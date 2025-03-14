#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <num_files> <file_size>"
    exit 1
fi

num_files=$1
file_size=$2

ip=$(head -n 1 ~/draid/deploy/int_ip_addrs_cli.txt)
registry=$(tail -n 1 ~/draid/deploy/int_ip_addrs_server.txt)
ssh $ip "cd ~/draid/docker/tools && python image.py push $registry:5000 -n $num_files -s $file_size"
