#!/bin/bash


#set -ex
set -e
cd `dirname $0`
TEST_HOME=$PWD
TEST_DIR=$TEST_HOME/work

if [ -d $TEST_DIR ]
then
    rm -rf $TEST_DIR
fi

mkdir $TEST_DIR

function cleanup {
	cd $TEST_DIR
	if [ $RC -eq 0 ]
	then
	    echo 'Destroying Vagrant Boxs'
	    ./cleanup.sh $TEST_DIR
	fi
}
trap cleanup EXIT

cp Vagrantfile $TEST_DIR
cp tests/$1 $TEST_DIR/default.pp
cp cleanup.sh $TEST_DIR

./init.sh $TEST_DIR


echo 'Testing Vagrant Boxes'
cd $TEST_DIR/continuent-vagrant
RC=0
HOSTS=`vagrant status | grep '^db*' | grep running | awk -F" " '{print $1}'`
for i in $HOSTS
do
	 vagrant ssh $i -c 'sudo -u tungsten /opt/continuent/tungsten/cluster-home/bin/check_tungsten_online'
	if [ "$?" != "0" ]
	then
		RC=1
	fi
done

exit $RC
