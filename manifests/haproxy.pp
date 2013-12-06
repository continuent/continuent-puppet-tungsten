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
class continuent_install::haproxy(
	$haproxyUser									= 'haproxy',
	$haproxyPassword							= 'secret',
) {
	if $haproxyPassword == 'secret' {
		warning 'The default haproxy password is being used'
	}
	
	if ($operatingsystem =~ /(?i:centos|redhat|oel)/) {
		package { 'xinetd':
			ensure => present,
		} ->
		service { "xinetd":
			ensure	=> "running",
			enable	=> "true",
		} ->
		file { "/opt/continuent/share/connectorchk.sh":
			owner => tungsten,
			group => tungsten,
			mode => 700,
			content => template("continuent_install/connectorchk.sh.erb") ,
		} ->
		exec { "add-service":
			onlyif	=> "/bin/cat /etc/services | /bin/grep connectorchk|wc -l",
			command => "/bin/echo 'connectorchk				 9200/tcp' >> /etc/services",
			notify	=> Service['xinetd'],
		} ->
		exec { "add-user-map":
			onlyif	=> "/bin/cat /opt/continuent/tungsten/tungsten-connector/conf/user.map | /bin/grep haproxy|wc -l",
			command => "/bin/echo '$haproxyUser $haproxyPassword	$::continuent_install::clusterName'	>> /opt/continuent/tungsten/tungsten-connector/conf/user.map",
		} ->
		file { "/etc/xinetd.d/connectorchk":
			owner => root,
			group => root,
			mode => 600,
			content => template("continuent_install/connectorchk.erb") ,
			notify	=> Service['xinetd'],
		}

		$sqlCheck="select * from mysql.user where user='$::continuent_install::haproxyUser'"
		$sqlExec="grant usage, replication client	on *.* to $::continuent_install::haproxyUser identified by '$::continuent_install::haproxyPassword';"
		exec { "create-haproxy-user":
			onlyif	=> "/usr/bin/mysql -u root -p$::continuent_install::masterPassword -P $::continuent_install::mysqlPort -Be \"$sqlCheck\"|wc -l",
			command => "/usr/bin/mysql -u root -p$::continuent_install::masterPassword -P $::continuent_install::mysql::port -Be \"$sqlExec\" ",
			require => [Exec['add-service'],Service[$::continuent_install::mysql::serviceName],Exec['set-mysql-password']],
		}
	}
}