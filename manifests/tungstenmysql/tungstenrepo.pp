# == Class: tungsten::tungstenmysql::params See README.md for documentation.
#
# Copyright (C) 2014 Continuent, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.  You may obtain
# a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

class tungsten::tungstenmysql::tungstenrepo (
  $installPerconaRepo							    = false,
  $installMariaDBRepo   					    = false,
  $installMySQLRepo								    = false,
) {


  if $installPerconaRepo == true {
    class { 'percona_repo' : }
  }

 
  if $installMariaDBRepo != false {
    class { 'mariadb_repo' : version => $installMariaDBRepo }
  }

  if $installMySQLRepo != false {
      if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
          if ($operatingsystem =~ /(?i:amazon)/) {
            $url = "http://dev.mysql.com/get/mysql-community-release-el${epel_version}-5.noarch.rpm"
            $package="mysql-community-release-el${epel_version}-5.noarch.rpm"
          } else {

            $url = "http://dev.mysql.com/get/mysql-community-release-el${operatingsystemmajrelease}-5.noarch.rpm"
            $package="mysql-community-release-el${operatingsystemmajrelease}-5.noarch.rpm"
          }

          exec { 'download-repo-rpm':
            command => "/usr/bin/wget  $url",
            cwd => "/tmp",
            logoutput => "on_failure",
            creates => "/tmp/$package"
          } ->
          exec { 'install-repo-rpm':
            command => "/bin/rpm -i /tmp/$package",
            cwd => "/tmp",
            logoutput => "on_failure",
            creates => "/etc/yum.repos.d/mysql-community.repo"
          }
      } elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
        include apt

        apt::source { 'mysql':
          ensure => present,
          include_src => true,
          location => 'http://repo.mysql.com/apt/ubuntu/',
          release => $::lsbdistcodename,
          repos => 'mysql-$version',
        }
      } else {
        fail("The ${module_name} module is not supported on an ${::operatingsystem} based system.")
      }
  }
}
