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
class tungsten_config {

   file { "10_tungsten":
       path    => "/etc/sudoers.d/10_tungsten",
       ensure  => present,
       owner   => "root",
       group   => "root",
       mode    => 0440,
       replace => true,
       require => Package[sudo],
       content => "tungsten ALL=(ALL) NOPASSWD: ALL";
   }

   exec { "remove-requiretty":
      command => "/bin/sed -i  '/requiretty/s/^/#/'  /etc/sudoers",
      require => Package[sudo],
   }
          
   file { '/etc/security/limits.d/10tungsten.conf':
      ensure => file,
      content => template('continuent_install/security.limits.conf.erb'),
   }

   
   file { "/opt/continuent":
        ensure => "directory",
        owner  => "tungsten",
        group  => "tungsten",
        mode   => 750,
        require => User['tungsten']
   }

   package {'java-1.6.0-openjdk': ensure => present, }
   package {'ruby': ensure => present, }
   package {'wget': ensure => present, }
   package {'sudo': ensure => present, }
   package {'rsync': ensure => present, }

  if $::continuent_install::installTungstenRepo == true {
   package {'percona-xtrabackup': ensure => present,require => [File['tungsten.repo'],Host[$::continuent_install::tungstenRepoHost]] }
  }
#  else {
#     package {'percona-xtrabackup': ensure => present, }
#  }

    $port=$::continuent_install::mysqlPort

    $sqlCheck="select * from mysql.user where user='$::continuent_install::int_replicationUser'"
    $sqlExec="grant all on *.* to $::continuent_install::int_replicationUser identified by '$::continuent_install::int_replicationPassword' with grant option;"

    if   $::continuent_install::installMysql == true {
      exec { "create-tungsten-user":
        onlyif  => ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlCheck\"|wc -l"],
        command => "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlExec\" ",
        require => Exec['set-mysql-password'],
      }
    } else {
      exec { "create-tungsten-user":
        onlyif  => ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlCheck\"|wc -l"],
        command => "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlExec\" ",
      }
    }

    $sqlCheck2="select * from mysql.user where user='$::continuent_install::int_appUser'"
    $sqlExec2 ="grant all privileges on *.* to $::continuent_install::int_appUser
                identified by '$::continuent_install::int_appPassword';revoke super on *.* from $::continuent_install::int_appUser"

    exec { "create-application-user":
      onlyif  => ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlCheck\"|wc -l"],
      command => "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlExec2\"",
      require => Exec['create-tungsten-user'],

    }
}
