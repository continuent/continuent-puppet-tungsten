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
class { 'continuent_install' :
      nodeHostName                => 'east-db1' ,
      nodeIpAddress               => "${::ipaddress}" ,
hostsFile                  => ["${::ipaddress},east-db1",'10.0.0.6,north-db1','10.0.0.7,north-db2','192.168.0.146,east-db2','192.168.0.147,west-db1','192.168.0.148,west-db2'],

      clusterData                => {
      east => { 'members' => 'east-db1,east-db2', 'connectors' => 'east-db1,east-db2', 'master' => 'east-db1' },
      west => { 'members' => 'west-db1,west-db2', 'connectors' => 'west-db1,west-db2', 'master' => 'west-db1' ,'relay-source'=> 'east'},
      west => { 'members' => 'north-db1,north-db2', 'connectors' => 'north-db1,north-db2', 'master' => 'north-db1' ,'relay-source'=> 'east'},
      } ,
      compositeName              => 'world' ,
      installMysql => true        ,
        installCluster            => true  ,
        installTungstenRepo => true,
        tungstenRepoHost    => 'yumtest.continuent.com',
        tungstenRepoIp      => '23.21.169.95'
}