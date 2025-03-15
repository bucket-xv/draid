#! /bin/bash

# Function to upload a certain image to the registry
upload_image() {
    image_name=$1
    docker pull $image_name
    docker save -o /tmp/$image_name.zip $image_name
    export server_ip=$(head -n 1 configs/ip_addrs_all.txt)
    export registry_ip=$(head -n 1 configs/int_ip_addrs_server.txt)
    scp /tmp/$image_name.zip root@$server_ip:/tmp/$image_name.zip
    ssh root@$server_ip "docker load -i /tmp/$image_name.zip"
    ssh root@$server_ip "docker tag $image_name $registry_ip:5000/$image_name"
    ssh root@$server_ip "docker push $registry_ip:5000/$image_name"
}

# upload_image bucketxv/ceph:centos
upload_image alpine:latest
upload_image registry:2