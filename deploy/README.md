# draid Deployment

This folder is used to deploy an experimental draid on the aliyun machines.

## Setup the Testbed

Note: 1\~3 are executed locally, while 4\~5 are executed on the **master node**.

### 1. Make sure your current directory is `draid/`. Create empty config files first.

```bash
mkdir configs
cd configs
touch int_ip_addrs_cli.txt
touch int_ip_addrs_server.txt
touch ip_addrs_all.txt
touch ceph.conf
```

- Put all public IP addresses in `ip_addrs_all.txt` for easy setup.
- Put all private IP addresses that compose a Ceph cluster in order in `int_ip_addrs_server.txt`. This should be in the same order as in `ip_addrs_all.txt`.
- Put all private IP addresses you want to access the Ceph cluster in `int_ip_addrs_cli.txt`.
- Note that an empty line after the last ip address is needed for the above three files.
- Change the network netmask in `ceph.conf` (private network recommended) to the one of your network.

**You can find the example of the config files in `examples/configs`.**

### 2. Execute the following command:

```Bash
cd deploy
./setup_all_nodes.sh root # root is your username on the aliyun machines
```

### 3. Upload the docker image to the remote. Note that you should have docker installed and running locally:

```bash
./upload.sh root
```

### 4. SSH to the **master node** and run the script to install draid. You may need to enter `Yes` once.

```Bash
tmux # This process needs time, so take a tmux in case the connection is broken.
cd draid/deploy
./deploy_source.sh 3 /dev/sd* # <the number of osd servers> <the osd disk>
```

### 5. Check that Ceph cluster is working.

Run the following command on the **master node**. 

```Bash
sudo ceph -s
```

You should see the output like this:

```Bash
cluster:
    id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    health: HEALTH_OK / HEALTH_WARN
...
```

## (Caution!) Destroy the testbed

```Bash
./destroy.sh
```
