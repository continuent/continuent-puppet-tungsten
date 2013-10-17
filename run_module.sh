#!/bin/bash
# === Copyright
#
# Copyright 2013 Continuent Inc.
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#Similar to run_test.sh but assumes the module is already installed

if [ -z $1 ]
then
    echo 'Missing test name parameter'
    exit 1
fi

cd /etc/puppet/modules/continuent_install/testing/classes
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
echo "--  RUNNING MODULE $1                         "
echo '----------------------------------------------------------'
echo
puppet apply $1

 

    