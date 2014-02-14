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
		$datadir                  = "/var/lib/mysql"
		$pidfile                  = "/var/lib/mysql/mysqld.pid"
		$socket                   = "/var/lib/mysql/mysql.sock"
	} elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
		$serviceName							= "mysql"
		$serverPackageName				= "Percona-Server-server-5.5"
		$clientPackageName				= "Percona-Server-client-5.5"
		$configFile								= "/etc/mysql/my.cnf"
		$datadir                  = "/var/lib/mysql"
		$pidfile                  = "/var/run/mysqld/mysqld.pid"
		$socket                   = "/var/run/mysqld/mysqld.sock"
	} else {
		fail("The ${module_name} module is not supported on an ${::operatingsystem} based system.")
	}
}