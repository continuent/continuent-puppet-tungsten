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
class mysql_config {

  $port=$::continuent_install::mysqlPort

  exec { "set-mysql-password":
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $::continuent_install::masterPassword",
    require => Service[$::continuent_install::mysqlServiceName],
    onlyif  => ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u root"]
  }
  
  $sqlCheck="select * from mysql.user where user='$::continuent_install::int_replicationUser'"
  $sqlExec="grant all on *.* to $::continuent_install::int_replicationUser identified by '$::continuent_install::int_replicationPassword' with grant option;"
  exec { "create-tungsten-user":
      onlyif  => ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlCheck\"|wc -l"],
      command => "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlExec\" ",
      require => Exec['set-mysql-password'],
  
  }
  
  $sqlCheck2="select * from mysql.user where user='$::continuent_install::int_appUser'"
  $sqlExec2 ="grant all privileges on *.* to $::continuent_install::int_appUser
            identified by '$::continuent_install::int_appPassword';revoke super on *.* from $::continuent_install::int_appUser"

  exec { "create-application-user":
      onlyif  => ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlCheck\"|wc -l"],
      command => "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlExec2\"",
      require => Exec['set-mysql-password'],
  
  }
  
  $sqlCheck3="select * from mysql.user where user=''"
  $sqlExec3="delete from mysql.user where user='';flush privileges;"
   exec { "remove-anon-users":
      onlyif  => ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlCheck\"|wc -l"],
      command => "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlExec3\"",
      require => Exec['set-mysql-password'],
  
  }


}
