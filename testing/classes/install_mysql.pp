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

if ($operatingsystem =~ /(?i:centos|redhat|oel)/) {
      package { 'mysql-server': ensure => present, require => [File['/etc/my.cnf']], }
      package { 'mysql': ensure => present, require => Package["mysql-server"], }


      service { mysqld :
        enable => true,
        ensure => running,
        require => [File['/etc/my.cnf'],Package['mysql-server']],
      }

      file { "my.cnf":
        path    => "/etc/my.cnf",
        owner   => root,
        group   => root,
        mode    => 644,
        content => template("/etc/puppet/modules/continuent_install/testing/classes/templates/my.erb"),

      }
    $ServiceName=mysqld
}


$port=13306
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
