if $operatingsystem == 'Redhat' and  $::operatingsystemmajrelease == 6 {

  class { 'tungsten': installSSHKeys => true, installMysql=> true, mySQLBuild=>'mysql', mySQLVersion=>'5.6',
        disableFirewall=> false, skipHostConfig=> true ,docker => true , installOracle => true  , oracleVersion=>11, oracleBinaries=>'/mnt/oracle'  }
}
