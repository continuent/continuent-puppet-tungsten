file { "continuent-hostname":
  path => '/etc/hostname',
  ensure => present,
  owner => root,
  group => root,
  mode => 644,
  content => "$fqdn\n",
}

exec { "set-hostname":
  command => "/bin/hostname -F /etc/hostname",
  unless => "/usr/bin/test `hostname` = `/bin/cat /etc/hostname`",
  require => File["continuent-hostname"],
}

exec { "set-network-hostname":
  command => "/bin/sed -i -e \"s/HOSTNAME=.*/HOSTNAME=$nodeHostName/\" /etc/sysconfig/network",
  unless => "/usr/bin/test `grep HOSTNAME /etc/sysconfig/network` = 'HOSTNAME=$nodeHostName'",
}

host { $fqdn:
  ip => $ipaddress
}