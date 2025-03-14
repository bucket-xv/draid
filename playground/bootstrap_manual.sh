uuid=$(uuidgen)
hostname=$(hostname -s)
ip-address=$(head -n 1 int_ip_addrs_server.txt)
cluster-name="ceph"

sudo touch /etc/ceph/ceph.conf
sudo chmod 644 /etc/ceph/ceph.conf
sudo echo "[global]
fsid = ${uuid}
mon_initial_members = ${hostname}
mon_host = ${ip-address}
mon_host = ${ip-address}
public_network = 127.0.0.0/0
" | sudo tee /etc/ceph/ceph.conf


sudo ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
sudo chown ceph:ceph /tmp/ceph.mon.keyring
monmaptool --create --add ${hostname} ${ip-address} --fsid ${uuid} /tmp/monmap
sudo mkdir /var/lib/ceph/mon/${cluster-name}-${hostname}
sudo -u ceph ceph-mon --mkfs -i ${hostname} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring


sudo systemctl start ceph-mon@${hostname}
sudo ceph -s