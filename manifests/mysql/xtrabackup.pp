class continuent_install::mysql::xtrabackup (
) {
	if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
		package { "percona-release":
			provider => "rpm",
			ensure => present,
			source => "http://www.percona.com/downloads/percona-release/percona-release-0.0-1.${architecture}.rpm",
		} ->
		package { "percona-xtrabackup-20" :
			ensure => present
		}
	} else {
		warning("Skipping Xtrabackup installation on unsupported system")
	}
}