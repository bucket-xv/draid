#!/bin/bash

# mount sda4 to /var/lib/ceph
dev=$1
sudo apt update
sudo mkdir -p /var/lib/ceph
sudo mkfs.ext4 $dev
sudo mount -t auto -v $dev /var/lib/ceph

# install cephadm and ceph-common
tools/install_release.sh
sudo apt install sysstat iftop -y

# cephadm bootstrap
cd ~/draid/deploy
host=$(head -n 1 int_ip_addrs_server.txt)
sudo cephadm bootstrap --mon-ip $host --allow-fqdn-hostname --cluster-network 10.10.1.0/24 --public-network 10.10.1.0/24
sudo ceph orch apply osd --all-available-devices
