# Using this repository as a private docker registry backend

<!--## Deploy a private docker registry with Ceph rgw

1. Then execute on your **local machine**:
```bash
cd ../docker
./sync_repo.sh <Username> # Username is used to ssh to remote machines
```

2. Execute the following command on **the mon node**:

```Bash
cd draid/docker
./cluster.sh <k> <m> # k denotes the number of data chunks and m denotes the number of parity chunks
``` 

3. Then ssh to the last **rgw node**(possibly the only one) to deploy registry on it:

```Bash
cd draid/docker
./start_registry.sh
```

 4. Add whatever image you want to that registry:

```Bash
cd draid/docker
./push_to_registry.sh <ImageName> # ImageName is the name of the image you want to push to the registry
``` -->

## Experiment with the private docker registry

<!-- ### Generate test settings

1. Run the script to generate the test settings on **your local machine**:

```bash
python gen_settings.py -n 3 -o default -r 1
``` -->

### Automate Test suite

Note: You need to setup once each time before running the test.

The setup time is around 2 minutes and the test time is around 1 minutes.

1. Run the script to setup the test environment on **mon node**. Use `-v` to print the verbose output.

```bash
python grid-simple.py -c single2 -e eth0 -d 2 -p 1 -m setup
```

2. Run the script to run the test on **all nodes**. Use `-v` to print the verbose output.

```bash
python grid-simple.py -c single2 -e eth0 -d 2 -p 1 -m run
```

<!-- 1. ssh to **the mon node** and Run experiment on latency:

```bash
git pull
python grid.py -c default -v -e eth0 -d 2 -p 1
```

2. Get the results to your **local machine**:

```bash
remote=$(head -n 1 configs/ip_addrs_all.txt)
scp -r root@$remote:<DRAID_DIR>/logs save_logs/
```

3. Analyze the results:

```bash
python plot.py -i bottleneck
``` -->
