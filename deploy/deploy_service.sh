#!/bin/bash

export DRAID_DIR=$(dirname "$(dirname "$(realpath "$0")")")
# Check if a file name and a number of lines are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <number_of_osds> <device>"
  exit 1
fi

num_lines=$1
device=$2

# Initialize a counter for the number of lines processed
line_count=0

# hostname=$(hostname)
# sudo ceph orch daemon add osd $hostname:$device

# Install boto3 for python
sudo apt-get install python3-pip -y
pip3 install boto3

# Read the file line by line
while read -r -u10 line; do
  # Increment the line count
  ((line_count++))

  hostname=$(ssh $line hostname)

  # Check if we've reached the number of lines of osd
  if [ $line_count -gt $num_lines ]; then
    # If so, the host is for rgw service
    # Now, add label, we deploy them in the end together
    echo "$hostname is for rgw"
    sudo ceph orch host label add $hostname rgw
  else
    # If not, the host is for osd servic""e
    # Add the osd
    echo "$hostname is for osd"
    sudo ceph orch daemon add osd $hostname:$device
  fi
done 10< $DRAID_DIR/configs/int_ip_addrs_server.txt

# Add the labeling hosts as rgw
sudo ceph orch apply rgw foo '--placement=label:rgw count-per-host:2' --port=8000

# Yet add master:8000 as rgw
sudo ceph orch apply rgw bar --placement="master" --port=8000

# Wait until the service is started
sleep 10

# Create a user for rgw
mkdir -p $DRAID_DIR/configs
sudo radosgw-admin user rm --uid=chenhao
sudo radosgw-admin user create --uid=chenhao --display-name="Chenhao Xu" --email=xv_chen_hao@163.com > $DRAID_DIR/configs/user.json
sudo ceph orch ps --daemon_type rgw > $DRAID_DIR/configs/rgw.txt
cd $DRAID_DIR/deploy/tools
python gen_config.py
cd ..

# Scp the configs to server nodes
tail -n +2 $DRAID_DIR/configs/int_ip_addrs_server.txt | while read -r ip
do
  scp -r $DRAID_DIR/configs $ip:$DRAID_DIR/
done 

# Scp the configs to cli nodes
while read -r -u10 cli_ip
do
  echo "Scp the configs to $cli_ip"
  scp -r $DRAID_DIR/configs $cli_ip:$DRAID_DIR/
done 10< $DRAID_DIR/configs/int_ip_addrs_cli.txt

