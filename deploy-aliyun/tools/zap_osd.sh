#!/bin/bash

fsid=$1
CEPH_RELEASE=19.2.0
CEPH_NAME=squid
sudo curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm
sudo chmod +x cephadm
sudo ./cephadm add-repo --release $CEPH_NAME
sudo ./cephadm install
# sudo cephadm add-repo --release $CEPH_NAME >/dev/null
# # sudo cephadm install ceph-common
# # sudo cephadm install ceph-base
# sudo cephadm install ceph-volume >/dev/null
sudo apt --fix-broken install -y
# sudo apt install python3-packaging -y
dev=$(lsblk -o NAME,TYPE | grep -B1 'lvm' | head -n 1 | awk '{print $1}')
# sudo ceph-volume lvm zap /dev/$dev --destroy
sudo wipefs -af /dev/$dev

sudo cephadm rm-cluster --force --zap-osds --fsid $fsid