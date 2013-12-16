#!/bin/bash
set -ex

WORKSPACE=$1

cd $WORKSPACE
if [ ! -d continuent-vagrant ]
then
	git clone https://github.com/continuent/continuent-vagrant.git continuent-vagrant
	cd $WORKSPACE/continuent-vagrant
	git submodule update --init
fi
cd $WORKSPACE/continuent-vagrant

# Clear out any old vagrant instances but it's ok if this fails
set +ex
vagrant destroy -f
set -ex

cp $1/Vagrantfile .
cp $1/default.pp ./manifests
./launch.sh
