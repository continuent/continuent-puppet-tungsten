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
  hostsFile                  => ["192.168.11.101 db1.vagrant",'192.168.11.102 db2.vagrant','192.168.11.103 db3.vagrant'],

  clusterData                => {
  east => { 'members' => 'db1.vagrant,db2.vagrant,db3.vagrant', 'connectors' => 'db1.vagrant,db2.vagrant', 'master' => 'db1.vagrant' },
  } ,
  installSSHKeys => true,
  installMysql => true        ,
  skipHostConfig => true,
  installClusterSoftware            => "/vagrant/ct.rpm"
}
