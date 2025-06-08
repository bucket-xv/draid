#!/bin/bash
DRAID_DIR=$(dirname "$(dirname "$(realpath "$0")")")

image=$1
ip=$(tail -n 1 $DRAID_DIR/configs/int_ip_addrs_server.txt)

echo $ip

sudo docker pull $image
sudo docker tag $image $ip:5005/$image
sudo docker push $ip:5005/$image