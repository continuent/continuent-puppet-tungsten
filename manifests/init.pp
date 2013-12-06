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
# [*installHaproxy*]
#	 Install and configure support for HAProxy TRUE|FALSE
# [*haproxyUser*]
#	 MySQL User for HAProxy - will be created if it doesn't exist
# [*haproxyPassword*]
#	 MySQL password for HAProxy
# [*installMysqlj*]
#	 Install MySQLJ Driver TRUE|FALSE
# [*provisionNode*]
#	 Provision the node with data MySQL TRUE/FALSE
# [*provisionDonor*]
#	 Slave to use as the donor
# [*installClusterSoftware*]
#	 Install and Configure Cluster TRUE|FALSE
# [*appUser*]
#		MySQL User for application - will be created if it doesn't exist
# [*appPassword*]
#	 MySQL password for HAProxy
# [*clusterData*]
#	 Configuration settings for the cluster
# [*applicationPort*]
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
		$installJava									= true,
		$installNTP										= true,
		$replicatorRepo									= false,
		
		#Setting this to true should only be used to support 
		#testing as it's not secure
		$installSSHKeys									= false,
		
		$installMysql										= false,
		$installSandbox									= false,
		
		$installReplicatorSoftware			= false,
			$replicationUser							= tungsten,
			$replicationPassword					= secret,
		$installClusterSoftware					= false,
			$clusterData									= false,
			$compositeName								= false,
			$appUser											= app_user,
			$appPassword									= secret,
			$applicationPort							= 3306,
		$provisionNode									= false,
			$provisionDonor								= false,
		#This will override all the processing for the ini file as is should 
		#contain an array of entires to create the ini file from
		$tungstenIniContents						= false,
		
		$installHaproxy									= false,
			$haproxyUser									= 'haproxy',
			$haproxyPassword							= 'secret',
) {
	anchor{ "continuent_install::dbms": }
	
	class{ "continuent_install::prereq":
		nodeHostName => $nodeHostName,
		nodeIpAddress => $nodeIpAddress,
		hostsFile => $hostsFile,
		replicatorRepo => $replicatorRepo,
		installMysqlj => $installMysqlj,
		installRVM => $installRVM,
		installSSHKeys => $installSSHKeys,
		installJava => $installJava,
		installNTP => $installNTP,
	}

	if $installMysql == true {
		class{ "continuent_install::mysql": } ->
		Anchor["continuent_install::dbms"]
	}
	
	if $installSandbox == true {
		class{ "continuent_install::mysql_sandbox": } ->
		Anchor["continuent_install::dbms"]
	}
	
	Anchor["continuent_install::dbms"] ->
	class { "continuent_install::tungsten":
		installReplicatorSoftware 			=> $installReplicatorSoftware,
			repUser 											=> $replicationUser,
			repPassword 									=> $replicationPassword,
		installClusterSoftware 					=> $installClusterSoftware,
			clusterData 									=> $clusterData,
			compositeName 								=> $compositeName,
			appUser 											=> $appUser,
			appPassword 									=> $appPassword,
			applicationPort 							=> $applicationPort,
		tungstenIniContents 						=> $tungstenIniContents,
		provision 											=> $provisionNode,
			provisionDonor 								=> $provisionDonor,
	}

	if $installHaproxy == true {
		class{"continuent_install::haproxy":
			require => Class["continuent_install::tungsten"]
		}
	}
}