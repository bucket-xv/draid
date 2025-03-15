#!/bin/bash

export DRAID_DIR=$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")

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
    ssh $ip "cd $DRAID_DIR && git pull" 1>&2
    ssh $ip "cd $DRAID_DIR/docker/tools && ./watch.sh $INTERFACE"
done 10< $DRAID_DIR/configs/int_ip_addrs_server.txt