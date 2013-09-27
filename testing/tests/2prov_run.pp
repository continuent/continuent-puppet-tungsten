#This will setup east-db1 ready for east-db2 to be autoprovisioned in prov_run.pp

class { 'continuent_tungsten' :
      nodeHostName                => 'east-db2' ,
      nodeIpAddress               => "${::ipaddress}" ,
      hostsFile                  => ["east-db1-private-ip  east-db1","${::ipaddress} east-db2"],

      clusterData                => {
      east => { 'members' => 'east-db1,east-db2', 'connectors' => 'east-db1,east-db2', 'master' => 'east-db1' },
      } ,
      provisionNode             => true,
      provisionDonor           => 'east-db1'   ,
      installSSHKeys => true     ,
      connectorJDownload         => 'https://dl.dropboxusercontent.com/u/25417984/'    ,
      installCluster            => true,
      installTungstenRepo => true,
      tungstenRepoHost    => 'yumtest.continuent.com',
      tungstenRepoIp      => '23.21.169.95'
}