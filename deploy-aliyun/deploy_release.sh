#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 "
    exit 1
fi

./configure_host_release.sh $1
./configure_server.sh
./configure_cli.sh -r
tools/deploy_service.sh $2 $3