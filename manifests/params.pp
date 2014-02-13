class tungsten::params {
	$systemUserName								= "tungsten"
	
	if $::operatingsystem == "Amazon" {
		$installNTP = false
	} else {
		$installNTP = true
	}
}