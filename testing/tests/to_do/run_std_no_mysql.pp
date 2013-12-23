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


package { 'mysql-server': ensure => present, require => [File['/etc/my.cnf']], }
package { 'mysql': ensure => present, require => Package["mysql-server"], }

$ServiceName=mysqld


service { mysqld :
enable => true,
ensure => running,
require => [File['/etc/my.cnf'],Package['mysql-server']],
}

$port=13306

file { "my.cnf":
path    => "/etc/my.cnf",
owner   => root,
group   => root,
mode    => 644,
content => "[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
symbolic-links=0
default-storage-engine=innodb
pid-file=/var/lib/mysql/mysql.pid

log-bin=mysql-bin
sync_binlog=1
max_allowed_packet=52m
open_files_limit=65535

server-id=1,
port=$port"

}




$masterUser='tungsten'
$masterPassword='secret'
$appUser='app_user'
$appPassword='secret'

exec { "set-mysql-password":
path => ["/bin", "/usr/bin"],
command => "mysqladmin -uroot password $masterPassword",
require => Service[$ServiceName],
onlyif  => "mysql -u root"
}

$sqlCheck="select * from mysql.user where user='$masterUser'"
$sqlExec="grant all on *.* to $masterUser identified by '$masterPassword' with grant option;"
exec { "create-tungsten-user":
  onlyif  => "/usr/bin/mysql -u root -p$masterPassword -P $port -Be \"$sqlCheck\"|wc -l",
  command => "/usr/bin/mysql -u root -p$masterPassword -P $port -Be \"$sqlExec\" ",
  require => Exec['set-mysql-password'],

}

$sqlCheck2="select * from mysql.user where user='$appUser'"
$sqlExec2 ="grant all privileges on *.* to $appUser
            identified by '$appPassword';revoke super on *.* from $appUser"

exec { "create-application-user":
  onlyif  => "/usr/bin/mysql -u root -p$masterPassword -P $port -Be \"$sqlCheck2\"|wc -l",
  command => "/usr/bin/mysql -u root -p$masterPassword -P $port -Be \"$sqlExec2\"",
  require => Exec['set-mysql-password'],

}

$sqlCheck3="select * from mysql.user where user=''"
$sqlExec3="delete from mysql.user where user='';flush privileges;"
exec { "remove-anon-users":
  onlyif  => "/usr/bin/mysql -u root -p$masterPassword -P $port -Be \"$sqlCheck3\"|wc -l",
  command => "/usr/bin/mysql -u root -p$masterPassword -P $port -Be \"$sqlExec3\"",
  require => Exec['set-mysql-password'],

}


file {"/etc/yum.repos.d/tungsten.repo":
  ensure => file,
  mode => 777,
  owner   => root,
  group   => root,
  content => '[tungsten]
name=Centos local Repo
baseurl=http://yumtest.continuent.com/
enabled=1
gpgcheck=0',
}

host { 'yumtest.continuent.com':
  ip => '23.21.169.95',
}


class { 'continuent_install' :
  hostsFile                  => ["192.168.11.101 db1",'192.168.11.102 db2','192.168.11.103 db3','192.168.11.104 db4'],

  clusterData                => {
  east => { 'members' => 'db1,db2,db3,db4', 'connectors' => 'db1,db2', 'master' => 'db1' },
  } ,
  installSSHKeys => true,
  installMysql => false       ,
  installClusterSoftware            => true
}
