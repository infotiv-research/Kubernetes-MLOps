# syntax=docker/dockerfile:1

FROM python:3

RUN apt-get update && apt-get install -y git && apt-get install -y libgl1-mesa-glx

WORKDIR /usr/src/forkliftdetection

RUN git clone https://github.com/ultralytics/yolov5

WORKDIR /usr/src/forkliftdetection/yolov5

RUN pip install -qr requirements.txt

# Mounting shared folder to "forkliftdata" inside container
VOLUME /usr/src/forkliftdetection/mnt

# Running detect.py script after build.
ENTRYPOINT python detect.py --weights "/usr/src/forkliftdetection/mnt/best.pt" --img 416 --conf 0.40 --source "/usr/src/forkliftdetection/mnt/testVideo4.mp4"

