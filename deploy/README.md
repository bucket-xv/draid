# draid Deployment

This folder is used to deploy a experimental draid on the cloudlab machines.

## Setup the Testbed

1. Make sure your current directory is `draid/`. Create empty config files first.

```bash
mkdir configs
cd configs
touch int_ip_addrs_cli.txt
touch int_ip_addrs_server.txt
touch ip_addrs_all.txt
touch ceph.conf
```

Put all public ip addresses in `ip_addrs_all.txt` for eay setup, put all private ip addresses that composes a Ceph cluster in order in `int_ip_addrs_server.txt`, and put all private ip addresses that you want to access the Ceph cluster in `int_ip_addrs_cli.txt`. Config `ceph.conf`.

2. Copy the manifest to manifest.xml and execute the following command:

```Bash
cd deploy
./setup_all_nodes.sh root
```

3. Upload the docker image to remote:

```bash
docker pull registry:2
docker save -o /tmp/registry.zip registry:2
export server_ip=$(head -n 1 configs/ip_addrs_all.txt)
export server_ip2=$(tail -n 1 configs/ip_addrs_all.txt)
scp /tmp/registry.zip root@$server_ip:/tmp/registry.zip
scp /tmp/registry.zip root@$server_ip2:/tmp/registry.zip
ssh root@$server_ip "docker load -i /tmp/registry.zip"
ssh root@$server_ip "docker run -d -p 5000:5000 --restart=always --name registry registry:2"
ssh root@$server_ip2 "docker load -i /tmp/registry.zip"


docker pull docker.io/bucketxv/ceph:centos
docker save -o /tmp/ceph.zip docker.io/bucketxv/ceph:centos
export server_ip=$(head -n 1 configs/ip_addrs_all.txt)
export registry_ip=$(head -n 1 configs/int_ip_addrs_server.txt)
scp /tmp/ceph.zip root@$server_ip:/tmp/ceph.zip
ssh root@$server_ip "docker load -i /tmp/ceph.zip"
ssh root@$server_ip "docker tag docker.io/bucketxv/ceph:centos $registry_ip:5000/ceph:centos"
ssh root@$server_ip "docker push $registry_ip:5000/ceph:centos"
```

4. Run the script to install draid. You may need to enter `Yes` once.

```Bash
tmux
# ./deploy_source.sh /dev/sda4 4 /dev/sdb
./deploy_source.sh 3 /dev/sd* # <the log disk> <the number of osd servers> <the osd disk>
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