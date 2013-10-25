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
class tungsten_install {

    file { "/etc/tungsten":
      ensure => "directory",
      owner  => "root",
      group  => "root",
      mode   => 750,
    }


    file { "tungsten.ini":
      path    => "/etc/tungsten/tungsten.ini",
      owner => root,
      group => root,
      mode => 644,
      content => template("continuent_install/tungsten.erb"),
      require => File["/etc/tungsten"],
    }



    if  $::continuent_install::installMysql == true {
      if  $::continuent_install::installMysqlj == true {
          $req= [File ["tungsten.ini"],Class['mysql_config'],Exec['install-mysqlj'],Class['tungsten_config'],Class['tungsten_hosts'],Class['unix_user']]
      }
      else {
          $req= [File ["tungsten.ini"],Class['mysql_config'],Class['tungsten_config'],Class['tungsten_hosts'],Class['unix_user']]
      }
    }
    else {
      if  $::continuent_install::installMysqlj == true {
          $req= [File ["tungsten.ini"],Exec['install-mysqlj'],Class['tungsten_config'],Class['tungsten_hosts'],Class['unix_user']]
      }
      else {
          $req= [File ["tungsten.ini"],Class['tungsten_config'],Class['tungsten_hosts'],Class['unix_user']]
      }
    }

    package { 'continuent-tungsten':
      ensure => present,
      require => [$req]
    }

    
}
