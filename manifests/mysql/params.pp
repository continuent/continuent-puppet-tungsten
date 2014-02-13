class tungsten::mysql::params (
	$masterUser							= root,
	$masterPassword					= secret,
	$port										= 13306,
) {
	if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
		$serviceName							= "mysql"
		$serverPackageName				= "Percona-Server-server-55"
		$clientPackageName				= "Percona-Server-client-55"
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