#!/bin/bash

set -e

read -s -p "Enter sudo password: " password
echo

echo "Installing smbclient, utils and seting up directories"

echo "$password" | sudo -S apt-get update
sudo apt install smbclient
sudo apt install cifs-utils
sudo mkdir -p /mnt/sambashare

echo "Installing Docker and containerd CRI"

sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo docker run hello-world

echo "Installing kubeadm, kubectl and kubelet"

echo "WARNING: disabling swap, this is required for kuberentes to work"

sudo swapoff -a
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Updating containerd config file"

sudo cp ./config.toml /etc/containerd/config.toml
sudo systemctl restart containerd

echo "Updating containerd config file"

sudo kubeadm join master:6443 --token 7hupk5.j4puhab588gwlb6f --discovery-token-unsafe-skip-ca-verification
