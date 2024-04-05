#!/bin/bash

# Function to log messages to syslog
log_message() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
    logger -t configure-host.sh "$1"
}

# Function to update /etc/hosts file
update_hosts() {
    if grep -q "$2" /etc/hosts; then
        log_message "Host entry already exists in /etc/hosts"
    else
        echo "$1 $2" | sudo tee -a /etc/hosts >/dev/null
        log_message "Added host entry $1 $2 to /etc/hosts"
    fi
}

# Function to update /etc/hostname file
update_hostname() {
    current_hostname=$(hostname)
    if [ "$1" != "$current_hostname" ]; then
        sudo hostnamectl set-hostname "$1"
        log_message "Changed hostname to $1"
    else
        log_message "Hostname already set to $1"
    fi
}

# Function to update IP address in netplan file
update_netplan() {
    if grep -q "$2" /etc/netplan/*.yaml; then
        log_message "Desired IP address already configured in netplan file"
    else
        sudo sed -i "s/addresses: \[\(.*\)\]/addresses: \[$2\]/g" /etc/netplan/*.yaml
        sudo netplan apply
        log_message "Changed IP address to $2 in netplan file"
    fi
}

# Function to handle command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -verbose)
        VERBOSE=true
        shift
        ;;
    -name)
        DESIRED_HOSTNAME="$2"
        update_hostname "$DESIRED_HOSTNAME"
        update_hosts "127.0.1.1" "$DESIRED_HOSTNAME"
        shift 2
        ;;
    -ip)
        DESIRED_IP="$2"
        update_hosts "$DESIRED_HOSTNAME" "$DESIRED_IP"
        update_netplan "$DESIRED_IP"
        shift 2
        ;;
    -hostentry)
        DESIRED_HOSTNAME="$2"
        DESIRED_IP="$3"
        update_hosts "$DESIRED_HOSTNAME" "$DESIRED_IP"
        shift 3
        ;;
    *)
        echo "Invalid argument: $1"
        exit 1
        ;;
    esac
done
