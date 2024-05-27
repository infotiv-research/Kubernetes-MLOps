# syntax=docker/dockerfile:1

FROM python:3

RUN apt-get update && apt-get install -y git && apt-get install -y libgl1-mesa-glx

WORKDIR /usr/src/forkliftdetection

RUN git clone https://github.com/ultralytics/yolov5

WORKDIR /usr/src/forkliftdetection/yolov5

RUN pip install -qr requirements.txt

# Mounting shared folder to "forkliftdata" inside container
VOLUME /usr/src/forkliftdetection/mnt

COPY data.yaml /usr/src/forkliftdetection/yolov5

# Running train.py script after build and copying training result to mounted directory
ENTRYPOINT python train.py --img 416 --batch 16 --epochs 2 --data data.yaml --weights yolov5s.pt --cache && cp ./runs/train/exp/weights/best.pt /usr/src/forkliftdetection/mnt
