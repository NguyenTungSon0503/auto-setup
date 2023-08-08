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
sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock --kubernetes-version v1.26.1
sudo kubeadm init   --pod-network-cidr=10.244.0.0/16   --upload-certs --kubernetes-version=v1.26.1  --control-plane-endpoint=$(hostname) --ignore-preflight-errors=all  --cri-socket unix:///run/containerd/containerd.sock
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf
sudo chmod 777 /etc/kubernetes/admin.conf 
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
kubectl taint node $(hostname) node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint node $(hostname) node-role.kubernetes.io/master:NoSchedule-
wget https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz
tar -xvf helm-v3.7.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/