#! /bin/bash

export DRAID_DIR=$(dirname "$(dirname "$(realpath "$0")")")

# Limit the bandwidth of all server nodes
while read -r -u10 ip && read -r -u11 bandwidth
do
    ssh $ip "cd $DRAID_DIR && git pull"
    ssh $ip "cd $DRAID_DIR/docker && ./tools/change_bandwidth.sh $ip -c && ./tools/change_bandwidth.sh $ip -l $bandwidth"
    echo "Changed bandwidth of $ip to $bandwidth"
done 10< $DRAID_DIR/configs/int_ip_addrs_server.txt 11< /tmp/bandwidth.txt