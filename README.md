# continuent-tungsten

## About

This module helps install [Continuent Tungsten](https://www.continuent.com) Database clustering software.
It also installs the pre-requisties for the open source Tungsten Replicator (www.tungsten-replicator.org)


## Authors

* Neil Armitage


## Requirements

* Puppet = 3.2.7

## Limitations

* Currently only RedHat RHEL/ Centos / AWS Linux

## Examples

Install the module into /etc/puppet/modules/tungsten (will be available in puppetforge soon)

To install the Contunuent Tungsten prereqs run the module with the required parameters.

 ```puppet
 class { 'tungsten' :
       nodeHostName                => 'east-db1' ,
       nodeIpAddress               => "${::ipaddress}" ,
       hostsFile                  => ["${::ipaddress},east-db1",'10.0.0.6,north-db1','10.0.0.7,north-db2','192.168.0.146,east-db2','192.168.0.147,west-db1','192.168.0.148,west-db2'],
       connectorJDownload         => 'http://yumtest.continuent.com/'
 }

 ```

 To install a node with the Continuent Tungsten software (required 2.0.1 or greater of the software available in an available yum repo)
  ```puppet
 class { 'tungsten' :
       nodeHostName                => 'east-db1' ,
       nodeIpAddress               => "${::ipaddress}" ,
       hostsFile                  => ["${::ipaddress},east-db1",'192.168.0.216,east-db2'],

       clusterData                => {
       east => { 'members' => 'east-db1,east-db2', 'connectors' => 'east-db1,east-db2', 'master' => 'east-db1' },
       } ,
       connectorJDownload         => 'http://yumtest.continuent.com/'  ,
       installSSHKeys => true,
       installCluster => true
 }

  ```
