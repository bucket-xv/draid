dev1=$1
dev2=$2
sudo mkfs.ext4 $dev1
sudo mkdir /tmp
sudo mount $dev1 /tmp
sudo chmod 777 /tmp

sudo mkfs.ext4 $dev2
mkdir ~/ceph
sudo mount $dev2 ~/ceph
sudo chown BucketXv ~/ceph
sudo rm -rf ~/ceph

if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
        pkt="apt"
        sudo apt-get update -y
        sudo apt install docker.io -y
    elif [[ "$ID" == "centos" ]]; then
        sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum update -y
        sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        pkt="yum"
    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
else
    echo "Unable to determine the Linux distribution."
    exit 1
fi

cd ~
git clone git@github.com:bucket-xv/ceph.git ceph
cd ceph
# git checkout squid-ecread
git checkout ecread-tx
git pull
git submodule update --init --recursive --progress
sudo $pkt install tmux -y
sudo $pkt install curl python3-routes -y
./install-deps.sh
./do_cmake.sh
cd ~/cephcluster/build_scripts