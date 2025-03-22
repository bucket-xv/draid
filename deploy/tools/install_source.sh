export DRAID_DIR=$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")
cd $DRAID_DIR/deploy/tools
./install_docker.sh
cd ~
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.10 -y
git clone git@github.com:bucket-xv/cephdeb.git
cd ~/cephdeb
git pull
sudo dpkg -i *.deb
sudo apt --fix-broken install -y
rm -rf ~/cephdeb # clean up