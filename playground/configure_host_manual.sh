#!/bin/bash

# mount sda4 to /var/lib/ceph
sudo apt update
sudo mkdir -p /var/lib/ceph
sudo mkfs.ext4 /dev/sdc
sudo mount -t auto -v /dev/sdc /var/lib/ceph

# install cephadm and ceph-common
cd ~
sudo apt install docker.io software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.10 -y
git clone git@github.com:bucket-xv/cephdeb.git
cd ~/cephdeb
git pull
sudo dpkg -i *.deb
sudo apt --fix-broken install -y

cd ~/draid/deploy
./bootstrap_manual.sh
