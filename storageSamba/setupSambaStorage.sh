#!/bin/bash

apt-get update -y > /dev/null && \
apt-get install samba -y > /dev/null && \
apt-get upgrade -y > /dev/null


text="[sambashare]
comment= Network Shared Folder by Samba Server on Ubuntu
path = /home/storage/sambashare
force user = storage
force group = storage
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
public = yes
read only = no
"

echo "$text" | tee -a /etc/samba/smb.conf > /dev/null

mkdir -p /home/storage/sambashare
chown -R storage:storage /home/storage/sambashare
chmod -R g+w /home/storage/sambashare
systemctl restart smbd
