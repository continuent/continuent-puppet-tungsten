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

## Examples

### Install the module into your module directory

    puppet module install continuent/tungsten
    
### Install system prerequisites

    class { 'tungsten': }

### Install everything to allow installation

    class { 'tungsten' :
    	installSSHKeys => true,
    	installMysql => true,
    }

### With puppetlabs/mysql using stock MySQL

    # Remove unsafe users that can cause authentication errors
    mysql_user {
      [ "@${::fqdn}",
        '@localhost',
        '@%']:
      ensure  => 'absent',
      require => Anchor['mysql::server::end'],
    }

    class { 'mysql::server' :
      root_password => "MyPassword",
      override_options => {
        "mysqld" => {
          "bind_address" => "0.0.0.0",
          "server_id" => fqdn_rand(5000,$ipaddress),
          "pid-file" => "/var/lib/mysql/mysql.pid",
          "log-bin" => "mysql-bin",
          "port" => "13306",
        },
      },
      restart => true,
    } ->
    class { 'tungsten' : }
    
    # Make sure the tungsten system user can read MySQL binary logs
    User <| title == "tungsten::systemUser" |> { groups +> "mysql" }

### With puppetlabs/mysql using Percona MySQL

    class { 'percona_repo' : }
    
    # Remove unsafe users that can cause authentication errors
    mysql_user {
      [ "@${::fqdn}",
        '@localhost',
        '@%']:
      ensure  => 'absent',
      require => Anchor['mysql::server::end'],
    }

    class { 'mysql::server' :
      package_name => "Percona-Server-server-56",
      service_name => "mysql",
      root_password => "MyPassword",
      override_options => {
        "mysqld" => {
          "bind_address" => "0.0.0.0",
          "server_id" => fqdn_rand(5000,$ipaddress),
          "pid-file" => "/var/lib/mysql/mysql.pid",
          "log-bin" => "mysql-bin",
          "port" => "13306",
        },
      },
      restart => true,
    } ->
    class { 'mysql::client' :
      package_name => "Percona-Server-client-56",
    } ->
    class { 'tungsten' : }
    
    # Make sure the tungsten system user can read MySQL binary logs
    User <| title == "tungsten::systemUser" |> { groups +> "mysql" }
    
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