#!/bin/bash

PROJ_DIR=$(dirname "$(dirname $(realpath "$0"))")

# mount sda4 to /var/lib/ceph
# dev=$1
# sudo apt update
# sudo mkdir -p /var/lib/ceph
# sudo mkfs.ext4 $dev
# sudo mount -t auto -v $dev /var/lib/ceph

# install cephadm and ceph-common
tools/install_source.sh
sudo apt install sysstat iftop -y

# cephadm bootstrap
cd $PROJ_DIR/configs
host=$(head -n 1 int_ip_addrs_server.txt) # Use the cluster network interface
sudo cephadm --image bucketxv/ceph:centos bootstrap --mon-ip $host --allow-fqdn-hostname -c ceph.conf
# sudo ceph orch apply osd --all-available-devices
