# Example for scheduling DDP training on Kubernetes cluster

Following these instructions will schedule a simple ddp example on a kubernetes cluster. If you use the script in the temp/ folder you will get a simple response from each worker. If you use the script in the project/ folder you will train a simple autoencoder on the MNIST dataset.

## Prerequisites

- Kubernetes cluster running
- Volcano installed on k8s cluster, see how to install [here](https://volcano.sh/en/docs/installation/)
- kube config file copied from master node to the local machine
- Docker running on local machine
- Logged in to docker image registry of your choice on local machine (if you are not using Dockerhub make sure that the CRI in the k8s cluster can access your local image registry)

## Instructions

1. Clone the MLOps repo.
1. Navigate to this folder in e.g. VScode:

```
cd k8sDDPtrainTest/
```

3. Create python virtual environment

`python3 -m venv .venv`

and activate it

`source .venv/bin/activate`

4. Install required packages

`pip install -r requirements.txt`

5. Copy the kube config file from the master node located at `~/.kube/config`. For `torchX` to be able to find the k8s cluster you need to have `~/.kube/` on your local machine and put the kube config there:

Create this directory, if it doesn't already exist:

`mkdir ~/.kube/`

Copy over the kube config with scp:

`scp master@master:~/.kube/config ~/.kube/`

6. Login to a docker registry like:

```
docker login -u "vaskostara" -p "#MLOps@infotiv" docker.io
```

7. Navigate to either `temp` or `project`

`cd temp/`

or

`cd project`

8. Schedule the ddp job on the k8s cluster with torchX.

In `temp`:

```
torchx run --scheduler kubernetes dist.ddp -j 1x2 --script dist_app.py
```

or in `project`

```
torchx run -s kubernetes dist.ddp -j 1x2 --script main.py
```

9. You can check that the job has been successfully scheduled with kubectl on the master node, or if you have kubectl installed locally you can check it here.

`kubectl get pods`

10. To see the results you can do

`kubectl logs -f <Name>`

# Volcano CLI

To be able to interact with Volcano jobs you need the Volcano CLI, vcctl, on the master node. [Reference](https://volcano.sh/en/docs/cli/)

1. Clone Volcano repo

`git clone https://github.com/volcano-sh/volcano.git`

2. go into volcano folder

`cd volcano`

3. install vcctl with make (requires make and go)

`make vcctl`

4. make the executable availabel anywhere

`cp _output/bin/vcctl /usr/bin`

You can now list volcano jobs

`vcctl job list`

or delete volcano jobs

`vcctl job delete --name name --namespace namespace`

See website for full list of commands

# Notes if you are not using this folder

- for torchX commands to work they need to be run in a folder that, apart from the
  python script, contains a .torchxconfig file that specifies Volcano queue
  and image repository to push and pull from. The config file for kubernetes scheduler can be created by running:

`torchx configure -s kubernetes`

- For unknown reasons the scheduling only works in a subfolder of the project.
  So if you have a folder with a virtual environment, you must create the
  python script and torchxconfig in a subfolder inside the project folder
  and run torchx there.
