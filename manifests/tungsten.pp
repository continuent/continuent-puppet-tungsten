# == Class: tungsten::tungsten See README.md for documentation.
#
# Copyright (C) 2014 Continuent, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.  You may obtain
# a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

class tungsten::tungsten (
	# Set this to true if you are not passing $clusterData
	# and want the /etc/tungsten/defaults.tungsten.ini file
	# to be created
	$writeTungstenDefaults			= false,

  # Set this to 'true' or the path of a tungsten-replicator package
	# If set to 'true', the 'tungsten-replicator' will be installed from
	# configured repositories.
	$installReplicatorSoftware	      = false,
		$repUser						            = tungsten,
		$repPassword				            = secret,
		$replicationLogDirectory	= false,
	$installOracle										= false,

  # Set this to 'true' or the path of a continuent-tungsten package
	# If set to 'true', the 'continuent-tungsten' will be installed from
	# configured repositories.
	$installClusterSoftware			      = false,
		$clusterData									  = false,
		$appUser										  	= app_user,
		$appPassword								  	= secret,
		$applicationPort						  	= 3306,

	$installRedoReaderSoftware			= false,
			$redoReaderUser 							= tungsten,
			$redoReaderPassword	   				= secret,
			$oracleSysPassword						= password,
			$oracleSystemPassword				= password,
			$oracleSID										= 'orcl',
			$redoReaderTopology				= false,
			$redoReaderMaster					= db1,
			$readReaderSlave					= db2,

	# Run the `tungsten_provision_slave` script after installing Tungsten
	$provision								      	= false,
	  $provisionDonor						    	= "autodetect",
) inherits tungsten::params {
	include tungsten::prereq

	if $clusterData != false or $redoReaderTopology != false {
		class{ "tungsten::tungsten::ini": installRedoReaderSoftware=>$installRedoReaderSoftware, redoReaderTopology=>$redoReaderTopology }->
		anchor{ "tungsten::tungsten::ini": }

    # Scheduling updates to existing installations must be done
    # before the clustering or replication software is installed.
    # If not, `tpm update` will be run twice during the initial
    # installation process.
    class{ "tungsten::tungsten::update": } ->
		Anchor["tungsten::tungsten::cluster"]
	} elsif $writeTungstenDefaults == true {
		class{ "tungsten::tungsten::defaultsini": }->
		anchor{ "tungsten::tungsten::ini": }
	} else {
		anchor{ "tungsten::tungsten::ini": }
	}

	# Create the replicationLogDirectory if specified
	if $replicationLogDirectory != false {
		Class["tungsten::prereq"] ->
		exec { "mkdir-replicationLogDirectory":
			command => "/bin/mkdir -p ${replicationLogDirectory}"
		} ->
		exec { "chown-replicationLogDirectory":
			command => "/bin/chown -R ${tungsten::prereq::systemUserName}: ${replicationLogDirectory}"
		}
	}

	# The /root/.my.cnf file is created by tungsten::mysql and mysql::server classes
	if defined(File["${::root_home}/.my.cnf"]) {
	  Anchor["tungsten::tungsten::ini"] ->
		file { "${::root_home}/tungsten_create_users":
      ensure => file,
      owner => 'root',
      mode => 700,
      content => template('tungsten/tungsten_create_users.erb'),
    } ~>
		exec { "tungsten_create_users":
			command => "${::root_home}/tungsten_create_users",
			refreshonly => true,
		} ->
		anchor{ "tungsten::tungsten::create-users": }

		# If tungsten::mysql isn't being used, the anonymous users need to
		# be removed from the mysql.user table
		if ! defined(Exec["tungsten-mysql-remove-anon-users"]) {
    	$sqlCheckAnonUsers	= "select * from mysql.user where user=''"
    	$sqlExecAnonUsers		= "delete from mysql.user where user='';flush privileges;"

    	Exec["tungsten_create_users"] ->
    	exec { "tungsten-tungsten-remove-anon-users":
    		onlyif	=> ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/test `/usr/bin/mysql --defaults-file=${::root_home}/.my.cnf -Be \"$sqlCheckAnonUsers\"|wc -l` -gt 0"],
    		command => "/usr/bin/mysql --defaults-file=${::root_home}/.my.cnf -Be \"$sqlExecAnonUsers\"",
    	} ->
  	  Anchor["tungsten::tungsten::create-users"]
  	}
	} else {
	  Anchor["tungsten::tungsten::ini"] ->
		anchor{ "tungsten::tungsten::create-users": }
	}

	if $installOracle == true {
		file { "/home/oracle/tungsten_create_users_oracle":
      ensure => file,
      owner => 'oracle',
      mode => 700,
      content => template('tungsten/tungsten_create_users_oracle.erb'),
    } ~>
		exec { "tungsten_create_users_oracle":
			command => "/usr/bin/sudo -u oracle /home/oracle/tungsten_create_users_oracle",
			require => Exec['start_oracle'],
			refreshonly => true,
		}

	}

	if $installClusterSoftware != false {
	  Anchor["tungsten::tungsten::create-users"] ->
		class{ "tungsten::tungsten::cluster":
			location => $installClusterSoftware,
		} ->
		anchor{ "tungsten::tungsten::cluster": }
	} else {
	  Anchor["tungsten::tungsten::create-users"] ->
		anchor{ "tungsten::tungsten::cluster": }
	}

	if $installReplicatorSoftware != false {
	  Anchor["tungsten::tungsten::cluster"] ->
		class{ "tungsten::tungsten::replicator":
			location => $installReplicatorSoftware,
		} ->
		anchor{ "tungsten::tungsten::replicator": }
	} else {
	  Anchor["tungsten::tungsten::cluster"] ->
		anchor{ "tungsten::tungsten::replicator": }
	}

	if $installRedoReaderSoftware != false {
		Anchor["tungsten::tungsten::cluster"] ->
		class{ "tungsten::tungsten::redoreader":
			location => $installRedoReaderSoftware,
		} ->
		anchor{ "tungsten::tungsten::redoreader": }
	}

	if $provision == true {
    Anchor["tungsten::tungsten::replicator"] ->
		class{ "tungsten::tungsten::provision":
			donor => $provisionDonor,
		}
	}

	if defined(File["/etc/mysql/conf.d"]) {
	  File["/etc/mysql/conf.d"] -> Class["tungsten::tungsten"]
	}

	if defined(Anchor["mysql::server::end"]) {
    Anchor["mysql::server::end"] -> Class["tungsten::tungsten"]
  }

	if defined(Anchor["tungsten::tungstenhadoop::end"]) {
	  Anchor["tungsten::tungstenhadoop::end"] -> Class["tungsten::tungsten"]
	}
}
