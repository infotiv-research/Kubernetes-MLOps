#!/bin/bash

set -e
echo


# Check if the share is already mounted
if mount | grep -q "/mnt/sambashare"; then
    echo -e "\nSamba share is already mounted.\n"
    exit 0
fi


host_name="storage"
# Main script
share_name="sambashare"

# Mount the Samba share using the resolved IP address
 mount -v -t cifs //"$host_name"/"$share_name" /mnt/"$share_name" -o guest

# Check if mount was successful
if [ $? -eq 0 ]; then
    echo -e "\nSamba share mounted successfully\n"
else
    echo -e "\nFailed to mount Samba share\n"
fi
