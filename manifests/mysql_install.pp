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
#		http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class mysql_install {
	$port=$::continuent_install::mysqlPort
	
	if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
		package { 'mysql-server': ensure => present, 
			require => [File["/etc/hostname"]],
 			before => [Package[percona-release]]
		}
		package { 'mysql': ensure => present, 
			require => Package[mysql-server], 
		}
	}

	service { $::continuent_install::mysqlServiceName :
		enable => true,
		ensure => running,
		require => [Package[mysql-server],File["/etc/my.cnf"]],
	}

	file { "my.cnf":
		path		=> "/etc/my.cnf",
		owner	 => root,
		group	 => root,
		mode		=> 644,
		content => template("continuent_install/my.erb")
	}

	exec { "set-mysql-password":
		path => ["/bin", "/usr/bin"],
		command => "mysqladmin -uroot password $::continuent_install::masterPassword",
		require => Service[$::continuent_install::mysqlServiceName],
		onlyif	=> ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u root"]
	}

	$sqlCheck3="select * from mysql.user where user=''"
	$sqlExec3="delete from mysql.user where user='';flush privileges;"
		exec { "remove-anon-users":
		onlyif	=> ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlCheck\"|wc -l"],
		command => "/usr/bin/mysql -u $::continuent_install::masterUser -p$::continuent_install::masterPassword -P $port -Be \"$sqlExec3\"",
		require => Exec['set-mysql-password'],
	}

	package { "percona-release":
		provider => "rpm",
		ensure => present,
		source => "http://www.percona.com/downloads/percona-release/percona-release-0.0-1.${architecture}.rpm",
	}

	package { "percona-xtrabackup-20" :
		ensure => present,
		require => [Package[percona-release]]
	}
}
