#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <data chunk> <parity chunk>"
    exit 1
fi

# Assign the first and second arguments to variables
k=$1
m=$2

# First set the cluster status
sudo ceph balancer off
sudo ceph osd set-require-min-compat-client reef
sudo ceph balancer mode read

# Then create the pool and enable the rgw application
./create_ecpool.sh $k $m
sudo ceph osd pool application enable default.rgw.buckets.data rgw

# Create pool in the rgw service
python create_bucket.py

# Start the registry
registry=$(tail -n 1 ../deploy/int_ip_addrs_server.txt)
ssh $registry "cd cephcluster/docker && ./start_registry.sh"

# Limit the bandwidth of all server nodes
while read -r -u10 ip && read -r -u11 bandwidth
do
    ssh $ip "git clone --recurse-submodules git@github.com:bucket-xv/cephcluster.git"
    ssh $ip "cd cephcluster && git pull"
    ssh $ip "cd cephcluster/docker && ./tools/change_bandwidth.sh $ip -c && ./tools/change_bandwidth.sh $ip -l $bandwidth"
    echo "Changed bandwidth of $ip to $bandwidth"
done 10< ~/cephcluster/deploy/int_ip_addrs_server.txt 11< /tmp/bandwidth.txt

# Wait for the cluster to be ready
for i in {1..5}
do
    sleep 3
    python tools/is_ready.py
done
