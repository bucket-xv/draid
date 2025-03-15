#!/bin/bash
# Usage: ./cleanup.sh
# Description: Remove all objects in the pool

PROJ_DIR=$(dirname "$(dirname "$(realpath "$0")")")

# Remove all images in all cli nodes
while read -r -u10 line; do
    ssh "$line" "sudo docker rmi \$(sudo docker images -q)"
done 10< $PROJ_DIR/configs/int_ip_addrs_cli.txt

# Stop and remove registry
registry=$(tail -n 1 $PROJ_DIR/configs/int_ip_addrs_server.txt)
ssh "$registry" "sudo docker stop registry && sudo docker rm registry"

# Remove all objects in the pool
sudo radosgw-admin bucket rm --bucket=registry --purge-objects  # --bypass-gc
# sudo radosgw-admin user rm --uid=chenhao --purge-keys --purge-data
sleep 1
sudo ceph tell mon.\* injectargs '--mon-allow-pool-delete=true'
sleep 1

# Delete the pool
sudo ceph osd pool delete default.rgw.buckets.data default.rgw.buckets.data --yes-i-really-really-mean-it
sleep 20