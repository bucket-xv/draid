#!/bin/bash

# This script is used to configure the client nodes

release=0
while getopts "f" opt; do
  case $opt in
    f)
      release=1
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

while read -r -u10 cli_ip
do
    # Distribute SSH keys
    ssh -o StrictHostKeyChecking=no $cli_ip "echo Hello!"
    scp ~/.ssh/id_ed25519 "$cli_ip:~/.ssh/"
    sudo cat /etc/ceph/ceph.pub | ssh $cli_ip "sudo cat >> ~/.ssh/authorized_keys"
    sudo ssh -o StrictHostKeyChecking=no $cli_ip "echo Hello!"
    sudo ssh-copy-id -f -i /etc/ceph/ceph.pub root@$cli_ip

    # Pass ceph credentials
    sudo ssh root@$cli_ip "mkdir -p /etc/ceph"    
    sudo scp /etc/ceph/ceph.conf root@$cli_ip:/etc/ceph/ceph.conf
    sudo scp /etc/ceph/ceph.client.admin.keyring root@$cli_ip:/etc/ceph/ceph.client.admin.keyring
    
    # Install librados
    ssh $cli_ip "sudo apt update -y && ssh-keyscan github.com >> ~/.ssh/known_hosts"
    ssh $cli_ip "git clone git@github.com:bucket-xv/cephcluster; cd cephcluster && git pull"
    if [ $release -eq 1 ]; then
        ssh $cli_ip "cd cephcluster/deploy/tools && ./install_release.sh"
    else
        echo "Without release flag"
        ssh $cli_ip "cd cephcluster/deploy/tools && ./install_source.sh"
    fi
    ssh $cli_ip "sudo apt install pip -y && pip install boto3"

done 10< int_ip_addrs_cli.txt
