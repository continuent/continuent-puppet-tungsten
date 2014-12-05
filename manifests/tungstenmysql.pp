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
	$masterUser			= $tungsten::tungstenmysql::params::masterUser,
	$masterPassword	= $tungsten::tungstenmysql::params::masterPassword,
	$port						= $tungsten::tungstenmysql::params::port,
	
	$serviceName		= $tungsten::tungstenmysql::params::serviceName,
  $overrideOptionsMysqld = {},
  $overrideOptionsClient = {},
  $overrideOptionsMysqldSafe = {},
  $serverPackageName = false,
  $clientPackageName = false,
) inherits tungsten::tungstenmysql::params  {
  include tungsten::prereq

  $fullOverrideOptionsMysqld=merge($tungsten::tungstenmysql::params::baseOverrideOptionsMysqld,$overrideOptionsMysqld)
  $fullOverrideOptionsClient=merge($tungsten::tungstenmysql::params::baseOverrideOptionsClient,$overrideOptionsClient)
  $fullOverrideOptionsMysqldSafe=merge($tungsten::tungstenmysql::params::baseOverrideOptionsMysqldSafe,$overrideOptionsMysqldSafe)

  if $serverPackageName == false {
    $fullServerPackageName =  $tungsten::tungstenmysql::params::baseServerPackageName
  } else {
    $fullServerPackageName =  $serverPackageName
  }

  if $clientPackageName == false {
    $fullClientPackageName =  $tungsten::tungstenmysql::params::baseClientPackageName
  } else {
    $fullClientPackageName =  $clientPackageName
  }


  class { 'percona_repo' : } ->
  class { 'mysql::server' :
    package_name => $fullServerPackageName,
    service_name => $tungsten::tungstenmysql::params::serviceName,
    root_password => $tungsten::tungstenmysql::params::masterPassword,
    override_options => {
          'mysqld'       =>  $fullOverrideOptionsMysqld,
          'mysqld_safe'  =>  $fullOverrideOptionsMysqldSafe,
          'client'       =>  $fullOverrideOptionsClient},
    restart => true,
    require => Class['tungsten::tungstenselinux'],
  } ->
	Class["tungsten::prereq"]
	
	User <| title == "tungsten::systemUser" |> { groups +> "mysql" }
}
