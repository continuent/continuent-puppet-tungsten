class { 'tungsten': installSSHKeys => true, installMysql=> true, mySQLBuild=>'mariadb', mySQLVersion=>'10.0', disableFirewall=> false, skipHostConfig=> true,vmSwappiness	=> 60  }
