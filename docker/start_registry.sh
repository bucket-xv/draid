#!/bin/bash

export DRAID_DIR=$(dirname "$(dirname "$(realpath "$0")")")

registry=$(tail -n 1 $DRAID_DIR/configs/int_ip_addrs_server.txt)

sudo docker run -d -p 5000:5000 -p 5001:5001 --restart=always --name registry \
                -v $DRAID_DIR/configs/registry.yml:/etc/docker/registry/config.yml \
                registry:2

                # -v `pwd`/../configs/registry.yml:/etc/distribution/config.yml \
                # -e REGISTRY_HTTP_ADDR=0.0.0.0:5000\

# sudo docker tag ubuntu 10.10.1.1:5000/ubuntu:latest
# sudo docker push 10.10.1.1:5000/ubuntu:latest