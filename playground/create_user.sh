# Create a user for rgw
mkdir -p ~/cephcluster/configs
sudo radosgw-admin user create --uid=chenhao --display-name="Chenhao Xu" --email=xv_chen_hao@163.com > ~/cephcluster/configs/user.json
sudo ceph orch ps --daemon_type rgw > ~/cephcluster/configs/rgw.txt

# Scp the configs to cli nodes
while read -r -u10 cli_ip
do
  scp -r ~/cephcluster/configs $cli_ip:~/cephcluster/
done 10< ~/cephcluster/deploy/int_ip_addrs_cli.txt
