#!/bin/bash

export DRAID_DIR=$(dirname "$(dirname "$(realpath "$0")")")

meta_registry=$(head -n 1 $DRAID_DIR/configs/int_ip_addrs_server.txt)

sudo docker run -d -p 5005:5000 -p 5001:5001 --restart=always --name registry \
                -v $DRAID_DIR/configs/registry.yml:/etc/docker/registry/config.yml \
                $meta_registry:5000/registry:2

