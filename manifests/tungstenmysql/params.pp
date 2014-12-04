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
  $mysqlOverrideOptions = {},
) {
	if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
      $base_override_options = merge( {
          'bind_address' => '0.0.0.0',
          'server_id' => fqdn_rand(1073741824),
          'pid-file' => '/var/lib/mysql/mysql.pid',
          'log-bin' => 'mysql-bin',
          'binlog-format' => 'MIXED',
          'port' => '13306',
          'open_files_limit' => '65535',
          'sync_binlog' => '2',
          'max_allowed_packet' => '64m',
          'auto_increment_increment' => 1,
          'auto_increment_offset' => 1,
          'innodb_file_per_table' => true,
          },$mysqlOverrideOptions)

		$serviceName							= "mysql"
		$serverPackageName				= "Percona-Server-server-55"
		$clientPackageName				= "Percona-Server-client-55"
		$configFile								= "/etc/my.cnf"
		$datadir                  = "/var/lib/mysql"
		$pidfile                  = "/var/lib/mysql/mysqld.pid"
		$socket                   = "/var/lib/mysql/mysql.sock"
	} elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
        $base_override_options = {
            'mysqld' => {
            'bind_address' => '0.0.0.0',
            'server_id' => fqdn_rand(1073741824),
            'pid-file' => '/var/lib/mysql/mysql.pid',
            'log-bin' => 'mysql-bin',
            'binlog-format' => 'MIXED',
            'port' => '13306',
            'open_files_limit' => '65535',
            'sync_binlog' => '2',
            'max_allowed_packet' => '64m',
            'auto_increment_increment' => 1,
            'auto_increment_offset' => 1,
            'innodb_file_per_table' => true,
            }
        }
		$serviceName							= "mysql"
		$serverPackageName				= "percona-server-server-5.5"
		$clientPackageName				= "percona-server-client-5.5"
		$configFile								= "/etc/mysql/my.cnf"
		$datadir                  = "/var/lib/mysql"
		$pidfile                  = "/var/run/mysqld/mysqld.pid"
		$socket                   = "/var/run/mysqld/mysqld.sock"
	} else {
		fail("The ${module_name} module is not supported on an ${::operatingsystem} based system.")
	}
}