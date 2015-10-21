# == Class: tungsten::prereq See README.md for documentation.
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

class tungsten::prereq (
	$systemUserName 				        = $tungsten::params::systemUserName,
	$nodeHostName									  = $fqdn,
	$installJava									  = true,
	$installNTP										  = $tungsten::params::installNTP,
	$disableFirewall							  = true,
	$disableSELinux									= true,

	# This may be set to 'nightly', 'stable' or 'true
	# If set to 'true', the stable repository will be used
	$replicatorRepo							    = false,

	$installMysqlj								  = true,
    $mysqljLocation               = false,

  #Setting this to true should only be used to support
	#testing as it's not secure unless you specify a custom private key
	$installSSHKeys								  = false,
	  $sshPublicKey                 = $tungsten::params::defaultSSHPublicKey,
	  $sshPrivateCert               = $tungsten::params::defaultSSHPrivateCert,

  #If this is set to true no setting of hostname will be done
  $skipHostConfig                 = false,
	$vmSwappiness										= 10,
	$docker													= false,
	$installGems										= true,
	$localGemLocation								= false

) inherits tungsten::params {
	if ($operatingsystem =~ /(?i:debian|ubuntu)/) {
		class { 'apt':
			update => {
			   frequency => 'always',
			},
	  }  -> Package <| |>
	}

	define install_local_gems  ( $loc  = false ) {

		if $loc == false {
			fail "install local gems failed as it was not passed a location"
		}
		package { $name:
			provider => "gem",
			source   => "$loc/$name",
	 }
	}

	package {'continuent-ruby': ensure => present, name => "ruby", }
	if ! defined(Package['continuent-wget']) {
			package {'continuent-wget': ensure => present, name => "wget", }
	}
	package {'continuent-sudo': ensure => present, name => "sudo", }
	if ! defined(Package['continuent-rsync']) {
		package {'continuent-rsync': ensure => present, name => "rsync", }
	}
  if $osfamily == 'RedHat' {
    package {'continuent-rubygems': ensure => present, name => "rubygems",}
  }

  if $osfamily == 'Debian' {
      #Newer releases have it built in so this should go away in the end
      if $operatingsystemrelease == '12.04' or
         $operatingsystemrelease == '10.04' or
         $lsbdistcodename == 'wheezy' or
         $lsbdistcodename == 'squeeze'{
          package {'continuent-rubygems': ensure => present, name => "rubygems",}
        }
  }

	if $installGems == true {
		package { "json_pure":
	     provider => "gem",
	  }

	  package { "continuent-monitors-nagios":
	     provider => "gem",
	     ensure => latest,
	  }
	}

	if $installGems == 'local' {

		if $localGemLocation == false {
			fail "If local install specified for gem a installGemLocation=> must be specified"
		}

			$localGemsToInstall=[
				"zip-2.0.2.gem",
				"xhr-ifconfig-1.2.3.gem",
				"open4-1.3.4.gem",
				"net-ssh-2.9.2.gem",
				"net-scp-1.2.1.gem",
				"escape-0.0.4.gem",
				"continuent-tools-core-0.11.0.gem",
				"continuent-tools-monitoring-0.7.0.gem",
				"json_pure-1.8.2.gem",
				"continuent-monitors-nagios-0.7.0.gem"]

			#If puppet is installing remotely if defaults to --no-ri --no-rdoc
			#for local gems it doesn't do this will set it
			file { "/root/.gemrc" :
				content => "gem: --no-rdoc --no-ri"
			} ->
			install_local_gems { $localGemsToInstall : loc=>$localGemLocation }

	}


	if $disableFirewall == true {
		class { "firewall": ensure    => stopped, }
		if $::osfamily == "RedHat" and  $::operatingsystemmajrelease == 7 {
		  if !defined(Service["firewalld"]) {
		    service {"firewalld": ensure => 'stopped'}
		  }
		}
	}

	if $skipHostConfig == false {
		class { "tungsten::prereq::hostname":
			nodeHostName                => $nodeHostName,
		}
	}

	class { "tungsten::prereq::unix_user":
		installSSHKeys                => $installSSHKeys,
		  sshPublicKey                => $sshPublicKey,
		  sshPrivateCert              => $sshPrivateCert,
	}

	anchor { "tungsten::prereq::start":
		require => [
			Package["continuent-wget"],
			Package["continuent-sudo"],
		]
	} ->
	class{ "tungsten::prereq::mysqlj":
		enabled => $installMysqlj,
    location => $mysqljLocation
	} ->
	class {"tungsten::prereq::sysctl":
		 vmSwappiness => $vmSwappiness,
		 docker 			=> $docker
	}->
	anchor { "tungsten::prereq::end":
		require => [
			Class["tungsten::prereq::unix_user"],
		]
	}

	if $installNTP == true {
		class { "ntp":
			before => Anchor["tungsten::prereq::start"]
		}
	}

	if $installJava == true {
	  # If we are installing on Amazon, the java install is simple. Otherwise,
	  # use the java class to choose the correct package name
		if $operatingsystem == "Amazon" {
			package { "java-1.7.0-openjdk":
				before => Anchor["tungsten::prereq::start"]
			}
		} else {
			class { "java":
				before => Anchor["tungsten::prereq::start"]
			}
		}
	}

	class{ "tungsten::prereq::repo":
		replicatorRepo                => $replicatorRepo,
	}
}
