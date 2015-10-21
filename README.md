# continuent-tungsten

## About

This module helps install [Continuent Tungsten](https://www.continuent.com) Database clustering software. It also installs the pre-requisites for the open source [Tungsten Replicator](http://www.tungsten-replicator.org).

## Authors

* Neil Armitage
* Jeff Mace

## Requirements

* Puppet = 3.2.7

## Limitations

* Currently supports RedHat RHEL/ Centos / AWS Linux / Debian / Ubuntu

## Supported Operating Systems

* Centos5->7
* Ubuntu 10.04,12.04 and 14.04
* Debian Wheezy and Squeeze
* Amazon AWS Linux

It may work on other platform but it has not been tested against them

* SLES12 is supported for pre-requisites only, MySQL installs do not work


## Supported MySQL Builds

* Percona 5.5 and 5.6
* MySQL 5.5 and 5.6
* MariaDB 5.5 and 10.0

Yum and Apt repositories will be installed from these builds and packages installed from them based on the mySQLBuild and mySQLVerson parameters. By default Percona 5.5 will be installed if no values are provided.

## Examples

### Install the module into your module directory

    puppet module install continuent/tungsten

### Install system prerequisites

    class { 'tungsten': }

### Install everything to allow installation

    class { 'tungsten' :
    	installSSHKeys => true,
    	installMysql => true,
      mySQLBuild => 'mysql|percona|mariadb',
      mySQLVersion => "5.5|5.6|10.0"
    }

### Installing Continuent Tungsten

    $clusterData = {
    	"east" => {
    		"topology" => "clustered",
    		"master" => "db1",
    		"slaves" => "db2,db3",
    		"connectors" => "db1,db2,db3",
    	},
    }
    class { 'tungsten' :
    	installSSHKeys => true,
    	installMysql => true,
      mySQLBuild => 'mysql|percona|mariadb',
      mySQLVersion => "5.5|5.6|10.0",
    	clusterData => $clusterData,
    	installClusterSoftware => "/root/continuent-tungsten-2.0.1-1002.rpm",
    }

### Installing Tungsten Replicator

This will install the latest stable version of Tungsten Replicator with master-slave replication from db1 to db2 and db3.

    $clusterData = {
    	"east" => {
    		"topology" => "master-slave",
    		"master" => "db1",
    		"slaves" => "db2,db3",
    	},
    }
    class { 'tungsten' :
    	installSSHKeys => true,
    	installMysql => true,
      mySQLBuild => 'mysql|percona|mariadb',
      mySQLVersion => "5.5|5.6|10.0",
    	clusterData => $clusterData,
    	replicatorRepo => "stable",
    	installReplicatorSoftware => true,
    }



### Using a custom SSH key for the tungsten user

Generate a new keypair if you don't already have one.

    $> ssh-keygen -t rsa -f tu -N '' -C 'Tungsten University' > /dev/null; cat tu; cat tu.pub; rm tu; rm tu.pub

Add the public and private key to your Puppet manifest. Do not include "ssh-rsa" or the trailing comment in the text of the public key.

    $sshPublicKey = "....."
    $sshPrivateCert = "-----BEGIN RSA PRIVATE KEY-----
    .....
    -----END RSA PRIVATE KEY-----"

    class { 'tungsten' :
      sshPublicKey => $sshPublicKey,
      sshPrivateCert => $sshPrivateCert,
    }

### Adding your public key to the tungsten user

Copy in the value of your SSH public key. Do not include "ssh-rsa" or the trailing comment in the text of the public key.

    $myPublicKey = "....."
    ssh_authorized_key { "my.tungsten.key":
      user => tungsten,
      type => rsa,
      key => $myPublicKey,
    }

## Changing the MySQL Data directory

  ```
  class { 'tungsten' :
    installSSHKeys => true,
    installMysql => true,
    mySQLBuild => 'mysql|percona|mariadb',
    mySQLVersion => "5.5|5.6|10.0",
    overrideOptionsMysqld=>{'datadir'=>'/data'}
  }
  ```

## Changing the MySQL Binary Log Directory

```
  class { 'tungsten' :
    installSSHKeys => true,
    installMysql => true,
    mySQLBuild => 'mysql|percona|mariadb',
    mySQLVersion => "5.5|5.6|10.0",
    overrideOptionsMysqld=>{'log-bin'=>'/logs/mysql-bin'}
  }
  ```

## Changing the MySQL Data directory and Binlog dir
  ```
  class { 'tungsten' :
    installSSHKeys => true,
    installMysql => true,
    mySQLBuild => 'mysql|percona|mariadb',
    mySQLVersion => "5.5|5.6|10.0",
    overrideOptionsMysqld=>{'datadir'=>'/data','log-bin'=>'/logs/mysql-bin'}
  }
  ```

## Changing MySQL Properties

All values in my.cnf can be overridden by values in the following hashs

* overrideOptionsMysqld ( [mysqld] section )
* overrideOptionsMysqldSafe ( [mysqld_safe] section )
* overrideOptionsMysqlClient ( [client] section)

The module already has the following values for the mysqld section

```
  $baseOverrideOptionsMysqld =  {
    'bind_address' => '0.0.0.0',
    'server_id' => fqdn_rand(1073741824),
    'pid-file' => '/var/lib/mysql/mysql.pid',
    'log-bin' => '/var/lib/mysql/mysql-bin',
    'binlog-format' => 'MIXED',
    'port' => $port,
    'open_files_limit' => '65535',
    'sync_binlog' => '2',
    'max_allowed_packet' => '64m',
    'auto_increment_increment' => 1,
    'auto_increment_offset' => 1,
    'innodb_file_per_table' => true,
    'datadir'=> '/var/lib/mysql'
  }
```

The client and mysqld_safe sections have no default values. Any value passed in are merged with these default values

e.g. to override the port

```
  class { 'tungsten' :
    installSSHKeys => true,
    installMysql => true,
    mySQLBuild => 'mysql|percona|mariadb',
    mySQLVersion => "5.5|5.6|10.0",
    overrideOptionsMysqld=>{'port'=>'3306'}
  }
  ```

## Setting AutoIncrement and AutoIncrement offset automatically

The auto_increment_increment and auto_increment_offset can be determined automatically from the supplied clusterData by setting the mySQLSetAutoIncrement flag to true. This then used the Functions described below to determine the correct values

```
    $clusterData = {
      "east" => {
        "topology" => "master-slave",
        "master" =>  db1,
        "slaves" => "db2,db3",
        },
      }

  class { 'tungsten':
      installSSHKeys => true,
      installMysql=> true,
      mySQLSetAutoIncrement=> true,
      clusterData=>$clusterData }

```

## Installing XtraBackup

By default if selected the module will determine were to install it from automatically. If installing Percona MySQL it will install it from the Percona repo otherwise it will download the required RPM or DEB from the Percona Website.

If required it can be download or use a rpm/deb from a private location

```

  class { 'tungsten':
      installSSHKeys => true,
      installMysql=> true,
      xtraBackupPackage=>'/mnt/nfs/xtrabackup-x.x.x.rpm' or 'http://192.168.2.300/xtrabackup-x.x.x.rpm',
      clusterData=>$clusterData }

```

## Installing with local Ruby gems

By default the gems will be installed from www.rubygems.org. If this is blocked the gems can be installed from a local directory. Copies of the gems required can be found in the tests/local_gems directory in github.

```
class { 'tungsten': installSSHKeys => true, installMysql=> true,
      disableFirewall=> false, skipHostConfig=> true,docker => true ,
      xtraBackupPackage=>'/mnt/xtrabackup/percona-xtrabackup-2.2.12-1.el6.x86_64.rpm'  ,
      installGems										=> 'local',
  		localGemLocation							=> '/mnt/gem/' }

```

The following gems need to be in the local file system specified in localGemLocation=>

```
zip-2.0.2.gem
xhr-ifconfig-1.2.3.gem
open4-1.3.4.gem
net-ssh-2.9.2.gem
net-scp-1.2.1.gem
escape-0.0.4.gem
continuent-tools-core-0.11.0.gem
continuent-tools-monitoring-0.7.0.gem
json_pure-1.8.2.gem
continuent-monitors-nagios-0.7.0.gem
```

## Integration with custom MySQL classes

The continuent/tungsten module is compatible with the puppetlabs/mysql module. See examples above on how to use it. If you have an existing method for configuring MySQL, it is simple to update it so the continuent/tungsten module recognizes it.

* Add "anchor{ 'mysql::server::end': }" to your module so that it is dependent on the MySQL server running. We use this anchor to identify that the tungsten system user should be added to the MySQL system group and to set the proper dependencies.
* Create a "file { '${::root_home}/.my.cnf': .. }" resource that allows the root user to connect to MySQL. The file should be created with the 600 mode, or it can be created before the tungsten class and destroyed afterward. We will use this to create the replication and application users. If it is not present, you are responsible for creating these users on your own.

## Functions

### getTungstenAvailableMasters

Extract an array of possible masters from a $clusterData hash object. The hostnames are extracted by looking for the keys: master, masters, slaves, members and dataservice-hosts. After the list is identified, it is reduced to eliminate duplicates and sorted.

If a valid list cannot be determined, an empty array is returned.

### getMySQLAutoIncrementIncrement

Calculate the value for the MySQL auto\_increment\_increment setting. The function takes a single argument that is either a valid $clusterData hash or an array of hostnames that may be masters. This function uses the getTungstenAvailableMasters function to get a valid list of possible masters.

If a valid value cannot be determined, the value 1 is returned.

    $clusterData = {
    	"east" => {
    		"topology" => "master-slave",
    		"master" => "db1",
    		"slaves" => "db2,db3",
    	},
    }
    getMySQLAutoIncrementIncrement($clusterData)

    $possibleMasters = ["db1", "db2", "db3"]
    getMySQLAutoIncrementIncrement($clusterData)

### getMySQLAutoIncrementOffset

Calculate the value for the MySQL auto\_increment\_offset setting. The function takes two arguments. The first is either a valid $clusterData hash or an array of hostnames that may be masters. The second is the hostname to search for to determine the offset. This function uses the getTungstenAvailableMasters function to get a valid list of possible masters.

If a valid value cannot be determined, the value 1 is returned.

    $clusterData = {
    	"east" => {
    		"topology" => "master-slave",
    		"master" => "db1",
    		"slaves" => "db2,db3",
    	},
    }
    getMySQLAutoIncrementOffset($clusterData, $::fqdn)

    $possibleMasters = ["db1", "db2", "db3"]
    getMySQLAutoIncrementOffset($possibleMasters, $::fqdn)

## Current Known Limitations

* SELinux needs to be disabled on Centos5 before running the module.
* MySQL 5.7 does not install at the moment owing to issues with the puppetlabs-mysql module
* If you are installing any version of MySQL on Centos7 other than MariaDB the puppetlabs module forces the directories to be MariaDB specific so the following directories have to be created
** /var/log/mariadb
** /var/run/mariadb

### Xtrabackup
Currently xtrabackup will be installed on the following operating systems
* Centos6
* Ubuntu 10.04, 12.04, 14.04
* Debian wheezy and squeeze

It is currently not possible to install it automatically on the following operating systems, if it is required it will need to be installed via an alternative way
* Centos5
