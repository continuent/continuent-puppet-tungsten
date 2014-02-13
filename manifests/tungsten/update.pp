class tungsten::tungsten::update (
) inherits tungsten::params {
	exec { "tungsten::tungsten::update::opt_continuent":
		path => ["/usr/bin"],
		command => "sudo -i -u tungsten /opt/continuent/tungsten/tools/tpm update",
		subscribe => File["/etc/tungsten/tungsten.ini"],
		onlyif => "test -f /opt/continuent/tungsten",
		refreshonly => true
	}
	
	exec { "tungsten::tungsten::update::opt_replicator":
		path => ["/usr/bin"],
		command => "sudo -i -u tungsten /opt/replicator/tungsten/tools/tpm update",
		subscribe => File["/etc/tungsten/tungsten.ini"],
		onlyif => "test -f /opt/replicator/tungsten",
		refreshonly => true
	}
}