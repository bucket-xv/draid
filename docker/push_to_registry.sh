#!/bin/bash

image=$1
ip=$(tail -n 1 ../deploy/int_ip_addrs_server.txt)

echo $ip

sudo docker pull $image
sudo docker tag $image $ip:5000/$image
sudo docker push $ip:5000/$image