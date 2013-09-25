# puppet-modules

## About

This module helps install [Continuent Tungsten](https://www.continuent.com) Database clustering software.


## Authors

* Neil Armitage


## Requirements

* Puppet = 3.2.7

## Examples

Install the module into /etc/puppet/modules/continuent-tungsten (will be available in puppetforge soon)

To install the Contunuent Tungsten prereqs run the module with the required parameters.

 ```puppet
 class { 'continuent_tungsten' :
       nodeHostName                => 'east-db1' ,
       nodeIpAddress               => "${::ipaddress}" ,
       hostsFile                  => ["${::ipaddress}  east-db1",'10.0.0.6 north-db1','10.0.0.7 north-db2','192.168.0.146 east-db2','192.168.0.147 west-db1','192.168.0.148 west-db2'],
       connectorJDownload         => 'http://yumtest.continuent.com/'
 }

 ```