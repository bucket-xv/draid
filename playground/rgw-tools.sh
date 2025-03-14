# sudo radosgw-admin realm create --rgw-realm=default

# sudo radosgw-admin zone create --rgw-zone=ec-rgw
# sudo radosgw-admin zone get --rgw-zone=ec-rgw
# sudo radosgw-admin period update --commit

# sudo radosgw-admin zone set --rgw-zone=ec-rgw --infile ec-rgw.json
# sudo docker image pull quay.io/prometheus/node-exporter:v1.7.0
# sudo ceph config get mgr mgr/cephadm/container_image_node_exporter

sudo ceph health detail

sudo netstat -ntlp | grep 9100

sudo netstat -tulnp | grep :9100 | awk '{print $7}' | cut -d'/' -f1 | xargs sudo kill -9
sudo pkill -f 'ceph'
sudo systemctl list-unit-files --type=service --all | grep 'ceph' | while read -r line; do
    service_name=$(echo "$line" | cut -d' ' -f1)
    sudo systemctl disable "$service_name"
done

mkdir -p ~/cephcluster/configs
sudo radosgw-admin user create --uid=chenhao --display-name="Chenhao Xu" --email=xv_chen_hao@163.com > ~/cephcluster/configs/user.json
sudo ceph orch ps --daemon_type rgw > ~/cephcluster/configs/rgw.txt

sudo ceph osd pool ls

sudo ceph pg ls-by-pool default.rgw.buckets.data

ceph osd pool set default.rgw.buckets.data min_size 3 # k+1

# "Non-zero exit code 1 from /usr/bin/docker container inspect --format {{.State.Status}} ceph-0855d398-b2d3-11ef-8886-63c6435a48f4-node-exporter-node2
# /usr/bin/docker: stdout 
# /usr/bin/docker: stderr Error response from daemon: No such container: ceph-0855d398-b2d3-11ef-8886-63c6435a48f4-node-exporter-node2
# Non-zero exit code 1 from /usr/bin/docker container inspect --format {{.State.Status}} ceph-0855d398-b2d3-11ef-8886-63c6435a48f4-node-exporter.node2
# /usr/bin/docker: stdout 
# /usr/bin/docker: stderr Error response from daemon: No such container: ceph-0855d398-b2d3-11ef-8886-63c6435a48f4-node-exporter.node2
# Deploy daemon node-exporter.node2 ...
# Verifying port 0.0.0.0:9100 ...
# Cannot bind to IP 0.0.0.0 port 9100: [Errno 98] Address already in use
# ERROR: TCP Port(s) '0.0.0.0:9100' required for node-exporter already in use"

