#see https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-reset/
echo removing last cluster...
sudo kubeadm reset
sudo rm -rf /var/lib/etcd # if not first time creating cluster
sudo iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
