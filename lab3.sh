#!/bin/bash

# Set the remote server details
server1_host="server1-mgmt"
server1_user="remoteadmin"
server2_host="server2-mgmt"
server2_user="remoteadmin"

# Set the desired configurations
server1_name="loghost"
server1_ip="192.168.16.3"
server2_name="webhost"
server2_ip="192.168.16.4"

# Check if verbose mode is enabled
verbose=false
if [ "$1" = "-verbose" ]; then
    verbose=true
fi

# Transfer the configure-host.sh script to the remote servers
scp configure-host.sh "$server1_user@$server1_host:/root"
scp configure-host.sh "$server2_user@$server2_host:/root"

# Run the configure-host.sh script on the remote servers
if [ "$verbose" = true ]; then
    ssh "$server1_user@$server1_host" -- /root/configure-host.sh -verbose -name "$server1_name" -ip "$server1_ip" -hostentry "$server2_name" "$server2_ip"
    ssh "$server2_user@$server2_host" -- /root/configure-host.sh -verbose -name "$server2_name" -ip "$server2_ip" -hostentry "$server1_name" "$server1_ip"
else
    ssh "$server1_user@$server1_host" -- /root/configure-host.sh -name "$server1_name" -ip "$server1_ip" -hostentry "$server2_name" "$server2_ip"
    ssh "$server2_user@$server2_host" -- /root/configure-host.sh -name "$server2_name" -ip "$server2_ip" -hostentry "$server1_name" "$server1_ip"
fi

# Update the local /etc/hosts file
./configure-host.sh -hostentry "$server1_name" "$server1_ip"
./configure-host.sh -hostentry "$server2_name" "$server2_ip"
