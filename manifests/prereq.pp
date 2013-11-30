class continuent_install::prereq (
	$systemUserName 				= $continuent_install::params::systemUserName,
	$nodeHostName									= $fqdn,
	$nodeIpAddress								= $ipaddress,
	$hostsFile										= [],
	$installRVM										= false,
	
	$replicatorRepo							= false,
		
	$installMysqlj								= true,
		$mysqljLocation	= "/opt/mysql/mysql-connector-java-5.1.26-bin.jar",
	
	#Setting this to true should only be used to support testing as it's not secure
	$installSSHKeys								 = false,
) inherits continuent_install::params {
	include ntp
	include java

	package {'ruby': ensure => present, }
	package {'wget': ensure => present, }
	package {'sudo': ensure => present, }
	package {'rsync': ensure => present, }
	
	class { "continuent_install::prereq::unix_user":
		installSSHKeys => $installSSHKeys
	}
	class{ "continuent_install::prereq::rvm": 
		enabled => $installRVM
	}
	
	anchor { "continuent_install::prereq::start": 
		require => [
			Class["ntp"],
			Class["java"],
			Package["ruby"],
			Package["wget"],
			Package["sudo"],
			Package["rsync"],
		]
	} ->
	class { "continuent_install::prereq::hostname": 
		nodeHostName => $nodeHostName
	} ->
	class { "continuent_install::prereq::hosts": 
		hostsFile => $hostsFile,
	} ->
	class{ "continuent_install::prereq::repo": 
		replicatorRepo => $replicatorRepo,
	} ->
	class{ "continuent_install::prereq::mysqlj": 
		enabled => $installMysqlj
	} ->
	anchor { "continuent_install::prereq::end": 
		require => [
			Class["continuent_install::prereq::unix_user"],
			Class["continuent_install::prereq::rvm"],
		]
	}
}