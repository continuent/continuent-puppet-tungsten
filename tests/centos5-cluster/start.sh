puppet apply /mnt/base.pp --modulepath=/mnt/modules

service sshd start
service mysql start
hc=$(cat /etc/hosts | grep 172 | grep -v `hostname`|wc -l)
if [ "$hc" -gt "0" ]; then
  for h in $(cat /etc/hosts | grep 172 | grep -v `hostname`| cut -f2); do
    sudo -u tungsten scp -o StrictHostKeyChecking=no /etc/hosts $h:/tmp/hosts
    sudo -u tungsten ssh $h "sudo cp /tmp/hosts /etc"
   done
fi
rpm -i /mnt/rpm/ct.rhel5.rpm