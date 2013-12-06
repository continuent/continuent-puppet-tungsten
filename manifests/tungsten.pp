class continuent_install::tungsten (
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
) inherits continuent_install::params {
	include continuent_install::prereq
	
	#See if the passed ini file contains any user or password details
	$int_repUser=getReplicationUser($repUser,$tungstenIniContents)
	$int_repPassword=getReplicationPassword($repPassword,$tungstenIniContents)

	$int_appUser=getApplicationUser($appUser,$tungstenIniContents)
	$int_appPassword=getApplicationPassword($appPassword,$tungstenIniContents)
	
	if $clusterData != false {
		class{ "continuent_install::tungsten::ini": }->
		anchor{ "continuent_install::tungsten::ini": }
	} else {
		anchor{ "continuent_install::tungsten::ini": }
	}
	
	if defined(File["${::root_home}/.my.cnf"]) {
		file { '/tmp/tungsten_create_users':
      ensure => file,
      owner => 'root',
      mode => 700,
      content => template('continuent_install/tungsten_create_users.erb'),
			require => Anchor["continuent_install::tungsten::ini"]
    } ->
		exec { "tungsten_create_users":
			command => "/tmp/tungsten_create_users",
		} ->
		anchor{ "continuent_install::tungsten::create-users": }
	} else {
		anchor{ "continuent_install::tungsten::create-users": }
	}
	
	if $installClusterSoftware != false {
		class{ "continuent_install::tungsten::cluster": 
			location => $installClusterSoftware,
			require => Anchor["continuent_install::tungsten::create-users"]
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
		}
	}
	
	class{ "continuent_install::tungsten::update":
		require => Anchor["continuent_install::tungsten::replicator"]
	}
}