#!/bin/bash

# Function to print usage
usage() {
    echo "Usage: $0 <ipv4_address> [-c]  [-l <bandwidth>]"
    exit 1
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    usage
fi

# Initialize flag variable
flag_c=false

# Loop through arguments
while [ "$1" != "" ]; do
    case $1 in
        -c ) flag_c=true
             ;;
        -l ) shift
             if [ -z "$1" ]; then
                 echo "Error: -l flag requires an argument."
                 usage
             fi
             bandwidth="$1"
             ;;
        * )  if [ -z "$IPV4_ADDRESS" ]; then
                IPV4_ADDRESS="$1"
            else
                usage
            fi
            ;;
    esac
    shift
done

# Check if the required argument is set
if [ -z "$IPV4_ADDRESS" ]; then
    usage
fi


INTERFACE=$(ip -4 addr show | grep -B1 "inet $IPV4_ADDRESS" | head -n1 | awk '{print $2}' | sed 's/://')

cd ~/cephcluster/wondershaper

if [ "$flag_c" = true ]; then
    sudo ./wondershaper -a $INTERFACE -c
else
    sudo ./wondershaper -a $INTERFACE -d $bandwidth -u $bandwidth
fi


cd ~


