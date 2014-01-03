class continuent_install::prereq (
	$systemUserName 				= $continuent_install::params::systemUserName,
	$nodeHostName									= $fqdn,
	$nodeIpAddress								= $ipaddress,
	$hostsFile										= [],
	$installRVM										= false,
	$installJava									= true,
	$installNTP										= $continuent_install::params::installNTP,
	$disableFirewall							= true,
	
	$replicatorRepo							= false,
		
	$installMysqlj								= true,
    $mysqljLocation                         = false,
	
	#Setting this to true should only be used to support testing as it's not secure
	$installSSHKeys								 = false,
    $skipHostConfig           = false,
) inherits continuent_install::params {
	package {'ruby': ensure => present, }
	package {'wget': ensure => present, }
	package {'sudo': ensure => present, }
	package {'rsync': ensure => present, }
	
	if $disableFirewall == true {
		class { "firewall":
		  ensure => stopped
		}
	}

    if $skipHostConfig == false {
        class { "continuent_install::prereq::hostname":
          nodeHostName => $nodeHostName
        }
    }
	class { "continuent_install::prereq::selinux":
	}
	class { "continuent_install::prereq::unix_user":
		installSSHKeys => $installSSHKeys
	}
	class{ "continuent_install::prereq::rvm": 
		enabled => $installRVM
	}
	
	anchor { "continuent_install::prereq::start": 
		require => [
			Package["wget"],
			Package["sudo"],
		]
	} ->
	class { "continuent_install::prereq::hosts":
		hostsFile => $hostsFile,
        skipHostConfig =>  $skipHostConfig,
	} ->
	class{ "continuent_install::prereq::repo": 
		replicatorRepo => $replicatorRepo,
	} ->
	class{ "continuent_install::prereq::mysqlj": 
		enabled => $installMysqlj,
        location => $mysqljLocation
	} ->
	anchor { "continuent_install::prereq::end": 
		require => [
			Class["continuent_install::prereq::unix_user"],
			Class["continuent_install::prereq::rvm"],
		]
	}
	
	if $installNTP == true {
		class { "ntp":
			before => Anchor["continuent_install::prereq::start"]
		}
	}
	
	if $installJava == true {
		if $operatingsystem == "Amazon" {
			package { "java-1.6.0-openjdk": 
				before => Anchor["continuent_install::prereq::start"]
			}
		} else {
			class { "java":
				before => Anchor["continuent_install::prereq::start"]
			}
		}
	}
}