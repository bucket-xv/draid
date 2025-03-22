#! /bin/bash

export DRAID_DIR=$(dirname "$(dirname $(realpath "$0"))")

# Function to upload a certain image to the registry
upload_image() {
    image_name=$1
    tmp_file_name=/tmp/$(basename "$image_name").zip
    docker pull $image_name
    echo "Saving $image_name to $tmp_file_name"
    docker save -o $tmp_file_name $image_name
    export server_ip=$(head -n 1 $DRAID_DIR/configs/ip_addrs_all.txt)
    export registry_ip=$(head -n 1 $DRAID_DIR/configs/int_ip_addrs_server.txt)
    scp $tmp_file_name $username@$server_ip:$tmp_file_name
    ssh $username@$server_ip "sudo docker load -i $tmp_file_name"
    ssh $username@$server_ip "sudo docker tag $image_name $registry_ip:5000/$image_name"
    ssh $username@$server_ip "sudo docker push $registry_ip:5000/$image_name"
}

username=$1
docker pull registry:2
docker save -o /tmp/registry.zip registry:2
export server_ip=$(head -n 1 $DRAID_DIR/configs/ip_addrs_all.txt)
scp /tmp/registry.zip $username@$server_ip:/tmp/registry.zip
ssh $username@$server_ip "sudo docker load -i /tmp/registry.zip"
ssh $username@$server_ip "sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2"

upload_image bucketxv/ceph:centos
upload_image alpine
upload_image registry:2