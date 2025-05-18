#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root!"
  exit 1
fi

# Display main menu
show_menu() {
  echo "==============================="
  echo "   Linux User Management Tool  "
  echo "==============================="
  echo "1) Create User"
  echo "2) Add User to Sudo Group"
  echo "3) List Users and Permissions"
  echo "4) Delete User"
  echo "5) Exit"
  echo "==============================="
}

# 1. Create a new user
create_user() {
  read -p "Enter username to create: " username
  if id "$username" &>/dev/null; then
    echo "User '$username' already exists."
  else
    useradd -m "$username"
    passwd "$username"
    echo "User '$username' created successfully."
  fi
}

# 2. Add user to sudo group
add_to_sudo() {
  read -p "Enter username to add to sudo group: " username
  if id "$username" &>/dev/null; then
    usermod -aG sudo "$username"
    echo "User '$username' added to sudo group."
  else
    echo "User '$username' does not exist."
  fi
}

# 3. List all users and sudo permissions
list_users() {
  printf "%-20s %-10s\n" "Username" "Is Sudo?"
  echo "--------------------------------------"
  while IFS=: read -r username _ uid _ _ home shell; do
    if [[ $uid -ge 1000 && $username != "nobody" ]]; then
      groups=$(id -nG "$username")
      if [[ $groups == *"sudo"* ]]; then
        sudo_status="Yes"
      else
        sudo_status="No"
      fi
      printf "%-20s %-10s\n" "$username" "$sudo_status"
    fi
  done < /etc/passwd
}

# 4. Delete a user
delete_user() {
  read -p "Enter username to delete: " username
  if id "$username" &>/dev/null; then
    read -p "Are you sure you want to delete '$username'? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      userdel -r "$username"
      echo "User '$username' deleted."
    else
      echo "Deletion cancelled."
    fi
  else
    echo "User '$username' does not exist."
  fi
}

# Main loop
while true; do
  show_menu
  read -p "Choose an option [1-5]: " choice
  case $choice in
    1) create_user ;;
    2) add_to_sudo ;;
    3) list_users ;;
    4) delete_user ;;
    5) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option." ;;
  esac
  echo
done