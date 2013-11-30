class continuent_install::mysql::params (
	$masterUser							= root,
	$masterPassword					= secret,
	$port										= 13306,
) inherits continuent_install::params {
	$serviceUser						= mysql
	$serviceGroup						= mysql
	
	if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
		$serviceName							= "mysqld"
	} else {
		fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
	}
}