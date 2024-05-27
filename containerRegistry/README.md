# Container Registry Setup

### Setup Tutorial : [How to Configure Private Registry for Kubernetes cluster running with containerd](https://mrzik.medium.com/how-to-configure-private-registry-for-kubernetes-cluster-running-with-containerd-cf74697fa382)

### Installation on the Registry Server

```
apt update
apt -y install docker.io docker-registry apache2-utils
```

```
sudo nano /etc/docker/registry/config.yml

#change htpasswd path
htpasswd:
    realm: basic-realm
    path: /etc/docker/registry/.htpasswd
```

```
sudo systemctl restart docker
sudo systemctl restart docker-registry

sudo ufw allow 5000/tcp
```

#### If you want to change your user admin:

```
sudo htpasswd -Bc /etc/docker/registry/.htpasswd regadmin
```

#### Suggested Credentials

|          |            |
| -------- | ---------- |
| User     | `regadmin` |
| Password | `REDACTED` |

## Pushing an Image to the Local Registry

To push to local registry the image needs to be built and tagged properly:

On a server (preferably not the master to avoid taking up space) run:

```
sudo docker build -t registry:5000/<image_name>:<image_version> .
sudo docker tag registry:5000/<image_name>:<image_version> <image_name>:<image_version>
sudo docker push registry:5000/<image_name>:<image_version>
```

OBS! OBS! OBS! THE BELOW "daemon.json" FILE NEEDS TO BE ON ALL CLIENTS THAT ARE ACCESSING
THE HOSTED IMAGE REGISTRY!!!

```
sudo nano /etc/docker/daemon.json
{
  "insecure-registries":
    ["registry:5000", "192.168.10.60:5000"]
}

sudo systemctl restart docker
```

| image_name      | image_version |
| --------------- | ------------- |
| yolov5_training | 1.0           |
| yolov5_testing  | 1.0           |

#### Testing private registry

To test if your private registry is functioning properly, you can use an example image. The following example uses the image `nginx:1.0`.

#### On the master node:

```
sudo docker pull nginx
sudo docker image ls
sudo docker tag nginx registry:5000/nginx:1.0
sudo docker login registry:5000
sudo docker push registry:5000/nginx:1.0
# to test that you can pull the pushed image
sudo docker pull registry:5000/nginx:1.0
```

ATTENTION:
If you get these error messages, it means that the config file `/etc/docker/daemon.json` is not updated correctly.

```
Error response from daemon: Get "https://registry:5000/v2/": dial tcp 192.168.10.60:5000: connect: connection refused

Error response from daemon: Get "https://registry:5000/v2/": http: server gave HTTP response to HTTPS client
```

## Pulling an Image from the Local Registry

### Configure kubernetes to pull local images

Useful link: [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#log-in-to-docker)

Create a secret on the master node:

```
kubectl create secret docker-registry regcred --docker-server=registry --docker-username=regadmin --docker-password=REDACTED
kubectl get secret regcred --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode
```

Copy the base64 number after "auth=" (`"cmVnYWRtaW46cmVnaXN0cnk="`) and paste it in the /etc/containerd/config.toml file:

After ` [plugins."io.containerd.grpc.v1.cri".registry.configs]` section add the following lines:

```
[plugins."io.containerd.grpc.v1.cri".registry.configs."registry:5000".tls]
      insecure_skip_verify = true
    [plugins."io.containerd.grpc.v1.cri".registry.configs."registry:5000".auth]
      auth = "cmVnYWRtaW46cmVnaXN0cnk="
```

and after `[plugins."io.containerd.grpc.v1.cri".registry.mirrors]`:

```
[plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry:5000"]
      endpoint = ["http://registry:5000"]
```

```
systemctl restart containerd
```

To test container registry in our cluster we can use the following [pod](/containerRegistry/private-reg-pod.yaml):

```
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: registry:5000/nginx:1.0
  imagePullSecrets:
  - name: regcred
```

Then apply the pod file and check if it was created:

```
kubectl apply -f private-reg-pod.yaml
kubectl get pod private-reg
```
