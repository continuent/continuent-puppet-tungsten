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

class tungsten::tungstenmysql::params (
	$masterUser							    = root,
	$masterPassword					    = secret,
	$port										    = 13306,
) {

  $baseOverrideOptionsMysqld =  {
    'bind_address' => '0.0.0.0',
    'server_id' => fqdn_rand(1073741824),
    'pid-file' => '/var/lib/mysql/mysql.pid',
    'log-bin' => '/var/lib/mysql/mysql-bin',
    'binlog-format' => 'MIXED',
    'port' => $port,
    'open_files_limit' => '65535',
    'sync_binlog' => '2',
    'max_allowed_packet' => '64m',
    'auto_increment_increment' => 1,
    'auto_increment_offset' => 1,
    'innodb_file_per_table' => true,
    'datadir'=> '/var/lib/mysql'
    }
  $baseOverrideOptionsMysqldSafe =  {}
  $baseOverrideOptionsClient =  {}

	if ($operatingsystem =~ /(?i:centos|redhat|oel|OracleLinux|amazon|SLES)/) {
    $configFileName               = "/etc/my.cnf"
    $logError                     = "/var/log/mysqld.log"
    $pidFile                      = '/var/run/mysqld/mysqld.pid'

	} elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
    $configFileName               = "/etc/mysql/my.cnf"
    $logError                     = "/var/log/mysqld.log"
    $pidFile                      = '/var/run/mysqld/mysqld.pid'

	} else {
		fail("The ${module_name} module is not supported on an ${::operatingsystem} based system.")
	}
}
