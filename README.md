# `create_users.sh` Script

## Overview

`create_users.sh` is a Bash script designed to automate the creation and management of user accounts and groups in a Linux environment. The script reads a text file for usernames and group names, creates users and groups, sets up home directories, generates secure passwords, logs all actions, and securely stores the passwords.

## Features

- Reads usernames and group names from a text file.
- Creates user accounts and associated groups.
- Assigns users to specified groups.
- Sets up home directories with correct permissions.
- Generates random secure passwords.
- Logs actions to `/var/log/user_management.log`.
- Stores passwords in `/var/secure/user_passwords.csv`.

## Prerequisites

- Linux environment (tested on Ubuntu).
- Bash shell.
- `openssl` installed.

## Installation

1. **Clone the repository** (if applicable):

    ```bash
    git clone https://github.com/your-repo/create_users.sh
    cd create_users.sh
    ```

2. **Ensure the script has execution permissions**:

    ```bash
    chmod +x create_users.sh
    ```

3. **Prepare the input file**:
    - Create a text file (e.g., `users.txt`) with each line containing a username and a semicolon-separated list of groups:

      ```text
      alice;developers,sysadmin
      bob;developers
      charlie;sysadmin,network
      ```

## Usage

Run the script with the input file as an argument:

```bash
sudo ./create_users.sh users.txt
