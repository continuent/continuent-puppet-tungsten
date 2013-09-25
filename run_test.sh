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
   puppet apply $2
fi

puppet apply /etc/puppet/modules/continuent_tungsten/testing/tests/$1

 

    