#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <log disk> <num of osd servers> <osd disks>"
    exit 1
fi
./configure_host_source.sh $1
./configure_server.sh
./configure_cli.sh
tools/deploy_service.sh $2 $3