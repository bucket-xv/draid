#!/bin/bash

username=$1

# generate ip addresses from manifest, this is yet to be implemented

scp_to_machine() {
  # Check if an argument is provided
  if [ $# -eq 0 ]; then
    echo "No argument provided"
    return 1
  fi

  ip_addr=$1

  echo "scp manifests to $ip_addr"
  ssh -o StrictHostKeyChecking=no $username@$ip_addr "echo Hello!"
  cat ~/.ssh/id_ed25519.pub | ssh $username@$ip_addr "sudo tee -a /root/.ssh/authorized_keys"
  # Sync the existing keys
  scp ~/.ssh/id_ed25519_tmp "$username@$ip_addr:~/.ssh/id_ed25519"
  scp ~/.ssh/id_ed25519_tmp.pub "$username@$ip_addr:~/.ssh/id_ed25519.pub"
  # Add root key pairs
  ssh $username@$ip_addr "sudo cp ~/.ssh/id_ed25519 /root/.ssh/"
  ssh $username@$ip_addr "ssh-keyscan github.com >> ~/.ssh/known_hosts"
}

# this is to setup all nodes
while read -u10 -r line
do
  scp_to_machine "$line"
  ssh "$username@$line" "git clone --recurse-submodules git@github.com:bucket-xv/cephcluster.git"
  ssh "$username@$line" "cd cephcluster && git pull"
done 10< ip_addrs_all.txt


echo "You are all set!"

