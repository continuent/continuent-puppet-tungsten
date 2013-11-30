class continuent_install::tungsten (
	$installClusterSoftware			= false,
	$installReplicatorSoftware	= false,
	
	$replicationUser						= "tungsten",
	$replicationPassword				= "secret",
	$applicationUser						= "app_user",
	$applicationPassword				= "secret",
	
	$additionalConfiguration		= undef,
	
	$provision									= false,
	$provisionDonor							= undef,
) inherits continuent_install::params {
	include continuent_install::prereq
	
	Class["continuent_install::prereq"] ->
	class{ "continuent_install::tungsten::ini": }
	
	if $installClusterSoftware == true {
		class{ "continuent_install::tungsten::cluster": 
			require => Class["continuent_install::tungsten::ini"]
		} ->
		anchor{ "continuent_install::tungsten::cluster": }
	} else {
		anchor{ "continuent_install::tungsten::cluster": }
	}
	
	if $installReplicatorSoftware == true {
		class{ "continuent_install::tungsten::replicator": 
			require => Anchor["continuent_install::tungsten::cluster"]
		} ->
		anchor{ "continuent_install::tungsten::replicator": }
	} else {
		anchor{ "continuent_install::tungsten::replicator": }
	}
	
	if $provision == true {
		class{ "continuent_install::tungsten::provision": 
			donor => $provisionDonor,
			require => Anchor["continuent_install::tungsten::replicator"]
		} ->
		anchor{ "continuent_install::tungsten::provision": }
	} else {
		anchor{ "continuent_install::tungsten::provision": }
	}
}