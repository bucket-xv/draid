# draid Deployment

This folder is used to deploy a experimental draid on the cloudlab machines.

## Setup the Testbed

1. Copy the manifest to manifest.xml and execute the following command:

```Bash
cd deploy-aliyun
python parse_manifest.py manifest.xml 5 # The figure denotes the number of ceph cluster servers.
git commit -a -m "Change ip"
git push
./setup_all_nodes.sh root
```

2. ssh to moniter server (First server in `ip_addrs_all.txt`) and execute the following command:

```Bash
tmux

ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone --recurse-submodules git@github.com:bucket-xv/draid.git
cd draid/deploy
```

3. Use `lsblk` and `fdisk` to find or create the disk to use for the testbed

```Bash
lsblk
sudo fdisk /dev/sd*
```

4. Run the script to install draid. You may need to enter `Yes` once.

```Bash
# ./deploy_source.sh /dev/sda4 4 /dev/sdb
./deploy_source.sh /dev/sd* 4 /dev/sd* # <the log disk> <the number of osd servers> <the osd disk>
```


5. Destoy the testbed

```Bash
cd ~/draid/deploy
./destroy.sh
```


## Note

The key difference between the `deploy_source.sh` and `deploy_release.sh` are
- `deploy_source.sh` is used to deploy from the development source code while `deploy_release.sh` is used to deploy from the release package
- `deploy_source.sh` uses wholely the cluster network interface while `deploy_release.sh` uses the public network interface