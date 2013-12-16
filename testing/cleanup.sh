#!/bin/bash
set -ex

WORKSPACE=$1
cd $WORKSPACE/continuent-vagrant
vagrant destroy -f
