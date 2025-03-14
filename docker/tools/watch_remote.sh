#!/bin/bash

# Usage: ./watch.sh <interface>
if [ "$#" -ne 1 ]; then
    echo "Usage: ./watch.sh <interface>"
    exit 1
fi

# Replace eth0 with your network interface
INTERFACE=$1

# cd tools && ./watch.sh $INTERFACE
while read -r -u10 ip
do
    ssh $ip "git clone --recurse-submodules git@github.com:bucket-xv/draid.git" 1>&2
    ssh $ip "cd draid && git pull" 1>&2
    ssh $ip "cd draid/docker/tools && ./watch.sh $INTERFACE"
done 10< ~/draid/deploy/int_ip_addrs_server.txt