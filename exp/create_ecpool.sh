#!/bin/bash

# Usage: ./create_ecpool.sh <k> <m>
# Description: Create an erasure-coded pool with k data chunks and m coding chunks
# Example: ./create_ecpool.sh 3 2
if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "Usage: ./create_ecpool.sh <k> <m>"
    exit 1
fi

# sudo ceph osd pool create default.rgw.buckets.index 1
sudo ceph osd erasure-code-profile rm ecprofile
sleep 1
sudo ceph osd erasure-code-profile set ecprofile \
    k=$1 \
    m=$2 \
    crush-failure-domain=host
sudo ceph osd pool create default.rgw.buckets.data erasure ecprofile
# sudo ceph osd pool create default.rgw.glacier.data erasure ecprofile

sleep 20
cd ~/cephcluster/exp
for i in {1..5}
do
    sleep 3
    tools/wait_until.sh
done


