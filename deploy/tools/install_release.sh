sudo apt install containerd docker.io software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.10 -y

cd ~
CEPH_RELEASE=19.2.0
CEPH_NAME=squid
sudo curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm
sudo chmod +x cephadm
sudo ./cephadm add-repo --release $CEPH_NAME
sudo ./cephadm install
sudo cephadm add-repo --release $CEPH_NAME
sudo cephadm install ceph-common
sudo cephadm install ceph-base
sudo cephadm install librados-dev