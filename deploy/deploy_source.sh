#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <num of osd servers> <osd disks>"
    exit 1
fi
./configure_host.sh
./configure_server.sh
./configure_cli.sh
./deploy_service.sh $1 $2