#!/bin/bash

sudo bin/ceph -s
sudo bin/ceph balancer status

cd ~/draid/test
python gen_data.py 1 2
cd ~/ceph/build
sudo bin/ceph balancer off
for i in $(seq 0 50); do
    sudo bin/rados -p default.rgw.buckets.data put object$i ~/draid/data/0.txt 2> /dev/null
done

sudo bin/ceph pg ls-by-pool default.rgw.buckets.data
sudo bin/ceph osd primary-affinity 1 0.612
sudo bin/ceph osd primary-affinity 2 0.4
sudo bin/ceph osd primary-affinity 3 0.2

sudo bin/ceph pg ls-by-pool default.rgw.buckets.data | python ~/draid/exp/tools/info.py

sleep 2
# sudo bin/ceph balancer eval default.rgw.buckets.data
sudo bin/ceph balancer optimize plan
sudo bin/ceph balancer show plan
# sudo bin/ceph balancer eval plan
sudo bin/ceph balancer execute plan

sudo cat out/* | grep 'already balanced'
sudo cat out/* | grep '20 balance_ec_primaries'
sudo cat out/* | grep -A 20 'Executing plan plan'


for i in {0..50}; do
    sudo bin/rados -p default.rgw.buckets.data get object$i ~/draid/data/get_$i.txt 2> /dev/null
    diff ~/draid/data/get_$i.txt ~/draid/data/0.txt
done

