#!/bin/bash

# This is executed on the mon node
stop_all() {
    echo "Stopping all processes, please wait..."
    while read -u10 -r ip
    do
        ssh "$ip" "sudo pkill -f pull_images.py"
    done 10< ~/cephcluster/deploy/int_ip_addrs_cli.txt
    echo "All processes stopped."
    exit 0
}


# Check if the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <file_num> <num_threads> <log_dir> <interface>"
    exit 1
fi

# Assign the first and second arguments to variables
file_num=$1
num_threads=$2
LOG_DIR=$3
interface=$4

trap 'stop_all $username' SIGINT

# Create a directory for logs if it doesn't exist
mkdir -p "$LOG_DIR"
rm -rf $LOG_DIR/*_out.log
rm -rf $LOG_DIR/*_err.log

# Setup traffic monitor on server nodes
cd ~/cephcluster/docker
while read -u10 -r ip
do
    TRAFFIC_MONITOR="cd ~/cephcluster/docker/tools && sudo ./monitor_network.sh"
    REMOTE_TRAFFIC_CSV="/tmp/${ip}_traffic.csv"
    ssh $ip "($TRAFFIC_MONITOR $interface) 2>/dev/null >$REMOTE_TRAFFIC_CSV </dev/null &"
done 10< ~/cephcluster/deploy/int_ip_addrs_server.txt

# Start experiment on all client nodes
random_seed=0
while read -u10 -r ip
do
    REMOTE_OUT_LOG="/tmp/${ip}_out.log"
    REMOTE_ERR_LOG="/tmp/${ip}_err.log"
    
    # Execute the program on the remote server and redirect output and stderr
    ssh $ip "(cd ~/cephcluster/docker && python pull_images.py $file_num $num_threads $random_seed) >$REMOTE_OUT_LOG 2>$REMOTE_ERR_LOG </dev/null &"
    random_seed=$((random_seed + num_threads))
done 10< ~/cephcluster/deploy/int_ip_addrs_cli.txt

echo "Execution started."

# Wait for the processes to finish and retrieve the logs
while read -u10 -r ip
do
    # Define the output and error log files on the remote server
    REMOTE_OUT_LOG="/tmp/${ip}_out.log"
    REMOTE_ERR_LOG="/tmp/${ip}_err.log"

    # Wait for the process to finish
    while ssh "$ip" "ps -ef | grep [p]ull_images.py"; do
        echo "Process is still running. Waiting..."
        sleep 5 
    done
    
    # SCP the output and error logs to the host machine and remove them from the remote server
    scp "$ip:$REMOTE_OUT_LOG" "$LOG_DIR/${ip}_out.log"
    scp "$ip:$REMOTE_ERR_LOG" "$LOG_DIR/${ip}_err.log"
    ssh "$ip" rm "$REMOTE_OUT_LOG" "$REMOTE_ERR_LOG"

done 10< ~/cephcluster/deploy/int_ip_addrs_cli.txt

# Get the traffic logs from the server nodes and terminate the traffic monitor
while read -u10 -r ip
do
    REMOTE_TRAFFIC_CSV="/tmp/${ip}_traffic.csv"
    scp "$ip:$REMOTE_TRAFFIC_CSV" "$LOG_DIR/${ip}_traffic.csv"
    ssh "$ip" sudo pkill -f "./monitor_network.sh"
    ssh "$ip" rm "$REMOTE_TRAFFIC_CSV"
done 10< ~/cephcluster/deploy/int_ip_addrs_server.txt

echo "Execution and log retrieval completed."
