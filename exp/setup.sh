#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <file_num> <file_size in Mbs> <bandwidth in Mbs> <mode> <data chunk> <parity chunk>"
    exit 1
fi

# Assign the first and second arguments to variables
file_num=$1
file_size=$2
bandwidth=$3
mode=$4
k=$5
m=$6

# First set the cluster status
sudo ceph balancer off
sudo ceph osd set-require-min-compat-client reef
sudo ceph balancer mode read

# Then create the pool
cd ~/draid/exp
./create_ecpool.sh $k $m
# sudo ceph osd pool set default.rgw.buckets.data fast_read 1

# Put the random data
cd ~/draid/test
if [ "$mode" == "rados" ]; then
    python gen_data.py 1 $file_size
    for i in $(seq 0 ${file_num}); do
        sudo rados -p default.rgw.buckets.data put object$i ~/draid/data/0.txt
        echo "Put object$i"
    done
elif [ "$mode" == "rgw" ]; then
    # Activate the pool
    sudo ceph osd pool application enable default.rgw.buckets.data rgw
    sleep 1
    # Put the objects
    ip=$(head -n 1 ~/draid/deploy/int_ip_addrs_cli.txt)

    ssh $ip "cd ~/draid/test && python gen_data.py 1 $file_size && python put_objects.py $file_num"
else
    echo "Invalid mode. Exiting..."
    exit 1
fi

# First limit the bandwidth of the monitor node
cd ~/draid/deploy
sip=$(head -n 1 int_ip_addrs_server.txt)
git submodule update --recursive --init
cd ~/draid/exp 
./change_bandwidth.sh $sip -c && ./change_bandwidth.sh $sip -l $bandwidth
echo "Changed bandwidth of $sip to $bandwidth"


# Then limit the bandwidth of server nodes
while read -r -u10 ip && read -r -u11 bandwidth
do
    ssh $ip "git clone --recurse-submodules git@github.com:bucket-xv/draid.git"
    ssh $ip "cd draid && git pull"
    ssh $ip "cd draid/exp && ./change_bandwidth.sh $ip -c && ./change_bandwidth.sh $ip -l $bandwidth"
    echo "Changed bandwidth of $ip to $bandwidth"
done 10< ~/draid/deploy/int_ip_addrs_server.txt 11< /tmp/bandwidth.txt


# Then compile the code on the client nodes
while read -r -u10 ip
do
    ssh $ip "git clone --recurse-submodules git@github.com:bucket-xv/draid.git"
    ssh $ip "cd draid && git pull"
    ssh $ip "cd draid/test && make clean && make"
done 10< ~/draid/deploy/int_ip_addrs_cli.txt

# Finally wait for the cluster to be ready
cd ~/draid/exp
for i in {1..4}
do
    sleep 3
    tools/wait_until.sh
done
