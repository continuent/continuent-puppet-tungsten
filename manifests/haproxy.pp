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
class haproxy {
	if ($operatingsystem =~ /(?i:centos|redhat|oel)/) {
		package { 'xinetd':
			ensure => present,
		}

		service { "xinetd":
			ensure	=> "running",
			enable	=> "true",
			require => Package["xinetd"],
		}

		file { "/opt/continuent/share/connectorchk.sh":
			owner => tungsten,
			group => tungsten,
			mode => 700,
			require => [Class['tungsten_install']],
			content => template("continuent_install/connectorchk.sh.erb") ,
		}

		exec { "add-service":
			onlyif	=> "/bin/cat /etc/services | /bin/grep connectorchk|wc -l",
			command => "/bin/echo 'connectorchk				 9200/tcp' >> /etc/services",
			notify	=> Service['xinetd'],
		}

		exec { "add-user-map":
			onlyif	=> "/bin/cat /opt/continuent/tungsten/tungsten-connector/conf/user.map | /bin/grep haproxy|wc -l",
			command => "/bin/echo '$::continuent_install::haproxyUser $::continuent_install::haproxyPassword	$::continuent_install::clusterName'	>> /opt/continuent/tungsten/tungsten-connector/conf/user.map",
			require => [Class['tungsten_install']],
		}

		file { "/etc/xinetd.d/connectorchk":
			owner => root,
			group => root,
			mode => 600,
			require => [File['/opt/continuent/share/connectorchk.sh'],Package['xinetd']],
			content => template("continuent_install/connectorchk.erb") ,
			notify	=> Service['xinetd'],
		}

		$sqlCheck="select * from mysql.user where user='$::continuent_install::haproxyUser'"
		$sqlExec="grant usage, replication client	on *.* to $::continuent_install::haproxyUser identified by '$::continuent_install::haproxyPassword';"
		exec { "create-haproxy-user":
			onlyif	=> "/usr/bin/mysql -u root -p$::continuent_install::masterPassword -P $::continuent_install::mysqlPort -Be \"$sqlCheck\"|wc -l",
			command => "/usr/bin/mysql -u root -p$::continuent_install::masterPassword -P $::continuent_install::mysqlPort -Be \"$sqlExec\" ",
			require => [Exec['add-service'],Service[$::continuent_install::mysqlServiceName],Exec['set-mysql-password']],
		}
	}
}