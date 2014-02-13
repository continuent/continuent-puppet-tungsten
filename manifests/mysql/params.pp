class continuent_install::mysql::params (
	$masterUser							= root,
	$masterPassword					= secret,
	$port										= 13306,
) inherits continuent_install::params {
	$serviceUser						= mysql
	$serviceGroup						= mysql
	
	if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
		$serviceName							= "mysqld"
		$serverPackageName				= "mysql-server"
		$clientPackageName				= "mysql"
		$configFile								= "/etc/my.cnf"
	} elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
		$serviceName							= "mysql"
		$serverPackageName				= "mysql-server"
		$clientPackageName				= "mysql-client"
		$configFile								= "/etc/mysql/my.cnf"
	} else {
		fail("The ${module_name} module is not supported on an ${::operatingsystem} based system.")
	}
}