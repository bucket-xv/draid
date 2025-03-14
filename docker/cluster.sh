#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 k m"
    exit 1
fi

# Assign the arguments to variables
k=$1
m=$2

# Add specified key for user chenhao
# sudo radosgw-admin key create --uid=chenhao --key-type=s3 --access-key fooAccessKey --secret-key fooSecretKey

# Set the cluster status
sudo ceph balancer off
sudo ceph osd set-require-min-compat-client reef
sudo ceph balancer mode read

# Then create the pool
cd ~/draid/docker
./create_ecpool.sh $k $m

# Enable the pool for rgw
sudo ceph osd pool application enable default.rgw.buckets.data rgw
sleep 1

# Wait for the cluster to be ready
for i in {1..5}
do
    sleep 3
    python tools/is_ready.py 
done

# Create a bucket for user
cd ~/draid/docker
sudo apt install pip -y
pip install boto3
python create_bucket.py
