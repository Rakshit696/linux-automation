#!/bin/bash

# Function to transfer and run configure-host.sh script on a remote server
configure_remote_server() {
    local server_address="$1"
    local hostname="$2"
    local ip_address="$3"
    local entry_name="$4"
    local entry_ip="$5"

    # Transfer configure-host.sh script to the remote server
    scp configure-host.sh remoteadmin@"$server_address":/root

    # Run configure-host.sh script on the remote server
    ssh remoteadmin@"$server_address" -- /root/configure-host.sh -name "$hostname" -ip "$ip_address" -hostentry "$entry_name" "$entry_ip"
}

# Update local /etc/hosts file
update_local_hosts() {
    local entry_name="$1"
    local entry_ip="$2"

    # Run configure-host.sh locally
    ./configure-host.sh -hostentry "$entry_name" "$entry_ip"
}

# Configure server1-mgmt
configure_remote_server "server1-mgmt" "loghost" "192.168.16.3" "webhost" "192.168.16.4"

# Configure server2-mgmt
configure_remote_server "server2-mgmt" "webhost" "192.168.16.4" "loghost" "192.168.16.3"

# Update local /etc/hosts file
update_local_hosts "loghost" "192.168.16.3"
update_local_hosts "webhost" "192.168.16.4"

exit 0
