sudo apt-get purge -y $(dpkg -l | grep -i 'ceph' | awk '{print$2}')
sudo apt-get purge -y $(dpkg -l | grep -i 'rbd' | awk '{print$2}')
sudo apt-get purge -y $(dpkg -l | grep -i 'rgw' | awk '{print$2}')
sudo apt-get purge -y $(dpkg -l | grep -i 'rados' | awk '{print$2}')
sudo apt-get autoremove -y