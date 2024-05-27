# Kubernetes

## Overview

This document will guide you on how to setup a kubernetes cluster consisting of
one master node and one worker node, on two virtual machines on the same PC.

If you have access to more hardware feel free to have master and worker on
separate PCs. After the cluster is set up we will add to it:

- [persistent volume](/forkliftDetection/persistent-volume/sambashare.yaml)
- [persistent volume claim](/forkliftDetection/forkliftdetection_training/k8s/pvClaim.yaml)
- [secret for the local registry](/containerRegistry/README.md).

Finally we will start 2 kubernetes jobs, a [training job](/forkliftDetection/forkliftdetection_training/k8s/job.yaml)
and a [testing job](/forkliftDetection/forkliftdetection_testing/k8s/job.yaml).

It is generally considered best practice to install Docker before Kubernetes. By installing Docker first, we ensure compatibility between Kubernetes and the container runtime.
We are following the official instructions to [install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/), Version 25.0.3, by using the `apt` repository.

To begin a Kuberenetes cluster, we are first installing the [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) toolbox, Version 1.29, as shown in the official documentation.

Before every installation, initiation or joining, we must always deactivate swap space:

```
sudo swapoff -a
```

## Setting up the servers

The detailed documentation can be found in the main README file for MLOps.

- Download and install [Oracle VM VirtualBox](https://www.virtualbox.org/).
- Download [Ubuntu Server 22.04.4](https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-amd64.iso).
- Launch a virtual machine with Ubuntu server and name it "master".
   The master node needs AT LEAST 2 GB RAM AND 2 CPUs so make sure to allocate enough resources.
- In the Virtual Box interface, on the host machine: Go into settings >> Network and change "NAT" to "Bridged Adapter" to get a separate IP for this VM.
- In new VM clone the MLOps repository to the home directory
   and navigate to the [kubernetes setup folder](/MLOps/kubernetesSetup):

```
cd /MLOps/kubernetesSetup
```

### Setting up the master node

To initiate a master node, also referred to as control panel, with the pod network addon Flannel, we use the official documentation of
[creating a cluster with kubeadm ](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) &
[deploying Flannel with kubectl](https://github.com/flannel-io/flannel/tree/master)

6. Run the initialization script:

```
./master-node/master-setup.sh
```

This shell script will download Docker, containerd, kubeadm, kubelet and kubectl. After downloading everything will be configured and setup such that at then end of the script a kubernetes controlplane will be up and running.

The config.toml file has to be in the same directory as the shell script.

7. Wait for the set up to complete successfully. Don't follow the instructions of the output! This is already handled by the script.

### Setting up the worker node

1. Perform steps 1. to 5. from the previous section (Setting up the master node).
   The worker will be needing as much resources as you can give it. Name the VM "worker".

2. Run the initialization script:

```
worker-node/worker-setup.sh
```

3. Update docker container

```
sudo nano /etc/docker/daemon.json
{
  "insecure-registries":
    ["registry:5000", "192.168.10.60:5000"]
}

sudo systemctl restart docker
```

4. After the script has run successfully paste the join command output from step 8 in the last section
   (Setting up the kubernetes master) into the terminal of this worker and run it.

The worker should now have joined the cluster. You can verify this by going to the
master node terminal and running:

```
kubectl get nodes
```

## Verification & Troubleshooting

### Node List

To check all nodes, run on the master node:

```
kubectl get nodes
```

and review each output:

```
NAME       STATUS   ROLES           AGE    VERSION
...        ...      ...             ...    ...
```

### Node Roles

To set `worker` under `ROLES` for a worker node, run the following command:

```
kubectl label node <NAME> node-role.kubernetes.io/worker=worker
```

### ERROR `STATUS >> NotReady`

To resolve the `STATUS >> NotReady` error, copy the `NAME` of the erratic node and run the folloowing on the master node:

```
kubectl describe node <NAME>
```

You can address the issue by checking the `Conditions` section of the output and fixing the respective bug.
Here is an example of a well-functioning node:

```
...
Conditions:
  Type                Status   ...   Reason                      Message
  ----                ------   ---   ------                      -------
  NetworkUnavailable  False    ...   FlannelIsUp                 Flannel is running on this node
  MemoryPressure      False    ...   KubeletHasSufficientMemory  kubelet has sufficient memory available
  DiskPressure        False    ...   KubeletHasNoDiskPressure    kubelet has no disk pressure
  PIDPressure         False    ...   KubeletHasSufficientPID     kubelet has sufficient PID available
  Ready               True     ...   KubeletReady                kubelet is posting ready status. AppArmor enabled
...
```

#### AUTOMATIC WORKER JOIN WITH STARTUP

The worker node prompts user login before the startup process is completed.
When first prompted to login, wait until 3 lines of progress in the terminal, then press `Enter`.
Then you can login.

Recreating the error:
If you try to login during the first prompt, the command `systemctl is-active kubelet` will output `active`,
even though the worker hasn't joined! This will result in the `worker` node showing `STATUS >> NotReady`.

### Join Stuck on Preflight Checks

The join command contains the IP address.
So, while the IP address isn't static, you need to change it manually, or access it dynamically in the following scripts:

`kubernetesSetup/worker-node/worker-setup.sh`
or
`kubernetesSetup/restart-cluster/restart-worker.sh`

## Preparing an example cluster

To replicate this section make sure that you have ALL prerequisites below:

- Set up a kubernetes cluster by following the above documentation
  (minimum 1 master and 1 woker node with the samba client enabled on the worker).

Refer to this [container registry documentation](/storageSamba/README.md) for:

- A storage server named "storage" (Netbios name STORAGE) hosting a shared folder named "sambashare".
- In the shared samba folder (sambashare) there MUST be one folder called "dataforkliftv19_small" and
  one mp4 video called "testVideo4.mp4". These files are found in this
  [resource folder](/forkliftDetection/YOLOforkliftdetection_resources/).

Refer to this [samba storage documentation](/containerRegistry/README.md) for:

- A server hosting a local Docker registry. The hostname of the server MUST be in the name of the Docker images that are built from the Dockerfiles in
  forkliftDetection/forkliftdetection_result_testing and forkliftDetection/forkliftdetection_training.
- The hostname of the storage node must also be in the
  /etc/containerd/config.toml file.
- The "auth field" has the right base64 string.
- Both images must have been built and tagged correctly and pushed to the local Docker registry.

### Steps to populate example cluster from the MLOps repo

#### NOTE

If you are NOT going to use the local container registry then:

- skip step 2

- in step 5 run:

```
kubectl apply -f forkliftDetection/forkliftdetection_training/k8s/train.yaml
```

- in step 10 run:

```
kubectl apply -f forkliftDetection/forkliftdetection_testing/k8s/detect.yaml
```

1. Mount the shared folder (sambashare) on the worker node set up with samba by running

`./storageSamba/mount_samba.sh`

#### The following commands should all be run on the master node

2. To be able to access the local registry you need to add a secrete with the credentials, to the cluster (refer to Create_local_image_registry.txt to make sure you have use the right username and password below.)

`kubectl create secret docker-registry regcred --docker-username=regadmin --docker-password=REDACTED`

in this case the secret is called "regcred" make sure you use the right secret in the cofig files! All config files in this example use a secret called "regcred"

3. For the cluster to be able to recognize the shared folder as a storage for the cluster
   you must add a PersistentVolume to the cluster. On the master node and in the MLOps repo, run

```
kubectl apply -f forkliftDetection/persistent-volume/sambashare.yaml
```

4. The kubernetes jobs you are about to apply require a PresistentVolumeClaim:

```
kubectl apply -f forkliftDetection/forkliftdetection_training/k8s/pvClaim.yaml
```

5. Run the training job:

```
kubectl apply -f forkliftDetection/forkliftdetection_training/k8s/job.yaml
```

6. Check that the job was successfully created

```
kubectl get jobs
```

7. Check that the pod executing the job is successfully running

```
kubectl get pods
```

8. Note the pod name that you get from step 7 and check the details of your pod

```
kubectl describe pod <pod name>
```

Make sure that the image has been pulled successfully and that the pod is running without errors.

9. After the job has finished, check the logs

```
kubectl logs <pod name>
```

10. Now run the detection job

```
kubectl apply -f forkliftDetection/forkliftdetection_testing/k8s/job.yaml
```

You can check the jobs, pods, details and logs of the pod by repeating steps 6 to 9.
You should now have a simple, working, demo cluster.

## Setting up the Kubernetes dashboard

Please refer to this [documentation](/kubernetesSetup/manifestsKubernetesDashboard/README.md).
The k8s dashboard provides a more userfriendly way to manage the cluster. Before you can use it however you need to set it up.
The dashboard is running in a pod which is configured to be accessed from outside the cluster.

## Accessing the dashboard

1. Go to `https://<NodeIp>:<dashboard port>`

1. Log in with token (not with configuration file). You can get the login token by running:

```
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```

## Restarting the cluster after shutdown

To restart the cluster after shutdown, you can initiate a new master node by running:

```
./restart-cluster/restart-master.sh
```

To rejoin the master node from another server, run:

```
./restart-cluster/restart-worker.sh
```

### Trigger Restart Process with Startup

To have the excecutables run automatically with startup, make sure you are in the correct server
and add their path at the bottom of `.bashrc`:

```
cd
nano .bashrc
```

In the master server add:

```
# enable kubeadm init
$HOME/MLOps/kubernetesSetup/restart-cluster/restart-master.sh
```

In the worker server add:

```
# enable kubeadm join
$HOME/MLOps/kubernetesSetup/restart-cluster/restart-worker.sh
```

## Dashboard

To set up a Kubernetes Dashboard, refer to this [file](/kubernetesSetup/dashboard/README.md).
