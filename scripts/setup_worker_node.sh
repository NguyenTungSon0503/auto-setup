curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B53DC80D13EDEF05
echo "step1"
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo "kubeadm install"
sudo apt update -y
sudo apt -y install vim git curl wget kubelet=1.26.1-00 kubeadm=1.26.1-00 kubectl=1.26.1-00
echo "memory swapoff"
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
if (systemctl -q is-active containerd)
  then
    echo "containerd is  still running."
      rm /etc/containerd/config.toml
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      sudo apt update
      sudo apt install -y containerd.io
      mkdir -p /etc/containerd
      containerd config default > /etc/containerd/config.toml
      sudo chmod 777 /etc/containerd/config.toml
      sudo systemctl restart containerd
      sudo systemctl enable containerd  
  else
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y containerd.io
    mkdir -p /etc/containerd
    containerd config default > /etc/containerd/config.toml
    sudo chmod 777 /etc/containerd/config.toml
    sudo systemctl restart containerd
    sudo systemctl enable containerd   
fi
containerd config default > /etc/containerd/config.toml
sudo chmod 777 /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl enable kubelet

#sudo kubeadm join test-k8s:6443 --token y0einr.sfcqd2oprxpjaa3c --discovery-token-ca-cert-hash sha256:e01eeeefb3cc987f7c99c286f2f2a11b75a2005cfe506219738b67ec7abc02e9
#sudo nano /proc/sys/net/ipv4/ip_forward (0 -> 1)