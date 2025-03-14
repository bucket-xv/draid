#!/bin/bash
mon=$(head -n 1 ip_addrs_all.txt)
sudo touch /etc/ceph/ceph.conf
sudo touch /etc/ceph/ceph.client.admin.keyring
(ssh BucketXv@$mon "sudo ceph config generate-minimal-conf") | sudo tee /etc/ceph/ceph.conf >/dev/null
(ssh BucketXv@$mon "sudo cat /etc/ceph/ceph.client.admin.keyring") | sudo tee /etc/ceph/ceph.client.admin.keyring >/dev/null
