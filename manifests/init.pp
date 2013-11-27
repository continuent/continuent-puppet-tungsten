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
# [*connectorJVersion*]
#	 MySQL/J Version to download
# [*connectorJDownload*]
#	 Location to Download the MySQL/J from
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
#			nodeHostName								=> 'east-db1' ,
#			nodeIpAddress							 => "${::ipaddress}" ,
#			hostsFile									=> ["${::ipaddress}	east-db1",'192.168.0.146 east-db2''],
#
#			clusterData								=> {
#																	 east => { 'members' => 'east-db1,east-db2', 'connectors' => 'east-db1,east-db2', 'master' => 'east-db1' },
#																		} ,
#			connectorJDownload				 => 'http://yumtest.continuent.com/'
#		}
#
# Install a node in a Multi-Site cluster where MySQL is already configured and running
#		 class { 'continuent_install' :
#				nodeHostName								=> 'east-db1' ,
#				nodeIpAddress							 => "${::ipaddress}" ,
#				hostsFile									=> ["${::ipaddress}	east-db1",'192.168.0.146 east-db2','192.168.0.147 west-db1','192.168.0.148 west-db2'],
#				clusterData								=> {
#										east => { 'members' => 'east-db1,east-db2', 'connectors' => 'east-db1,east-db2', 'master' => 'east-db1' },
#										west => { 'members' => 'west-db1,west-db2', 'connectors' => 'west-db1,west-db2', 'master' => 'west-db1' ,'relay-source'=> 'east'},
#																		} ,
#				compositeName							=> 'world' ,
#				connectorJDownload				 => 'http://yumtest.continuent.com/',
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
	$nodeHostName									 = $fqdn ,
	$nodeIpAddress									= "${::ipaddress}" ,
	$hostsFile											= [],
	$installMysql									 = false ,
		$mysqlPort										= 13306,
		$mysqlServiceName						 = 'mysqld'	,
	$installHaproxy								 = false,
		$haproxyUser									= 'haproxy',
		$haproxyPassword							= 'secret',
	$installMysqlj									= true,
		$mysqljLocation							 = "/opt/mysql/mysql-connector-java-5.1.26-bin.jar",
		$connectorJVersion						= '5.1.26' ,
	$provisionNode									= false ,
		$provisionDonor							 = ''	,
	$installCluster								 = false	,
		$masterUser									 = 'root' ,
		$masterPassword							 = 'secret'	 ,
		$replicationUser							= 'tungsten' ,
		$replicationPassword					= 'secret' ,
		$appUser											= 'app_user'	,
		$appPassword									= 'secret' ,
		$clusterData									= '' ,
		$connectorPort								= 3306 ,
		$compositeName								= '',
	#This will override all the processing for the ini file as is should contain
	#an array of entires to create the ini file from
	$tungstenIniContents						= '',
	$installTungstenRepo						= 'false',
		$tungstenRepoHost						 = '',
		$tungstenRepoIp							 = '',
	$installSandbox								 = 'false',
		$sandboxVersion							 = '3.0.42',
	$installRvm										 = 'false',
	$installReplicator							= 'false',
		$replicatorRepo							 = 'stable',

	#Setting this to true should only be used to support testing as it's not secure
	$installSSHKeys								 = false
) {
	#See if the passed ini file contains any user or password details
	$int_replicationUser=getReplicationUser($replicationUser,$tungstenIniContents)
	$int_replicationPassword=getReplicationPassword($replicationPassword,$tungstenIniContents)

	$int_appUser=getApplicationUser($appUser,$tungstenIniContents)
	$int_appPassword=getApplicationPassword($appPassword,$tungstenIniContents)

	if $installMysql == true {
		if $masterPassword == 'secret' {
			warning 'The default master password is being used'
		}
		if $appPassword == 'secret' {
			warning 'The default application password is being used'
		}
		if $replicationPassword == 'secret' {
			warning 'The default replication password is being used'
		}
	}

	if $installHaproxy == true {
		if $haproxyPassword == 'secret' {
			warning 'The default haproxy password is being used'
		}
	}

	include unix_user

	if $installMysql == true {
		#Generate ServerId based on IP
		#$serverId=generateServerId($nodeIpAddress)
        $serverId=fqdn_rand(5000,$nodeIpAddress)
		include mysql_install
	}

	if $installMysqlj == true {
		include mysqlj_install
	}
	else
	{
		if $mysqljLocation == '' {
			warning 'No mysql/j location specified and mysqlj_install is set to false'
		}
	}

	if $installTungstenRepo == true {
		include tungsten_repo
	}

	include tungsten_config
	include tungsten_hosts
	include ntp
	include set_hostname

	if $installCluster == true	{
		if $clusterData == '' {
			warning 'Missing Cluster data - unable to install cluster'
		}

		$clusterName=getClusterName($clusterData,$nodeHostName)
		$compositeDS=getCompositeDS($clusterData)
		include tungsten_install
		if $installHaproxy == true {
			include haproxy
		}
		if $provisionNode == true {
			include provision_node
		}
	}

	if $installSandbox == true {
		include sandbox_install
	}

	if $installRvm == true {
		include rvm_install
	}

	if $installReplicator == true {
		include install_replicator
	}
}
