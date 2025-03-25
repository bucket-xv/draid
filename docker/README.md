# Using this repository as a private docker registry backend

## Experiment with the private docker registry

Note: You need to setup once each time before running the test.

**The setup time is around 2 minutes and the test time is around 1 minutes.**

1. Run the script to setup the test environment on **master node**. Use `-v` to print the verbose output.

```bash
python grid-simple.py -c single2 -e eth0 -d 2 -p 1 -m setup
```

2. Run the script to run the test. Use `-v` to print the verbose output.

```bash
python grid-simple.py -c single2 -e eth0 -d 2 -p 1 -m run
```

## Deploy a private docker registry with Ceph rgw

1. Run the script to setup the test environment on **master node**. Use `-v` to print the verbose output.
```bash
python grid-simple.py -c common -e eth0 -d 2 -p 1 -m setup
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
