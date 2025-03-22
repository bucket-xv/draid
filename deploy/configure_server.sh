# Copy the `id_ed25519` from user to root
DRAID_DIR=$(dirname "$(dirname $(realpath "$0"))")

# Distribute ssh keys
while read -r -u10 osd_ip
do
    echo "Distribute keys to $osd_ip"
    ssh -o StrictHostKeyChecking=no $osd_ip "echo Hello!"
    sudo cat /etc/ceph/ceph.pub | ssh $osd_ip "sudo cat >> ~/.ssh/authorized_keys"
    sudo ssh -o StrictHostKeyChecking=no $osd_ip "echo Hello!"
    sudo ssh-copy-id -f -i /etc/ceph/ceph.pub root@$osd_ip
done 10< $DRAID_DIR/configs/int_ip_addrs_server.txt

# Install
lines=$(tail -n +2 $DRAID_DIR/configs/int_ip_addrs_server.txt)
while read -r -u10 osd_ip
do
    echo "Configure server $osd_ip"
    # ssh $osd_ip "sudo mkdir -p /var/lib/ceph && sudo mkfs.ext4 /dev/sda4 && sudo mount -t auto -v /dev/sda4 /var/lib/ceph"
    ssh $osd_ip "sudo apt update && sudo apt install python-is-python3 iftop -y"
    ssh $osd_ip "cd $DRAID_DIR/deploy/tools && ./install_docker.sh"
    hostname=$(ssh $osd_ip hostname)
    sudo ceph orch host add $hostname $osd_ip
done 10<<< $lines
