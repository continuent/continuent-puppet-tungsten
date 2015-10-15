#
# Copyright (C) 2015 Continuent, Inc.
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

class tungsten::tungstenmysql::xtrabackup ( $installXtrabackup = true,
  	                                        $mySQLBuild	= 'percona',
                                            $xtraBackupPackage = 'auto'

) {

    if $installXtrabackup == true {

        if $mySQLBuild == 'percona' {

            if $::osfamily == "RedHat" and $operatingsystemmajrelease == 5 {
              notice ("xtrabackup is not supported on ${::operatingsystem}:${operatingsystemmajrelease} based system")
            }else {
              if $xtraBackupPackage='auto' {
                  package { 'percona-xtrabackup': ensure => 'present' }
              } else {
                case $::osfamily {
                  'Redhat': {$provider='rpm'}
                  'Debian': {$provider='dpkg'}
                }
                package { "percona-xtrabackup":
                   provider => $provider
                   ensure => present,
                   source => $download,
                 }
              }
            }

        } else {
          if $::osfamily == "RedHat" {
              if ($operatingsystem =~ /(?i:amazon)/) {
                  $release = $epel_version
              } else {
                $release = $operatingsystemmajrelease
              }

              if $release != 5 {
                if $xtraBackupPackage == 'auto' {
                  case $release {
                    6:          { $download = "http://www.percona.com/downloads/XtraBackup/XtraBackup-2.2.8/binary/redhat/6/x86_64/percona-xtrabackup-2.2.8-5059.el6.x86_64.rpm" }
                    7:          { $download = "http://www.percona.com/downloads/XtraBackup/XtraBackup-2.2.8/binary/redhat/7/x86_64/percona-xtrabackup-2.2.8-5059.el7.x86_64.rpm"  }
                    default:    { fail("Xtrabackup is not supported on an ${::operatingsystem}:${release} based system.") }
                    }
                } else {
                  $download = $xtraBackupPackage
                }

                if ! defined(Package['continuent-wget']) {
                    package {'continuent-wget': ensure => present, name => "wget", }
                }
                if ! defined(Package['continuent-rsync']) {
                  package {'continuent-rsync': ensure => present, name => "rsync", }
                }

                if $release == 7 {package {'perl-Digest-MD5': ensure=>'present'}}
                package {'perl-DBD-MySQL': ensure=>'present'} ->
                package {'perl-Time-HiRes': ensure=>'present'} ->


                package { "percona-xtrabackup":
                   provider => "rpm",
                   ensure => present,
                   require => Package['continuent-rsync'],
                   source => $download,
                 }
              } else {
                notice ("xtrabackup is not supported on ${::operatingsystem}:${release} based system")
              }


        } elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {

            if $xtraBackupPackage == 'auto' {
              case $::lsbdistcodename {
                'squeeze':   { $download = "http://www.percona.com/downloads/XtraBackup/XtraBackup-2.2.8/binary/debian/squeeze/x86_64/percona-xtrabackup_2.2.8-5059-1.squeeze_amd64.deb" }
                "wheezy":    { $download = "http://www.percona.com/downloads/XtraBackup/XtraBackup-2.2.8/binary/debian/wheezy/x86_64/percona-xtrabackup_2.2.8-5059-1.wheezy_amd64.deb" }
                'lucid':     { $download = "http://www.percona.com/downloads/XtraBackup/XtraBackup-2.2.8/binary/debian/lucid/x86_64/percona-xtrabackup_2.2.8-5059-1.lucid_amd64.deb"}
                'precise':   { $download = "http://www.percona.com/downloads/XtraBackup/XtraBackup-2.2.8/binary/debian/precise/x86_64/percona-xtrabackup_2.2.8-5059-1.precise_amd64.deb"}
                'trusty':    { $download = "http://www.percona.com/downloads/XtraBackup/XtraBackup-2.2.8/binary/debian/trusty/x86_64/percona-xtrabackup_2.2.8-5059-1.trusty_amd64.deb" }
                default:     { fail("Xtrabackup is not supported on an ${::operatingsystem}:${lsbdistcodename} based system.") }
              }
            } else {
                $download = $xtraBackupPackage
            }


          if ! defined(Package['continuent-wget']) {
                    package {'continuent-wget': ensure => present, name => "wget", }
          }
          package {'libdbd-mysql-perl': ensure=>'present'} ->
          package { "percona-xtrabackup":
             provider => "dpkg",
             ensure => present,
             source => $download,
           }

        } else {
            fail("Xtrabackup is not supported on an ${::operatingsystem} based system.")
        }
      }
    }
}
