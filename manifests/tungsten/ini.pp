class tungsten::tungsten::ini (
) inherits tungsten::tungsten {
	include tungsten::prereq

    if $tungsten::tungsten::clusterData != false {
      $compositeInfo = getCompositeDS($tungsten::tungsten::clusterData)
    }

	Class["tungsten::prereq"] ->
	file { "tungsten.ini":
		path		=> "/etc/tungsten/tungsten.ini",
		owner => $tungsten::prereq::systemUserName,
		group => "root",
		mode => 644,
		content => template("tungsten/tungsten.erb"),
	}
}