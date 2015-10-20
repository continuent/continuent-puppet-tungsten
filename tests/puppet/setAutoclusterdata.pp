$clusterData = {
      "east" => {
        "topology" => "master-slave",
        "master" =>  $::fqdn,
        "slaves" => "db2,db3",
      },
    }

class { 'tungsten': installSSHKeys => true,
        installMysql=> true,
        disableFirewall=> false, skipHostConfig=> true ,mySQLSetAutoIncrement=>true,clusterData=>$clusterData,docker => true,
        xtraBackupPackage=>'/mnt/xtrabackup/percona-xtrabackup-2.2.12-1.el6.x86_64.rpm'    }
