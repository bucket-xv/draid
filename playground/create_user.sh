# Create a user for rgw
mkdir -p ~/draid/configs
sudo radosgw-admin user create --uid=chenhao --display-name="Chenhao Xu" --email=xv_chen_hao@163.com > ~/draid/configs/user.json
sudo ceph orch ps --daemon_type rgw > ~/draid/configs/rgw.txt

# Scp the configs to cli nodes
while read -r -u10 cli_ip
do
  scp -r ~/draid/configs $cli_ip:~/draid/
done 10< ~/draid/deploy/int_ip_addrs_cli.txt
