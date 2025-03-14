#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <num of osd servers> <osd disks>"
    exit 1
fi
./configure_host_source.sh
./configure_server.sh
./configure_cli.sh
tools/deploy_service.sh $1 $2