class tungsten::mysql::server (
) inherits tungsten::mysql {
	if $masterPassword == 'secret' {
		warning 'The default master password is being used'
	}
	
	$serverId	= fqdn_rand(5000,$::tungsten::prereq::nodeIpAddress)
	$sqlCheck	= "select * from mysql.user where user=''"
	$sqlExec		= "delete from mysql.user where user='';flush privileges;"
	
	class { "percona_repo" : }
	User <| title == "tungsten::systemUser" |> { groups +> "mysql" }
	
	package { 'mysql-server': 
		ensure => present,
		name => $serverPackageName,
	} ->
	package { 'mysql': 
		ensure => present,
		name => $clientPackageName,
	}	->
	User["tungsten::systemUser"] ->
	file { "/etc/mysql":
    ensure => directory,
    mode => 755,
  } ->
  file { "/etc/mysql/conf.d":
    ensure => directory,
    mode => 755,
  } ->
	file { "my.cnf":
  	path		=> $configFile,
  	mode		=> 644,
  	content => template("tungsten/my.erb"),
  } ~>
	service { "tungsten::mysql::server" :
		name => $serviceName,
		enable => true,
		ensure => running,
	} ->
	exec { "set-mysql-password":
		path => ["/bin", "/usr/bin"],
		command => "mysqladmin -uroot password $masterPassword",
		onlyif	=> ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u root"]
	} ->
	file { "${::root_home}/.my.cnf":
	  content => template('tungsten/my.cnf.pass.erb'),
	  owner   => root,
	  mode    => '0600',
	} ->
	exec { "remove-anon-users":
		onlyif	=> ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql --defaults-file=${::root_home}/.my.cnf -Be \"$sqlCheck\"|wc -l"],
		command => "/usr/bin/mysql --defaults-file=${::root_home}/.my.cnf -Be \"$sqlExec\"",
	} ->
	package { "percona-xtrabackup" :
		ensure => present
	}
}