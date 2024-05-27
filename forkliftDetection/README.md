Added 3 .yaml files. If you have a k8s cluster up and running (master and worker) then you can apply the yaml files to the cluster.

- sambashare.yaml: Defines 10 Gi in the local folder /mnt/sambashare as a PersitentVolume in the k8s cluster.
- pvClaim.yaml:  Defines a PersistentVolumeClaim (part of the PersistentVolume) of 3 Gi as a PVclaim used for the training pod.
- job.yaml: Defines a k8s job that will execute the yolov5 training micro service using a PVclaim for accessing training data.

The above files can be applied to the cluster using: `kubectl apply -f </path/to/file.yaml>`

# Preparations

- Make sure there is a host machine/VM "storage" that is setup exactly according to the steps in SambaFileSharing.txt (ignore static IP section)
- Make sure the training data is located in the shared folder
- Make sure there is an mp4 video named "testvideo4.mp4" in the shared folder
- Make sure you have another machine/VM "worker" setup according to the steps in worker.txt
- Download this folder on the "worker" machine/VM

# Steps to run the model

- The `YOLOforkliftdetection_resources` has to be stored in Samba share and
- The IP address bug in `mount_samba.sh` is now fixed.
- The files `train.sh` and `detect.sh` now contain some dependency installations and the corresponding docker build. Also they should now be run with elevated permissions.
- While in the MLOps directory, run the following commands to:

## Train

```
cd sprint_w9/forkliftdetection_train
sudo ./train.sh
```

## Detect

```
cd sprint_w9/forkliftdetection_result_test
sudo ./detect.sh
```
