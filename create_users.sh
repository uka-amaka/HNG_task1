#!/bin/bash

# Script to create users and groups, set up home directories, and generate passwords.
# Logs actions to /var/log/user_management.log and stores passwords in /var/secure/user_passwords.csv.

# Log file
LOGFILE="/var/log/user_management.log"
# Secure password file
SECURE_PASS_FILE="/var/secure/user_passwords.csv"
# User input file from argument
INPUT_FILE="$1"

# Create necessary directories and set permissions
mkdir -p /var/secure
touch $SECURE_PASS_FILE
chmod 600 $SECURE_PASS_FILE

# Function to log messages
log_message() {
    local MESSAGE="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $MESSAGE" | tee -a $LOGFILE
}

# Function to generate a random password
generate_password() {
    local PASSWORD=$(openssl rand -base64 12)
    echo "$PASSWORD"
}

# Function to handle user creation
create_user() {
    local USERNAME=$1
    local GROUPS=$2

    # Check if user already exists
    if id "$USERNAME" &>/dev/null; then
        log_message "User $USERNAME already exists."
        return 1
    fi

    # Create the user with a personal group
    useradd -m -G "$USERNAME,$GROUPS" -s /bin/bash "$USERNAME"
    if [ $? -ne 0 ]; then
        log_message "Failed to create user $USERNAME."
        return 1
    fi

    # Set up home directory permissions
    chmod 700 /home/$USERNAME
    chown $USERNAME:$USERNAME /home/$USERNAME

    # Generate and set a password for the user
    PASSWORD=$(generate_password)
    echo "$USERNAME:$PASSWORD" | chpasswd
    if [ $? -ne 0 ]; then
        log_message "Failed to set password for user $USERNAME."
        return 1
    fi

    # Store the password securely
    echo "$USERNAME,$PASSWORD" >> $SECURE_PASS_FILE
    log_message "Created user $USERNAME with groups $GROUPS."
}

# Main script
if [ ! -f $INPUT_FILE ]; then
    log_message "Input file $INPUT_FILE not found."
    exit 1
fi

while IFS=';' read -r USERNAME GROUPS; do
    # Ignore whitespace and empty lines
    USERNAME=$(echo "$USERNAME" | xargs)
    GROUPS=$(echo "$GROUPS" | xargs)
    if [ -z "$USERNAME" ] || [ -z "$GROUPS" ]; then
        continue
    fi

    # Create groups if they do not exist
    IFS=',' read -ra GROUP_ARRAY <<< "$GROUPS"
    for GROUP in "${GROUP_ARRAY[@]}"; do
        if ! getent group "$GROUP" &>/dev/null; then
            groupadd "$GROUP"
            if [ $? -ne 0 ]; then
                log_message "Failed to create group $GROUP."
                continue
            fi
            log_message "Created group $GROUP."
        fi
    done

    # Create the user
    create_user "$USERNAME" "$GROUPS"
done < $INPUT_FILE

log_message "User creation script completed."
exit 0
