#!/bin/bash

echo "Pre read balance"
sudo ceph pg ls-by-pool default.rgw.buckets.data | python tools/info.py

sudo ceph balancer optimize plan
sleep 1
# sudo ceph balancer show plan
sudo ceph balancer execute plan

for i in {1..3}
do
    sleep 3
    tools/wait_until.sh
done

echo "Post read balance"
sudo ceph pg ls-by-pool default.rgw.buckets.data | python tools/info.py