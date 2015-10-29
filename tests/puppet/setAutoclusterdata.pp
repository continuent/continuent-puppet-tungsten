$clusterData = {
      "east" => {
        "topology" => "master-slave",
        "master" =>  $::fqdn,
        "slaves" => "db2,db3",
      },
    }

class { 'tungsten': installSSHKeys => true,
        installMysql=> true,
        disableFirewall=> false, skipHostConfig=> true ,mySQLSetAutoIncrement=>true,clusterData=>$clusterData,docker => true     }
