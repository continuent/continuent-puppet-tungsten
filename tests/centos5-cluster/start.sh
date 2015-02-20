puppet apply /mnt/base.pp --modulepath=/mnt/modules

service sshd start
service mysql start

rpm -i /mnt/rpm/ct.rhel5.rpm
