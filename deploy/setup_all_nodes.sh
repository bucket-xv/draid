#!/bin/bash

PROJ_DIR=$(dirname "$(dirname $(realpath "$0"))")
username=$1

# generate ip addresses from manifest, this is yet to be implemented

setup_keys() {
  # Check if an argument is provided
  if [ $# -eq 0 ]; then
    echo "No argument provided"
    return 1
  fi

  ip_addr=$1

  echo "scp keys to $ip_addr"
  # ssh -o StrictHostKeyChecking=no $username@$ip_addr "echo Hello!"
  # Let the user visit without password
  cat ~/.ssh/id_ed25519.pub | ssh $username@$ip_addr "sudo tee -a /root/.ssh/authorized_keys"
  # Sync the server keys so that all servers can ssh to each other
  scp ~/.ssh/id_rsa_server "$username@$ip_addr:~/.ssh/id_rsa"
  scp ~/.ssh/id_rsa_server.pub "$username@$ip_addr:~/.ssh/id_rsa.pub"
  cat ~/.ssh/id_rsa_server.pub | ssh $username@$ip_addr "sudo tee -a /root/.ssh/authorized_keys"
  # Add private key to root user
  ssh $username@$ip_addr "sudo cp ~/.ssh/id_rsa /root/.ssh/"
  ssh $username@$ip_addr "ssh-keyscan github.com >> ~/.ssh/known_hosts"
}

# this is to setup all nodes
while read -u10 -r line
do
  setup_keys "$line"
  ssh "$username@$line" "git clone --recurse-submodules git@github.com:bucket-xv/draid.git"
  ssh "$username@$line" "cd draid && git pull && mkdir configs"
  scp -r ../configs $username@$line:~/draid/configs
done 10< $PROJ_DIR/configs/ip_addrs_all.txt

echo "You are all set!"

