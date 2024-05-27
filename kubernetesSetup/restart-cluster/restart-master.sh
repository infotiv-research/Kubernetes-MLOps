# path=$HOME/MLOps/kubernetesSetup/restart-cluster/restart-master.sh

STATUS=$(systemctl is-active kubelet)

if [[ "$STATUS" == "active" ]]; then
    kubectl get nodes
else
    echo "Restarting Kubernetes Master Node"

    sudo swapoff -a
    sudo kubeadm reset -f
    sudo rm -rf $HOME/.kube

    echo "Using kubeadm to create a cluster with pod network cidr and constant token"

    sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --token 7hupk5.j4puhab588gwlb6f --token-ttl 0 >/dev/null

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    echo "Applying Flannel pod network add-on"

    kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
    kubectl get nodes
fi
