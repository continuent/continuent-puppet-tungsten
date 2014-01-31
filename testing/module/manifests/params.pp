class continuent_install::params {
	$systemUserName								= "tungsten"
	
	if $::operatingsystem == "Amazon" {
		$installNTP = false
	} else {
		$installNTP = true
	}
}