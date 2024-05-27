#!/bin/bash

#Install dependences
echo -e "Installing and upgrading\n"
apt install nbtscan &> /dev/null
apt install gawk &> /dev/null
apt upgrade -y &> /dev/null

# mount shared folder
../mount_samba.sh

# build docker container
docker build -t yolov5_training .

# start docker container
docker run --rm --shm-size=10g -v /mnt/sambashare:/usr/src/forkliftdetection/mnt yolov5_training
