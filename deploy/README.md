# draid Deployment

This folder is used to deploy a experimental draid on the cloudlab machines.

## Setup the Testbed

Note: 1~3 are executed locally, while 4~5 are executed on the **master node**.

1. Make sure your current directory is `draid/`. Create empty config files first.

```bash
mkdir configs
cd configs
touch int_ip_addrs_cli.txt
touch int_ip_addrs_server.txt
touch ip_addrs_all.txt
touch ceph.conf
```

Put all public ip addresses in `ip_addrs_all.txt` for easy setup, put all private ip addresses that composes a Ceph cluster in order in `int_ip_addrs_server.txt`, and put all private ip addresses that you want to access the Ceph cluster in `int_ip_addrs_cli.txt`. Change the network netmask in `ceph.conf` (private network recommended) to the one of your network.

You can find the example of the config files in `examples/configs`.

2. Copy the manifest to manifest.xml and execute the following command:

```Bash
cd deploy
./setup_all_nodes.sh root
```

3. Upload the docker image to remote:

```bash
./upload.sh root
```

4. SSH to the **master node** and run the script to install draid. You may need to enter `Yes` once.

```Bash
tmux
cd draid/deploy
./deploy_source.sh 3 /dev/sd* # <the number of osd servers> <the osd disk>
```

5. (Optional) Destoy the testbed

```Bash
./destroy.sh
```

## Note

The key difference between the `deploy_source.sh` and `deploy_release.sh` are
- `deploy_source.sh` is used to deploy from the development source code while `deploy_release.sh` is used to deploy from the release package
- `deploy_source.sh` uses wholely the cluster network interface while `deploy_release.sh` uses the public network interface