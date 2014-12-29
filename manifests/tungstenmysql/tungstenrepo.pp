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
  $mySQLBuild 							    = false,
  $mySQLVersion       			    = false
) {

  if ($mySQLBuild !~ /(?i:percona|mariadb|mysql|native)/) {
    fail("The $mySQLBuild is not supported by this module")
  }

  if ($mySQLBuild  =~ /(?i:percona)/) {
    if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
      if ($operatingsystem =~ /(?i:amazon)/) {
        $baseurl = "http://repo.percona.com/centos/${epel_version}/os/\$basearch/"
      } else {
        $baseurl = 'http://repo.percona.com/centos/$releasever/os/$basearch/'
      }

      yumrepo { 'percona':
        descr => 'CentOS $releasever - Percona',
        baseurl => $baseurl,
        gpgkey => 'http://www.percona.com/downloads/percona-release/RPM-GPG-KEY-percona',
        enabled => 1,
        gpgcheck => 1,
      }
    } elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
      include apt

      apt::source { 'percona':
        ensure => present,
        include_src => true,
        location => 'http://repo.percona.com/apt',
        release => $::lsbdistcodename,
        repos => 'main',
        key => "CD2EFD2A",
      }
    } else {
      fail("The Percona Repo  is not supported on an ${::operatingsystem} based system.")
    }
  }


  if ($mySQLBuild  =~ /(?i:mariadb)/) {
    if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
      if ($operatingsystem =~ /(?i:amazon)/) {
        $baseurl = "http://yum.mariadb.org/${mySQLVersion}/centos${epel_version}-amd64"
      } else {
        $baseurl = "http://yum.mariadb.org/${mySQLVersion}/centos${operatingsystemmajrelease}-amd64"
      }

      yumrepo { 'mariadb':
        name => 'mariadb',
        baseurl => $baseurl,
        gpgkey => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
        enabled => 1,
        gpgcheck => 1,
      }
    } elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
      include apt

      apt::source { 'mariadb':
        ensure => present,
        include_src => true,
        location => "http://mirrors.coreix.net/mariadb/repo/$mySQLVersion/ubuntu",
        release => $::lsbdistcodename,
        repos => 'main',
        key => "0xcbcb082a1bb943db",
      }
    } else {
      fail("The mariaDB repo is not supported on an ${::operatingsystem} based system.")
    }
  }

  if ($mySQLBuild  =~ /(?i:mysql)/) {
      if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
          if ($operatingsystem =~ /(?i:amazon)/) {
            $baseurl ="http://repo.mysql.com/yum/mysql-${mySQLVersion}-community/el/${epel_version}/\$basearch/"
          } else {
            $baseurl ="http://repo.mysql.com/yum/mysql-${mySQLVersion}-community/el/${operatingsystemmajrelease}/\$basearch/"
          }

          file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql':
            ensure => file,
            mode	 => 644,
            owner	=> "root",
            group	=> "root",
            source => 'puppet:///modules/tungsten/RPM-GPG-KEY-mysql',
          }->
          yumrepo { 'mysql-community':
            name => 'mysql-community',
            baseurl => $baseurl,
            gpgkey => 'file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql',
            enabled => 1,
            gpgcheck => 1,
          }
      } elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
        include apt

        tempos=downcase($operatingsystem)
        apt::source { 'mysql':
          ensure => present,
          include_src => true,
          location => "http://repo.mysql.com/apt/$tempos/",
          release => $::lsbdistcodename,
          repos => "mysql-$mySQLVersion",
          key => '5072E1F5'
        }
      } else {
        fail("The MySQL Repo module is not supported on an ${::operatingsystem} based system.")
      }
  }
}
