if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
        os="ubuntu"
    elif [[ "$ID" == "centos" ]]; then
        os="centos"
    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
else
    echo "Unable to determine the Linux distribution."
    exit 1
fi

cd ~/ceph/build
sudo ../src/stop.sh
sudo rm -rf out dev
# sudo ../src/cstart.sh
sudo systemctl start docker
sudo ../src/script/cpatch -t bucketxv/ceph:$os

sudo docker login -u bucketxv # Password at mubu
sudo docker push bucketxv/ceph:$os