#!/bin/bash

#Install dependences
echo -e "Installing and upgrading\n"
apt install nbtscan &> /dev/null
apt install gawk &> /dev/null
apt upgrade -y &> /dev/null

# mount shared directory
../mount_samba.sh

# build detection container
docker build -t yolov5_detection .

# run detection container
docker run --rm --shm-size=10g -v /mnt/sambashare:/usr/src/forkliftdetection/mnt yolov5_detection
