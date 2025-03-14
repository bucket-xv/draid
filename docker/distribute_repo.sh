#!/bin/bash

user=$1
registry=$(tail -n 1 ../deploy/int_ip_addrs_server.txt)
while read -u10 -r line
do
  # Distribute repo
  ssh "$user@$line" "git clone --recurse-submodules git@github.com:serverless-project/ServerlessPilot.git --branch xch/deploy"
  ssh "$user@$line" "cd ServerlessPilot && git pull && git submodule update --init --recursive --remote"

  # Set registry
  ssh "$user@$line" "sudo apt update && sudo apt install containerd docker.io iftop -y"
  ssh "$user@$line" "cd cephcluster && git pull && git submodule update --init --recursive"
  # ssh "$user@$line" "cd cephcluster/docker/tools && ./add_registry.sh $registry"

done 10< ../deploy/ip_addrs_all.txt

echo "You are all set!"
