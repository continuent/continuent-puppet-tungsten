puppet apply /mnt/base.pp --modulepath=/mnt/modules

service ssh start
service mysql start
sleep 120
dpkg -i /mnt/ct.deb
