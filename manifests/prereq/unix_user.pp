# == Class: tungsten::prereq::unix_user See README.md for documentation.
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

	if $osfamily == 'Suse' {
    group {$systemUserName: ensure => 'present'}
    file { '/etc/security/limits.d/':
            ensure => directory,
    }
	}

  group {"mysql": ensure => 'present'} ->
	User <| title == "tungsten::systemUser" |>

	if defined(Anchor["mysql::server::end"]) {
	  User <| title == "tungsten::systemUser" |> { groups +> "mysql" }

	}



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



	exec { "tungsten::prereq::remove-requiretty":
  		command => "/bin/sed -i	'/requiretty/s/^Defaults/#Defaults/'	/etc/sudoers",
  		onlyif => "/bin/grep requiretty /etc/sudoers | /bin/egrep -v \"^#\"",
  		require => Package[sudo],
  	}

  #Centos/Rhel 5 does not support /etc/sudoers.d files (CONT-147)
  if $osfamily == 'RedHat' and $operatingsystemmajrelease == 5 {
      exec { "tungsten::prereq::sudo":
        command => "/bin/echo  '\n$systemUserName ALL=(ALL) NOPASSWD: ALL' >>  /etc/sudoers",
        unless => "/bin/grep $systemUserName /etc/sudoers",
        require => Package[sudo],
      }
  }  else {

			file { "tungsten::prereq::sudo.d" :
				path    => "/etc/sudoers.d",
				ensure  => directory,
				owner   => "root",
				group   => "root",
				mode    => 0440,
				require => Package[sudo],
			} ->
      file { "tungsten::prereq::sudo":
        path    => "/etc/sudoers.d/10_tungsten",
        ensure  => present,
        owner   => "root",
        group   => "root",
        mode    => 0440,
        replace => true,
        require => Package[sudo],
        content => template('tungsten/tungsten.sudo.erb'),
      }->
			exec { "tungsten::prereq::sudo_include":
					command => "/bin/echo  '\n#includedir /etc/sudoers.d' >>  /etc/sudoers",
					unless => "/bin/grep 'includedir /etc/sudoers.d' /etc/sudoers",
					require => Package[sudo],
			}
  }


	file { '/etc/security/limits.d/10tungsten.conf':
		ensure => file,
		content => template('tungsten/security.limits.conf.erb'),
	}

	file { "/opt/continuent":
		ensure => "directory",
		owner	=> $systemUserName,
		group	=> $systemUserName,
		mode	 => 700,
		require => User["tungsten::systemUser"]
	}

	file { "/opt/continuent/software":
		ensure => "directory",
		owner	=> $systemUserName,
		group	=> $systemUserName,
		mode	 => 750,
		require => User["tungsten::systemUser"]
	}

	file { "/opt/continuent/service_logs":
		ensure => "directory",
		owner	=> $systemUserName,
		group	=> $systemUserName,
		mode	 => 700,
		require => User["tungsten::systemUser"]
	}

	file { "/opt/replicator":
		ensure => "directory",
		owner	=> $systemUserName,
		group	=> $systemUserName,
		mode	 => 700,
		require => User["tungsten::systemUser"],
	}

	file { "/etc/tungsten":
		ensure => "directory",
		owner	=> $systemUserName,
		group	=> $systemUserName,
		mode	 => 700,
	}

	#Create tungsten .ssh dir
	file { "/home/tungsten/.ssh":
		ensure => 'directory',
		require => File['/home/tungsten'],
		owner => $systemUserName,
		mode => '700',
	}

  # Only create the ~tungsten/.ssh files if we are asked to use the default
  # certificate, or if a different certificate is provided.
  if $installSSHKeys == true {
    $setupSSHDirectory = true
  } elsif $sshPrivateCert != $tungsten::params::defaultSSHPrivateCert {
    $setupSSHDirectory = true
  } else {
    $setupSSHDirectory = false
  }

	if $setupSSHDirectory == true {
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
