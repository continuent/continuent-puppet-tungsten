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
class mysqlj_install {

      file { "/opt/mysql":
          ensure => "directory",
          owner  => "tungsten",
          group  => "tungsten",
          mode   => 750,
          require => User['tungsten']
      }


     exec { "download-mysqlj":
        cwd => "/opt/mysql",
        command => "/usr/bin/wget  ${::continuent_install::connectorJDownload}/mysql-connector-java-${::continuent_install::connectorJVersion}.tar.gz",
        creates => "/opt/mysql/mysql-connector-java-${::continuent_install::connectorJVersion}.tar.gz",
        require => [File['/opt/mysql'],Package['wget']]
      }

      exec { "install-mysqlj":
        cwd => "/opt/mysql",
        command => "/bin/tar xvzf /opt/mysql/mysql-connector-java-${::continuent_install::connectorJVersion}.tar.gz",
        creates => "/opt/mysql/mysql-connector-java-${::continuent_install::mysqlj_ver}",
        require =>  Exec["download-mysqlj"] ,
      }

}