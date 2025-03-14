#!/bin/bash

# This is executed on the mon node

stop_all() {
    username=$1
    echo "Stopping all processes, please wait..."
    while read -u10 -r ip
    do
        ssh "$username@$ip" "sudo pkill -f ./read"
    done 10< ~/draid/deploy/int_ip_addrs_cli.txt
    echo "All processes stopped."
    exit 0
}


# Check if the correct number of arguments is provided
if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <Username> <file_num> <file_size in Mbs> <num_threads> <log_dir> <interface> <mode>"
    exit 1
fi

# Assign the first and second arguments to variables
username=$1
file_num=$2
file_size=$3
num_threads=$4
LOG_DIR=$5
interface=$6
mode=$7


trap 'stop_all $username' SIGINT

# Define the program to execute on the remote servers
if [ "$mode" == "rados" ]; then
    PROGRAM="cd ~/draid/test && sudo ./read"
elif [ "$mode" == "rgw" ]; then
    PROGRAM="cd ~/draid/test && python ./read.py"
else
    echo "Invalid mode. Exiting..."
    exit 1
fi

TRAFFIC_MONITOR="cd ~/draid/exp/tools && sudo ./monitor_network.sh"

# Create a directory for logs if it doesn't exist

mkdir -p "$LOG_DIR"

rm -rf $LOG_DIR/*_out.log
rm -rf $LOG_DIR/*_err.log

random_seed=0

# REMOTE_TRAFFIC_CSV="/tmp/10.10.1.1_traffic.csv"
# cd ~/draid/exp/tools
# sudo ./monitor_network.sh $interface 2>/dev/null >$REMOTE_TRAFFIC_CSV </dev/null &
cd ~/draid/exp
# Setup traffic monitor on server nodes
while read -u10 -r ip
do
    # Start the traffic monitor
    REMOTE_TRAFFIC_CSV="/tmp/${ip}_traffic.csv"
    ssh "$username@$ip" "($TRAFFIC_MONITOR $interface) 2>/dev/null >$REMOTE_TRAFFIC_CSV </dev/null &"
done 10< ~/draid/deploy/int_ip_addrs_server.txt


# Read each IP address from the file
while read -u10 -r ip
do
    # Define the output and error log files on the remote server
    REMOTE_OUT_LOG="/tmp/${ip}_out.log"
    REMOTE_ERR_LOG="/tmp/${ip}_err.log"
    
    # Execute the program on the remote server and redirect output and stderr
    ssh "$username@$ip" "($PROGRAM $file_num $file_size $num_threads $random_seed) >$REMOTE_OUT_LOG 2>$REMOTE_ERR_LOG </dev/null &"
    random_seed=$((random_seed + num_threads))
    # ssh "$username@$ip" "ps a"
done 10< ~/draid/deploy/int_ip_addrs_cli.txt

echo "Execution started."

# sleep 40

# Read each IP address from the file
while read -u10 -r ip
do
    # Define the output and error log files on the remote server
    REMOTE_OUT_LOG="/tmp/${ip}_out.log"
    REMOTE_ERR_LOG="/tmp/${ip}_err.log"

    while ssh "$username@$ip" "ps -ef | grep [.]/read"; do
        echo "Process $PROGRAM is still running. Waiting..."
        sleep 5  # Wait for 5 seconds before checking again
    done
    
    # SCP the output and error logs to the host machine
    scp "$username@$ip:$REMOTE_OUT_LOG" "$LOG_DIR/${ip}_out.log"
    scp "$username@$ip:$REMOTE_ERR_LOG" "$LOG_DIR/${ip}_err.log"

    # Remove the remote log files if needed
    ssh "$username@$ip" rm "$REMOTE_OUT_LOG" "$REMOTE_ERR_LOG"

    # ssh "$username@$ip" "sudo pkill -f $PROGRAM"
done 10< ~/draid/deploy/int_ip_addrs_cli.txt

# Get the traffic logs from the server nodes and terminate the traffic monitor

# cp /tmp/10.10.1.1_traffic.csv $LOG_DIR
# sudo pkill -f "./monitor_network.sh"
while read -u10 -r ip
do
    REMOTE_TRAFFIC_CSV="/tmp/${ip}_traffic.csv"
    scp "$username@$ip:$REMOTE_TRAFFIC_CSV" "$LOG_DIR/${ip}_traffic.csv"
    ssh "$username@$ip" sudo pkill -f "./monitor_network.sh"
    ssh "$username@$ip" rm "$REMOTE_TRAFFIC_CSV"
done 10< ~/draid/deploy/int_ip_addrs_server.txt

echo "Execution and log retrieval completed."
