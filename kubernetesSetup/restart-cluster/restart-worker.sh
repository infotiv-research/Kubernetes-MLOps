# path=$HOME/MLOps/kubernetesSetup/restart-cluster/restart-worker.sh

STATUS=$(systemctl is-active kubelet)

if [[ "$STATUS" == "active" ]]; then
    echo "Worker Node Already Joined"
else
    echo "Rejoining Kubernetes Worker Node"

    sudo swapoff -a
    sudo kubeadm reset -f
    sudo rm -rf $HOME/.kube
    sudo kubeadm join master:6443 --token 7hupk5.j4puhab588gwlb6f --discovery-token-unsafe-skip-ca-verification
fi
