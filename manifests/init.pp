# == Class: continuent_install
#
# This is the main class to manage all the components of a Tungsten
# infrastructure. This is the only class that needs to be declared.
#
# === Parameters:
# Host Configuration Settings
# [*nodeHostName*]
#	 The FQDN for this host
# [*nodeIpAddress*]
# [*hostsFile*]
#	 IP for the Host
# [*installMysql*]
#	 Install and configure MySQL TRUE|FALSE
# [*mysqlPort*]
#	 MySQL Port
# [*mysqlServiceName*]
#	 Name of the mysql service MYSQL or MYSQLD normally
# [*serverId*]
#	 Server Id
# [*installHaproxy*]
#	 Install and configure support for HAProxy TRUE|FALSE
# [*haproxyUser*]
#	 MySQL User for HAProxy - will be created if it doesn't exist
# [*haproxyPassword*]
#	 MySQL password for HAProxy
# [*installMysqlj*]
#	 Install MySQLJ Driver TRUE|FALSE
# [*mysqljLocation*]
#	 Location to download MySQL/J Driver to
# [*provisionNode*]
#	 Provision the node with data MySQL TRUE/FALSE
# [*provisionDonor*]
#	 Slave to use as the donor
# [*installCluster*]
#	 Install and Configure Cluster TRUE|FALSE
# [*masterUser*]
#		 MySQL User for Cluster - will be created if it doesn't exist
# [*masterPassword*]
#	 MySQL password
# [*appUser*]
#		MySQL User for application - will be created if it doesn't exist
# [*appPassword*]
#	 MySQL password for HAProxy
# [*clusterData*]
#	 Configuration settings for the cluster
# [*connectorPort*]
#	 Port for Tungsten Connector
#
# Examples
#
# Install a node in a basic Cluster
#		class { 'continuent_install' :
#			nodeHostName								=> 'east-db1',
#			nodeIpAddress							 => "${::ipaddress}",
#			hostsFile									=> ["${::ipaddress}	east-db1",'192.168.0.146 east-db2''],
#
#			clusterData								=> {
#																	 east => { 'members' => 'east-db1,east-db2', 'connectors' => 'east-db1,east-db2', 'master' => 'east-db1' },
#																		},
#		}
#
# Install a node in a Multi-Site cluster where MySQL is already configured and running
#		 class { 'continuent_install' :
#				nodeHostName								=> 'east-db1',
#				nodeIpAddress							 => "${::ipaddress}",
#				hostsFile									=> ["${::ipaddress}	east-db1",'192.168.0.146 east-db2','192.168.0.147 west-db1','192.168.0.148 west-db2'],
#				clusterData								=> {
#										east => { 'members' => 'east-db1,east-db2', 'connectors' => 'east-db1,east-db2', 'master' => 'east-db1' },
#										west => { 'members' => 'west-db1,west-db2', 'connectors' => 'west-db1,west-db2', 'master' => 'west-db1' ,'relay-source'=> 'east'},
#																		},
#				compositeName							=> 'world',
#				installMysql							=> false
#			}
# === Copyright
#
# Copyright 2013 Continuent Inc.
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#		http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class continuent_install (
		$nodeHostName										= $fqdn,
		$nodeIpAddress									= $ipaddress,
		$hostsFile											= [],
		$installMysqlj									= true,
		$installRVM											= false,
		$replicatorRepo									= false,
		
		#Setting this to true should only be used to support 
		#testing as it's not secure
		$installSSHKeys									= false,
		
		$installMysql										= false,
		$installSandbox									= false,
		$installOracle									= false,
		
		# Not Working
		$installHaproxy									= false,
			$haproxyUser									= 'haproxy',
			$haproxyPassword							= 'secret',

		$installCluster									= false	,
			$replicationUser							= 'tungsten',
			$replicationPassword					= 'secret',
			$appUser											= 'app_user',
			$appPassword									= 'secret',
			$clusterData									= '',
			$connectorPort								= 3306,
			$compositeName								= '',
		$installReplicator							= false,
		$provisionNode									= false,
			$provisionDonor								= ''	,
			
		#This will override all the processing for the ini file as is should 
		#contain an array of entires to create the ini file from
		$tungstenIniContents						= '',
) {
	class{ "continuent_install::prereq":
		nodeHostName => $nodeHostName,
		nodeIpAddress => $nodeIpAddress,
		hostsFile => $hostsFile,
		replicatorRepo => $replicatorRepo,
		installMysqlj => $installMysqlj,
		installRVM => $installRVM,
		installSSHKeys => $installSSHKeys,
	}

	if $installMysql == true {
		include mysql
	}
	
	if $installSandbox == true {
		include mysql_sandbox
	}
	
	if $installOracle == true {
		include oracle
	}
	
	if $installCluster == true {
	
	}
	
	if $installReplicator == true {
	
	}

	if $installHaproxy == true {
		include haproxy
	}
}