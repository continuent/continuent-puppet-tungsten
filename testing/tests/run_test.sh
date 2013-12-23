#!/bin/bash

if [ -z $1 ]
then
    echo 'Missing test name parameter'
    exit 1
fi

#mkdir -p /etc/puppet/modules/continuent_install/  > /dev/null
#cp -r /tmp/* /etc/puppet/modules/continuent_install/   > /dev/null





cd /vagrant/classes
sudo puppet apply test_setup.pp

#run any extra puppet classes to support testing
if [ ! -z "$2" ]
then
   IFS=', ' read -a array <<< "$2"
   for module in "${array[@]}"
   do
        module=$(echo "$module" | sed "s/,//g")
        echo
        echo "   ------ Applying test module $module  -------"
        echo
        sudo puppet apply $module
   done
fi

sudo puppet module install puppetlabs/stdlib
sudo puppet module install puppetlabs/ntp
sudo puppet module install puppetlabs/java
sudo puppet module install puppetlabs/firewall

echo
echo '----------------------------------------------------------'
echo "--  RUNNING TEST $1                         "
echo '----------------------------------------------------------'
echo
sudo puppet apply /vagrant/tests/$1

 

    