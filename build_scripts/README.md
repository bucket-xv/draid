# Build Ceph packages from source

## Setup the Testbed

0. Copy the ip addresses to `ip_addr_host.txt`

1. Copy the ssh key to the build machine

```Bash
remote=$(head -n 1 ip_addr_host.txt)
scp ~/.ssh/id_ed25519 "BucketXv@$remote:~/.ssh/"
```

2. ssh to the build machine and clone the repository

```Bash
ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone git@github.com:bucket-xv/draid.git
cd ~/draid/build_scripts
```

3. Use `lsblk` and `fdisk` to find or create the disk to use for the testbed

```Bash
lsblk
sudo fdisk /dev/sd*
```

4. Run the script to install Ceph

```Bash
cd ~/draid/build_scripts
./setup.sh /dev/sd* /dev/sd* # provide 2 devices 
# you may need to enter yes once
```

5. Run the script to test the Ceph cluster

```Bash
tmux
./update.sh # this is for test issue
# ./update.sh; ./builddeb.sh
# ./update.sh; ./container.sh
```

5. Build ceph packages or container

```Bash
./builddeb.sh
./container.sh
```
