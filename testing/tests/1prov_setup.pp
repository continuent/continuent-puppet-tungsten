#This will setup east-db1 ready for east-db2 to be autoprovisioned in prov_run.pp

class { 'continuent_tungsten' :
      nodeHostName                => 'east-db1' ,
      nodeIpAddress               => "${::ipaddress}" ,
      hostsFile                  => ["${::ipaddress}  east-db1",'192.168.0.216 east-db2'],

      clusterData                => {
      east => { 'members' => 'east-db1,east-db2', 'connectors' => 'east-db1,east-db2', 'master' => 'east-db1' },
      } ,
      connectorJDownload         => 'http://yumtest.continuent.com/'  ,
      installSSHKeys => true,
      installCluster => true
}