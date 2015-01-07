class { 'tungsten': installSSHKeys => true, installMysql=> true, mySQLBuild=>'mariadb', mySQLVersion=>'5.5', disableFirewall=> false, skipHostConfig=> true }
