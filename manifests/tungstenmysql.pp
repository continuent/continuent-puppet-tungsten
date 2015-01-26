# == Class: tungsten::mysql See README.md for documentation.
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

class tungsten::tungstenmysql (
	$masterUser													= $tungsten::tungstenmysql::params::masterUser,
	$masterPassword											= $tungsten::tungstenmysql::params::masterPassword,
  $overrideOptionsMysqld 							= {},
  $overrideOptionsClient 							= {},
  $overrideOptionsMysqldSafe 					= {},
  $installMysql 											= false,
	$mySQLBuild											    = false,
	$mySQLVersion				   					    = false,
	$disableSELinux											= true,
	$clusterData												= nil,
	$mySQLSetAutoIncrement												= false,
	$installXtrabackup								  = true,
) inherits tungsten::tungstenmysql::params  {

  if $installMysql == true {

		if $mySQLSetAutoIncrement == true {
			 $autoInc=getMySQLAutoIncrementIncrement($clusterData)
			 $autoOffset=getMySQLAutoIncrementOffset($clusterData, $::fqdn)
			 $autoSettings={'auto_increment_increment'=>$autoInc,'auto_increment_offset'=>$autoOffset}
			 $tmpOverrideOptionsMysqld=merge($overrideOptionsMysqld,$autoSettings)
			 $fullOverrideOptionsMysqld=merge($tungsten::tungstenmysql::params::baseOverrideOptionsMysqld,$tmpOverrideOptionsMysqld)
		}else {
    	$fullOverrideOptionsMysqld=merge($tungsten::tungstenmysql::params::baseOverrideOptionsMysqld,$overrideOptionsMysqld)
		}

    $fullOverrideOptionsClient=merge($tungsten::tungstenmysql::params::baseOverrideOptionsClient,$overrideOptionsClient)
    $fullOverrideOptionsMysqldSafe=merge($tungsten::tungstenmysql::params::baseOverrideOptionsMysqldSafe,$overrideOptionsMysqldSafe)

		class { 'tungsten::tungstenmysql::centos7dirs' : } ->
    class { 'tungsten::tungstenmysql::tungstenrepo' :
					mySQLBuild				 => $mySQLBuild,
					mySQLVersion			 => $mySQLVersion
		}->
    class { 'mysql::server' :
      package_name => getMySQLPackageName('server',$mySQLBuild,$mySQLVersion),
      service_name => getMySQLServiceName($mySQLBuild,$mySQLVersion),
      root_password => $tungsten::tungstenmysql::params::masterPassword,
      config_file => $tungsten::tungstenmysql::params::configFileName,
      override_options => {
      'mysqld'       =>  $fullOverrideOptionsMysqld,
      'mysqld_safe'  =>  $fullOverrideOptionsMysqldSafe,
      'client'       =>  $fullOverrideOptionsClient},
      restart => true,
    } ->
		class { 'tungsten::tungstenmysql::xtrabackup' : installXtrabackup => $installXtrabackup }

    User <| title == "tungsten::systemUser" |> { groups +> "mysql" }
  }
}
