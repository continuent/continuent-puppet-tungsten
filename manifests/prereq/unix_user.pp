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
class tungsten::prereq::unix_user(
	$installSSHKeys								= false,
	$sshPublicKey                 = $tungsten::params::defaultSSHPublicKey,
	$sshPrivateCert               = $tungsten::params::defaultSSHPrivateCert,
) inherits tungsten::params {
	@user { "tungsten::systemUser":
		name => $systemUserName,
		groups => [],
		comment => 'This user was created by Puppet',
		ensure => 'present',
		uid => 6000,
		home => '/home/tungsten',
		managehome => true,
		shell => "/bin/bash",
	}
	
	User <| title == "tungsten::systemUser" |>

	file { "/home/tungsten/":
		ensure => directory,
		owner	=> $systemUserName,
		group	=> $systemUserName,
		mode => 750,
		require => [ User["tungsten::systemUser"] ]
	}
	
	file {"/home/tungsten/.bash_profile":
		ensure => file,
		mode => 644,
		owner => $systemUserName,
		group => "root",
		content => template('tungsten/tungsten_bash_profile.erb'),
		require => File['/home/tungsten'],
	}
	
	file { "10_tungsten":
		path		=> "/etc/sudoers.d/10_tungsten",
		ensure	=> present,
		owner	 => "root",
		group	 => "root",
		mode		=> 0440,
		replace => true,
		require => Package[sudo],
		content => "$systemUserName ALL=(ALL) NOPASSWD: ALL";
	}

	exec { "remove-requiretty":
		command => "/bin/sed -i	'/requiretty/s/^/#/'	/etc/sudoers",
		require => Package[sudo],
	}
					
	file { '/etc/security/limits.d/10tungsten.conf':
		ensure => file,
		content => template('tungsten/security.limits.conf.erb'),
	}
	
	file { "/opt/continuent":
		ensure => "directory",
		owner	=> $systemUserName,
		group	=> $systemUserName,
		mode	 => 750,
		require => User["tungsten::systemUser"]
	}
	
	file { "/opt/replicator":
		ensure => "directory",
		owner	=> $systemUserName,
		group	=> $systemUserName,
		mode	 => 750,
		require => User["tungsten::systemUser"],
	}
	
	file { "/etc/tungsten":
		ensure => "directory",
		owner	=> $systemUserName,
		group	=> $systemUserName,
		mode	 => 750,
	}

	#Create tungsten .ssh dir
	file { "/home/tungsten/.ssh":
		ensure => 'directory',
		require => File['/home/tungsten'],
		owner => $systemUserName,
		mode => '700',
	}

	if	$installSSHKeys == true {
	  File['/home/tungsten/.ssh'] ->
		file {"/home/tungsten/.ssh/id_rsa":
			ensure => file,
			mode => 600,
			owner => $systemUserName,
			content => $sshPrivateCert,
		} ->
		file {"/home/tungsten/.ssh/id_rsa.pub":
			ensure => file,
			mode => 600,
			owner => $systemUserName,
			content => "ssh-rsa $sshPublicKey",
		} ->
		ssh_authorized_key { "tungsten::prereq::unix_user":
		  user => $systemUserName,
		  type => rsa,
		  key => $sshPublicKey,
		}
	}
}