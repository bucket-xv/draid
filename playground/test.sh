TRAFFIC_MONITOR="cd ~/cephcluster/exp/tools && sudo ./monitor_network.sh"
REMOTE_TRAFFIC_CSV="/tmp/10.10.1.1_traffic.csv"

cd ~/cephcluster/exp/tools
sudo ./monitor_network.sh $interface 2>/dev/null >$REMOTE_TRAFFIC_CSV </dev/null &