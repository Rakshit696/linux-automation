#!/bin/bash

# Ignore TERM, HUP and INT signals
trap '' TERM HUP INT

# Function to log changes
log_changes() {
    if [ "$verbose" = true ]; then
        echo "$1"
    fi
    logger "$1"
}

# Function to update hostname
update_hostname() {
    if [ "$desired_name" != "$(hostname)" ]; then
        echo "$desired_name" | sudo tee /etc/hostname >/dev/null
        sudo hostnamectl set-hostname "$desired_name"
        log_changes "Updated hostname from $(hostname) to $desired_name"
    else
        if [ "$verbose" = true ]; then
            echo "Hostname is already set to $desired_name"
        fi
    fi
}

# Function to update IP address
update_ip_address() {
    current_ip=$(ip addr show dev "$lan_interface" | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)
    if [ "$current_ip" != "$desired_ip" ]; then
        sudo sed -i "s/$current_ip/$desired_ip/g" /etc/hosts
        sudo netplan apply
        log_changes "Updated IP address from $current_ip to $desired_ip"
    else
        if [ "$verbose" = true ]; then
            echo "IP address is already set to $desired_ip"
        fi
    fi
}

# Function to update /etc/hosts
update_hosts_file() {
    if ! grep -q "$desired_ip $desired_name" /etc/hosts; then
        echo "$desired_ip $desired_name" | sudo tee -a /etc/hosts >/dev/null
        log_changes "Added $desired_name ($desired_ip) to /etc/hosts"
    else
        if [ "$verbose" = true ]; then
            echo "$desired_name ($desired_ip) already exists in /etc/hosts"
        fi
    fi
}

# Parse command line arguments
verbose=false
desired_name=""
desired_ip=""
while getopts "vn:i:h:" opt; do
    case $opt in
        v)
            verbose=true
            ;;
        n)
            desired_name="$OPTARG"
            ;;
        i)
            desired_ip="$OPTARG"
            ;;
        h)
            IFS=' ' read -ra args <<< "$OPTARG"
            desired_name="${args[0]}"
            desired_ip="${args[1]}"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Determine the LAN interface
lan_interface=$(ip route get 8.8.8.8 | awk '{print $5}')

# Update hostname, IP address, and /etc/hosts
update_hostname
update_ip_address
update_hosts_file
