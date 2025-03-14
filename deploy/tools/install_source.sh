cd ~
sudo apt install containerd docker.io software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.10 -y
git clone git@github.com:bucket-xv/cephdeb.git
cd ~/cephdeb
git pull
sudo dpkg -i *.deb
sudo apt --fix-broken install -y