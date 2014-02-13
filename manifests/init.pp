# == Class: tungsten
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
#	 MySQL password for App User
# [*clusterData*]
#	 Configuration settings for the cluster
# [*applicationPort*]
#	 Port for Tungsten Connector
#
# Examples
#
# Install a node in a basic Cluster
#		class { 'tungsten' :
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
#		 class { 'tungsten' :
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
class tungsten (
		$nodeHostName										= $fqdn,
		$nodeIpAddress									= $ipaddress,
		$hostsFile											= [],
		$installMysqlj									= true,
          $mysqljLocation                               = false,
		$installRVM											= false,
		$installJava										= true,
		$installNTP											= $tungsten::params::installNTP,
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
        #If this is set no setting of hostname will be done
        $skipHostConfig                             = false
		
) inherits tungsten::params {
	class{ "tungsten::prereq":
		nodeHostName => $nodeHostName,
		nodeIpAddress => $nodeIpAddress,
		hostsFile => $hostsFile,
		replicatorRepo => $replicatorRepo,
		installMysqlj => $installMysqlj,
        mysqljLocation => $mysqljLocation,
		installRVM => $installRVM,
		installSSHKeys => $installSSHKeys,
		installJava => $installJava,
		installNTP => $installNTP,
        skipHostConfig => $skipHostConfig
	}

	if $installMysql == true {
		include mysql
	}
	
	Class["tungsten::prereq"] ->
	class { "tungsten::tungsten":
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
}