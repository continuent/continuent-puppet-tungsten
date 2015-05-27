puppet apply /mnt/base.pp --modulepath=/mnt/modules

service sshd start
service mysql start
sleep 600
rpm -i /mnt/rpm/ct.rpm
