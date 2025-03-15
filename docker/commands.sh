export DRAID_DIR=$(dirname "$(dirname "$(realpath "$0")")")

# Show ceph cluster status
sudo ceph balancer eval default.rgw.buckets.data
sudo ceph pg ls-by-pool default.rgw.buckets.data
sudo ceph pg ls-by-pool default.rgw.buckets.data | python $DRAID_DIR/docker/tools/info.py
sudo ceph orch ps 
sudo ceph device ls
sudo ceph osd pool ls
sudo rados df

for i in $(seq 0 50); do
    sudo rados -p default.rgw.buckets.data put object$i $DRAID_DIR/data/0.txt
    echo "Put object$i"
done

for i in $(seq 0 50); do
    sudo rados -p default.rgw.buckets.data rm object$i
    echo "Remove object$i"
done

sudo ceph osd primary-affinity 1 1

sudo ceph balancer optimize plan
sudo ceph balancer show plan
sudo ceph balancer execute plan

sudo ceph pg ls-by-pool default.rgw.buckets.data | python $DRAID_DIR/docker/tools/info.py

sudo apt install iftop -y
sudo iftop -i *
lsblk -d -o name,rota

# Get dashboard
sudo cat /var/log/ceph/cephadm.log | grep -A 5 "Ceph Dashboard is now available at"

# Delete disks
sudo pvremove /dev/sdb
sudo vgremove
sudo wipefs -af /dev/

# rgw
sudo radosgw-admin bucket list
sudo radosgw-admin user info --uid=chenhao

sudo ceph orch rm rgw.foo

# progess
sudo ceph progress clear

# Test fix
sudo radosgw-admin zonegroup placement add --rgw-zonegroup default --placement-id default-placement --storage-class STANDARD_IA
sudo radosgw-admin zone placement add --rgw-zone default   --placement-id default-placement --storage-class STANDARD_IA   --data-pool default.rgw.glacier.data

sudo radosgw-admin user modify \
      --uid chenhao \
      --placement-id default-placement \
      --storage-class STANDARD_IA
sudo ceph osd pool application enable default.rgw.buckets.data rgw