PROJ_DIR=$(dirname "$(dirname $(realpath "$0"))")

sudo ceph orch rm rgw.foo
sudo ceph orch stop prometheus
sudo ceph orch stop grafana
sudo ceph orch stop alertmanager
sudo ceph orch stop node-exporter
sudo ceph orch stop crash
sudo ceph orch stop mgr
sudo ceph orch stop mon
sudo ceph orch stop osd
sudo ceph osd pool delete .rgw .rgw --yes-i-really-really-mean-it
sudo ceph osd pool delete .mgr .mgr --yes-i-really-really-mean-it
while read -r -u10 osd_ip
do
    hostname=$(ssh $osd_ip hostname)
    sudo ceph orch host drain $hostname --zap-osd-devices
done 10< $PROJ_DIR/configs/int_ip_addrs_server.txt

# # Function to check if the output contains "success"
# contains_osd() {
#     while IFS= read -r line; do
#         if [[ $line == *"osd"* ]]; then
#             echo "Found osd in the output"
#             return 1 # Return 1 (true) if "osd" is found
#         fi
#     done
#     return 0 # Return 0 (false) if "osd" is not found
# }

sleep 30

# Remove all osds
# while read -r -u10 ip
# do
#     hostname=$(ssh $ip hostname)
#     echo "Removing $hostname..."
#     while true; do
#         output=$(sudo ceph orch host rm $hostname 2>&1)
#         echo "$output"
#         contains_osd <<< "$output"
#         result=$?
#         echo "Result: $result"
#         # Check if the output contains "success"
#         # if [ $result -eq 1 ]; then
#         if  [ -n "$output" ]; then
#             echo "Waiting for all daemons to drain..."
#             sleep 10 # Wait for 10 second before trying again
#         else
#             echo "Successfully removed $hostname!"
#             break # Exit the loop if "success" is found
#         fi
#     done
# done 10< int_ip_addrs_server.txt

sleep 1

sudo ceph mgr module disable cephadm
# for all hosts
fsid=$(sudo ceph fsid)
echo $fsid
sudo cephadm rm-cluster --force --zap-osds --fsid $fsid

# ./tools/zap_osd.sh
# ./tools/clear_deb.sh

while read -r -u10 osd_ip
do
    ssh $osd_ip "cd draid && git pull"
    ssh $osd_ip "cd draid/deploy/tools && ./zap_osd.sh $fsid"
    ssh $osd_ip "cd draid/deploy/tools && ./clear_deb.sh"
done 10< $PROJ_DIR/configs/int_ip_addrs_server.txt

while read -r -u10 osd_ip
do
    ssh $osd_ip "cd draid && git pull"
    ssh $osd_ip "cd draid/deploy/tools && ./clear_deb.sh"
done 10< $PROJ_DIR/configs/int_ip_addrs_cli.txt