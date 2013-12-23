#This will setup east-db1 ready for east-db2 to be autoprovisioned in prov_run.pp

if $hostname == 'db1' {
file {"/etc/yum.repos.d/tungsten.repo":
  ensure => file,
  mode => 777,
  owner   => root,
  group   => root,
  content => '[tungsten]
name=Centos local Repo
baseurl=http://yumtest.continuent.com/
enabled=1
gpgcheck=0',
}

host { 'yumtest.continuent.com':
  ip => '23.21.169.95',
}


class { 'continuent_install' :
      hostsFile                  => ["192.168.11.101 db1",'192.168.11.102 db2'],

      clusterData                => {
      east => { 'members' => 'db1,db2', 'connectors' => 'db1,db2', 'master' => 'db1' },
      } ,
      installSSHKeys => true,
      installMysql => true        ,
      installClusterSoftware            => true
}
}

