cd ~/ceph/build
sudo ../src/stop.sh
sudo rm -rf out dev

# sudo yum install debhelper
git clone git@github.com:bucket-xv/cephdeb.git ~/cephdeb
cd ~/cephdeb
git pull
cd ~/ceph
# Get the number of available processors
num_processors=$(nproc)
num_jobs=$((num_processors * 2))
sudo dpkg-buildpackage -j$num_jobs
sudo rm ~/cephdeb/*.deb --force
find ~ -type f -name "*.deb" ! -name "*dbg*" -exec mv {} ~/cephdeb \;
sudo rm ~/*.deb --force
cd ~/cephdeb
git add --all
git commit -m "update"
git push
# ./make-dist