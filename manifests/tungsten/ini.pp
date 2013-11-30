class continuent_install::tungsten::ini (
) inherits continuent_install::tungsten {
	include continuent_install::prereq
	
	Class["continuent_install::prereq"] ->
	file { "tungsten.ini":
		path		=> "/etc/tungsten/tungsten.ini",
		owner => $continuent_install::prereq::systemUserName,
		group => "root",
		mode => 644,
		content => template("continuent_install/tungsten.erb"),
	}
}