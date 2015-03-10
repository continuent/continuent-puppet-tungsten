puppet apply /mnt/base.pp --modulepath=/mnt/modules

service ssh start
service mysql start
dpkg -i /mnt/ct.deb
