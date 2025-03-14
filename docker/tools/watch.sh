#!/bin/bash

# Usage: ./watch.sh <interface>
if [ "$#" -ne 1 ]; then
    echo "Usage: ./watch.sh <interface>"
    exit 1
fi

# Replace eth0 with your network interface
INTERFACE=$1

# Get the initial RX and TX bytes
initial_rx=$(cat /proc/net/dev | grep $INTERFACE | awk '{print $2}')
initial_tx=$(cat /proc/net/dev | grep $INTERFACE | awk '{print $10}')

echo $initial_rx
echo $initial_tx

# # Function to calculate and display the traffic
# calculate_traffic() {
#     current_rx=$(cat /proc/net/dev | grep $INTERFACE | awk '{print $2}')
#     current_tx=$(cat /proc/net/dev | grep $INTERFACE | awk '{print $10}')

#     rx_diff=$((current_rx - initial_rx))
#     tx_diff=$((current_tx - initial_tx))

#     echo "RX bytes since $(date):$rx_diff"
#     echo "TX bytes since $(date):$tx_diff"
# }

# # Use watch to call the function every 1 second
# calculate_traffic
