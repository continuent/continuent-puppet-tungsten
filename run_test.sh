#!/bin/bash

if [ -z $1 ]
then
    echo 'Missing test name parameter'
    exit 1
fi

mkdir -p /etc/puppet/modules/continuent_tungsten/  > /dev/null
cp -r /tmp/* /etc/puppet/modules/continuent_tungsten/   > /dev/null

cd /etc/puppet/modules/continuent_tungsten/testing/classes
puppet apply test_setup.pp

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
        puppet apply $module
   done
fi

echo
echo '----------------------------------------------------------'
echo "--  RUNNING TEST $1                         "
echo '----------------------------------------------------------'
echo
puppet apply /etc/puppet/modules/continuent_tungsten/testing/tests/$1

 

    