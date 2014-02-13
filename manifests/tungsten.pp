class tungsten::tungsten (
	$installReplicatorSoftware	= false,
		$repUser						= tungsten,
		$repPassword				= secret,
	
	$installClusterSoftware			= false,
		$clusterData									= false,
		$compositeName								= false,
		$appUser											= app_user,
		$appPassword									= secret,
		$applicationPort							= 3306,
		
	$tungstenIniContents		= false,
	
	$provision									= false,
	$provisionDonor							= false,
) inherits tungsten::params {
	include tungsten::prereq
	
	#See if the passed ini file contains any user or password details
	$int_repUser=getReplicationUser($repUser,$tungstenIniContents)
	$int_repPassword=getReplicationPassword($repPassword,$tungstenIniContents)

	$int_appUser=getApplicationUser($appUser,$tungstenIniContents)
	$int_appPassword=getApplicationPassword($appPassword,$tungstenIniContents)
	
	if $clusterData != false {
		class{ "tungsten::tungsten::ini": }->
		anchor{ "tungsten::tungsten::ini": }
		
		Anchor["tungsten::tungsten::replicator"] ->
		class{ "tungsten::tungsten::update": }
	} else {
		anchor{ "tungsten::tungsten::ini": }
	}
	
	if defined(File["${::root_home}/.my.cnf"]) {
	  Anchor["tungsten::tungsten::ini"] ->
		file { '/tmp/tungsten_create_users':
      ensure => file,
      owner => 'root',
      mode => 700,
      content => template('tungsten/tungsten_create_users.erb'),
    } ->
		exec { "tungsten_create_users":
			command => "/tmp/tungsten_create_users",
		} ->
		anchor{ "tungsten::tungsten::create-users": }
	} else {
		anchor{ "tungsten::tungsten::create-users": }
	}
	
	if $installClusterSoftware != false {
	  Anchor["tungsten::tungsten::create-users"] ->
		class{ "tungsten::tungsten::cluster": 
			location => $installClusterSoftware,
		} ->
		anchor{ "tungsten::tungsten::cluster": }
	} else {
		anchor{ "tungsten::tungsten::cluster": }
	}
	
	if $installReplicatorSoftware == true {
	  Anchor["tungsten::tungsten::cluster"] ->
		class{ "tungsten::tungsten::replicator": } ->
		anchor{ "tungsten::tungsten::replicator": }
	} else {
		anchor{ "tungsten::tungsten::replicator": }
	}
	
	if $provision == true {
    Anchor["tungsten::tungsten::replicator"] ->
		class{ "tungsten::tungsten::provision": 
			donor => $provisionDonor,
		}
	}
}