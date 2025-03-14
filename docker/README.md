# Using this repository as a private docker registry backend

## Deploy a private docker registry without Ceph rgw

1. Follow the first step in `deploy/README.md` to distribute keys.

2. Then execute on your **local machine**:
```bash
cd ../docker
./distribute_repo.sh <Username> # Username is used to ssh to remote machines
```

## Deploy a private docker registry with Ceph rgw

1. Follow `deploy/README.md`.

2. Then execute on your **local machine**:
```bash
cd ../docker
./distribute_repo.sh <Username> # Username is used to ssh to remote machines
```

3. Execute the following command(on the mon node):

```Bash
cd ~/draid/docker
./cluster.sh <k> <m> # k denotes the number of data chunks and m denotes the number of parity chunks
``` 

4. Then ssh to the last rgw server(possibly the only) to deploy registry on it:

```Bash
cd ~/draid/docker
./start_registry.sh
```

5. Add whatever image you want to that registry:

```Bash
cd ~/draid/docker
./push_to_registry.sh <ImageName> # ImageName is the name of the image you want to push to the registry
```

## Experiment with the private docker registry

### Generate test settings

1. Run the script to generate the test settings

```bash
python gen_settings.py -n 4 -o default -r 1
```

### Automate Test suite

1. ssh to **the primary machine** and Run experiment on latency:

```bash
cd ~/draid/docker
git pull
python grid.py -c default -v -e enp65s0f0np0 -d 3 -p 1
```

2. Get the results:

```bash
remote=$(head -n 1 deploy/ip_addr_host.txt)
scp -r BucketXv@$remote:~/draid/logs save_logs/
```

3. Analyze the results:

```bash
python plot.py -i bottleneck
```
