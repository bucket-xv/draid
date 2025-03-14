#!/bin/bash

registry=$(tail -n 1 ~/cephcluster/deploy/int_ip_addrs_server.txt)

content="{
  \"insecure-registries\" : [\"$registry:5000\"]
}"

sudo mkdir -p /etc/docker
# sudo touch /etc/docker/daemon.json
echo "$content" | sudo tee /etc/docker/daemon.json > /dev/null

sleep 1
sudo systemctl restart docker