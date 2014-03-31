# == Class: tungsten::mysql::params See README.md for documentation.
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

class tungsten::mysql::params (
	$masterUser							= root,
	$masterPassword					= secret,
	$port										= 13306,
) {
	if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
		$serviceName							= "mysql"
		$serverPackageName				= "Percona-Server-server-55"
		$clientPackageName				= "Percona-Server-client-55"
		$configFile								= "/etc/my.cnf"
		$datadir                  = "/var/lib/mysql"
		$pidfile                  = "/var/lib/mysql/mysqld.pid"
		$socket                   = "/var/lib/mysql/mysql.sock"
	} elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
		$serviceName							= "mysql"
		$serverPackageName				= "Percona-Server-server-5.5"
		$clientPackageName				= "Percona-Server-client-5.5"
		$configFile								= "/etc/mysql/my.cnf"
		$datadir                  = "/var/lib/mysql"
		$pidfile                  = "/var/run/mysqld/mysqld.pid"
		$socket                   = "/var/run/mysqld/mysqld.sock"
	} else {
		fail("The ${module_name} module is not supported on an ${::operatingsystem} based system.")
	}
}