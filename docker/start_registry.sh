#!/bin/bash

sudo apt update
sudo apt install containerd docker.io iftop -y

registry=$(tail -n 1 ~/draid/deploy/int_ip_addrs_server.txt)

content="{
  \"insecure-registries\" : [\"$registry:5000\"]
}"

sudo mkdir -p /etc/docker
echo "$content" | sudo tee /etc/docker/daemon.json > /dev/null

sudo docker run -d -p 5000:5000 -p 5001:5001 --restart=always --name registry \
                -v `pwd`/../configs/registry.yml:/etc/docker/registry/config.yml \
                registry

                # -v `pwd`/../configs/registry.yml:/etc/distribution/config.yml \
                # -e REGISTRY_HTTP_ADDR=0.0.0.0:5000\

# sudo docker tag ubuntu 10.10.1.1:5000/ubuntu:latest
# sudo docker push 10.10.1.1:5000/ubuntu:latest