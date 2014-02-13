class continuent_install::mysql::xtrabackup (
) {
  class { "percona_repo" : } ->
	package { "percona-xtrabackup" :
		ensure => present
	}
}