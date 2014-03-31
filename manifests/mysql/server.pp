# == Class: tungsten::mysql::server See README.md for documentation.
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

class tungsten::mysql::server (
) inherits tungsten::mysql {
	if $masterPassword == 'secret' {
		warning 'The default master password is being used'
	}
	
	$serverId	= fqdn_rand(5000,$ipaddress)
	$sqlCheck	= "select * from mysql.user where user=''"
	$sqlExec		= "delete from mysql.user where user='';flush privileges;"
	
	class { "percona_repo" : }
	User <| title == "tungsten::systemUser" |> { groups +> "mysql" }
	
	package { 'mysql-server': 
		ensure => present,
		name => $serverPackageName,
	} ->
	package { 'mysql': 
		ensure => present,
		name => $clientPackageName,
	}	->
	User["tungsten::systemUser"] ->
	file { "/etc/mysql":
    ensure => directory,
    mode => 755,
  } ->
  file { "/etc/mysql/conf.d":
    ensure => directory,
    mode => 755,
  } ->
	file { "my.cnf":
  	path		=> $configFile,
  	mode		=> 644,
  	content => template("tungsten/my.erb"),
  } ~>
	service { "tungsten::mysql::server" :
		name => $serviceName,
		enable => true,
		ensure => running,
	} ->
	exec { "set-mysql-password":
		path => ["/bin", "/usr/bin"],
		command => "mysqladmin -uroot password $masterPassword",
		onlyif	=> ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u root"]
	} ->
	file { "${::root_home}/.my.cnf":
	  content => template('tungsten/my.cnf.pass.erb'),
	  owner   => root,
	  mode    => '0600',
	} ->
	exec { "tungsten-mysql-remove-anon-users":
		onlyif	=> ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql --defaults-file=${::root_home}/.my.cnf -Be \"$sqlCheck\"|wc -l"],
		command => "/usr/bin/mysql --defaults-file=${::root_home}/.my.cnf -Be \"$sqlExec\"",
	} ->
	package { "percona-xtrabackup" :
		ensure => present
	}
}