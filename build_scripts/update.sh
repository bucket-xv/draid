#!/bin/bash
git pull

cd ~/ceph
git pull
git submodule update --recursive --init

cd build
sudo ../src/stop.sh
sudo rm -rf out dev
sudo ninja -j $(nproc)
sudo ninja install -j $(nproc)
sudo ninja vstart -j $(nproc)
sudo env MON=1 OSD=4 ../src/vstart.sh -n -d
sudo bin/ceph osd erasure-code-profile set ecprofile \
    k=3 \
    m=1
sudo bin/ceph osd pool create default.rgw.buckets.data erasure ecprofile
# sudo bin/ceph osd pool create pool
sudo bin/ceph osd set-require-min-compat-client reef
sudo bin/ceph balancer off
sudo bin/ceph balancer mode upmap-read

# sudo bin/ceph osd getmap -o om
# sudo bin/osdmaptool om --upmap out.txt
# sudo bin/osdmaptool om --vstart --read out.txt --read-pool default.rgw.buckets.data

# sudo bin/ceph balancer eval-verbose

sudo bin/ceph tell mon.* config set debug_mgr 10
sudo bin/ceph tell mon.* config set debug_osd 10
sudo bin/ceph tell mgr.* config set debug_mgr 10
sudo bin/ceph tell mgr.* config set debug_osd 10

