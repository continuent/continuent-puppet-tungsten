class { 'tungsten': installSSHKeys => true, installMysql=> true,
    mySQLBuild=>'percona', mySQLVersion=>'5.6', disableFirewall=> false, skipHostConfig=> true,docker => true     }
