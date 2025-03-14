#!/bin/bash
# Usage: ./cleanup.sh <num_files>
# Description: Remove all objects in the pool
# Example: ./cleanup.sh 50
# if [ "$#" -ne 1 ]; then
#     echo "Illegal number of parameters"
#     echo "Usage: ./cleanup.sh <num_files>"
#     exit 1
# fi

# num_files=$1
# for i in $(seq 0 ${num_files}); do
#     sudo rados -p default.rgw.buckets.data rm object$i
#     echo "Remove object$i"
# done

sudo radosgw-admin bucket rm --bucket=bucket --purge-objects  # --bypass-gc
# sudo radosgw-admin user rm --uid=chenhao --purge-keys --purge-data
sleep 1
sudo ceph tell mon.\* injectargs '--mon-allow-pool-delete=true'
sleep 1

# sudo ceph osd pool delete default.rgw.control default.rgw.control --yes-i-really-really-mean-it
# sudo ceph osd pool delete default.rgw.log default.rgw.log --yes-i-really-really-mean-it
# sudo ceph osd pool delete default.rgw.meta default.rgw.meta --yes-i-really-really-mean-it
# sudo ceph osd pool delete default.rgw.buckets.index default.rgw.buckets.index --yes-i-really-really-mean-it
sudo ceph osd pool delete default.rgw.buckets.data default.rgw.buckets.data --yes-i-really-really-mean-it
sleep 20