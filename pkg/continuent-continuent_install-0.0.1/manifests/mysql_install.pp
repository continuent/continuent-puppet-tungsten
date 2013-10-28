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
class mysql_install {


  if ($operatingsystem =~ /(?i:centos|redhat|oel)/) {
    package { 'mysql-server': ensure => present, require => [File["/etc/hostname"],File['/etc/my.cnf']], }
    package { 'mysql': ensure => present, require => Package["mysql-server"], }
  }

  service { $::continuent_install::mysqlServiceName :
      enable => true,
      ensure => running,
      require => [File['/etc/my.cnf']],
  }

  file { "my.cnf":
    path    => "/etc/my.cnf",
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("continuent_install/my.erb"),

  }
  
}