#!/bin/bash

# This script monitors network traffic and writes it to a CSV file
# Usage: ./monitor_network.sh <interface>
# Example: ./monitor_network.sh eth0

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: ./monitor_network.sh <interface>"
    exit 1
fi

# Define the network interface and output file
INTERFACE=$1  # Replace with your interface name
# OUTPUT_FILE=$2  # Replace with the desired output file

# Write the header to the CSV file
echo "Timestamp, RX_Bytes, TX_Bytes"

# Get the initial RX and TX bytes
INIT_RX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
INIT_TX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# Monitor the traffic in a loop
while true; do
    # Get the current RX and TX bytes
    RX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    TX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

    # Calculate the difference in bytes
    DIFF_RX=$((RX_BYTES - INIT_RX_BYTES))
    DIFF_TX=$((TX_BYTES - INIT_TX_BYTES))
    
    # Get the current timestamp
    TIMESTAMP=$(date +%s)
    
    # Write the data to the CSV file
    echo "$TIMESTAMP, $DIFF_RX, $DIFF_TX"
    
    # Wait for 1 second
    sleep 1
done
