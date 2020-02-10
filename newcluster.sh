#see https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node
sudo sysctl net.bridge.bridge-nf-call-iptables=1

echo would you like to pull images? \(only necessary for fresh OS installs\) [y/N]
read SHOULD_PULL_IMAGES

if [[ $SHOULD_PULL_IMAGES == 'y' ]]; then
  echo pulling images...
  sudo kubeadm config images pull -v3
fi

echo initializing cluster...
sudo kubeadm init --ignore-preflight-errors=SystemVerification # --pod-network-cidr=10.244.0.0/16 # flannel only

echo generating kubernetes configs...
mkdir -p $HOME/.kube &&
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config &&
sudo chown $(id -u):$(id -g) $HOME/.kube/config &&

#see https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#-installation
# make sure your vpn isn't conflicting with ip's!
echo applying weave network controller...
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# sudo iptables -P FORWARD ACCEPT
