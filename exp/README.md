# Experiment 

## Generate test settings

1. Run the script to generate the test settings

```bash
python gen_settings.py -n 5 -o default -r 1
```

## Automate Test suite
<!-- 1. Set the parms in `grid.py` and `create_default.rgw.buckets.data.sh` and then commit 

```bash
git commit -a -m "Update grid.py params"
``` -->

1. ssh to **the primary machine** and Run experiment on latency:

```bash
cd ~/draid/exp
git pull
python grid.py -c default -v -e enp65s0f0np0 -m rgw -d 4 -p 1
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

## Step by step test

1. ssh to **the primary machine** and Run experiment on latency:

```bash
cd ~/draid/exp
git pull
./setup.sh 20 10 10000 novar
```

## Note

<!-- - You need to check the PROGRAM variable in `sync_read.sh` before running the experiment. -->