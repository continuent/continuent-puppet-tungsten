class tungsten::prereq (
	$systemUserName 				= $tungsten::params::systemUserName,
	$nodeHostName									= $fqdn,
	$nodeIpAddress								= $ipaddress,
	$hostsFile										= [],
	$installRVM										= false,
	$installJava									= true,
	$installNTP										= $tungsten::params::installNTP,
	$disableFirewall							= true,
	
	$replicatorRepo							= false,
		
	$installMysqlj								= true,
    $mysqljLocation                         = false,
	
	#Setting this to true should only be used to support testing as it's not secure
	$installSSHKeys								 = false,
    $skipHostConfig           = false,
) inherits tungsten::params {
	package {'ruby': ensure => present, }
	package {'wget': ensure => present, }

	package {'continuent-sudo': ensure => present, name=> 'sudo' }

	package {'rsync': ensure => present, }
	
	if $disableFirewall == true {
		class { "firewall":
		  ensure => stopped
		}
	}

	if $skipHostConfig == false {
		class { "tungsten::prereq::hostname":
			nodeHostName => $nodeHostName
		}
	}
	class { "tungsten::prereq::selinux":
	}
	class { "tungsten::prereq::unix_user":
		installSSHKeys => $installSSHKeys
	}
	class{ "tungsten::prereq::rvm": 
		enabled => $installRVM
	}
	
	anchor { "tungsten::prereq::start": 
		require => [
			Package["wget"],
			Package["sudo"],
		]
	} ->
	class { "tungsten::prereq::hosts":
		hostsFile => $hostsFile,
        skipHostConfig =>  $skipHostConfig,
	} ->
	class{ "tungsten::prereq::repo": 
		replicatorRepo => $replicatorRepo,
	} ->
	class{ "tungsten::prereq::mysqlj": 
		enabled => $installMysqlj,
        location => $mysqljLocation
	} ->
	anchor { "tungsten::prereq::end": 
		require => [
			Class["tungsten::prereq::unix_user"],
			Class["tungsten::prereq::rvm"],
		]
	}
	
	if $installNTP == true {
		class { "ntp":
			before => Anchor["tungsten::prereq::start"]
		}
	}
	
	if $installJava == true {
		if $operatingsystem == "Amazon" {
			package { "java-1.6.0-openjdk": 
				before => Anchor["tungsten::prereq::start"]
			}
		} else {
			class { "java":
				before => Anchor["tungsten::prereq::start"]
			}
		}
	}
	
	if ($operatingsystem =~ /(?i:debian|ubuntu)/) {
	  exec { "tungsten::prereq::apt-update":
        command => "/usr/bin/apt-get update"
    }

    Exec["tungsten::prereq::apt-update"] -> Package <| |>
  }
}