# == Class: tungsten::tungstenhadoop See README.md for documentation.
#
# Copyright (C) 2015 VMware, Inc.
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

class tungsten::tungstenvertica (
	$package = false,
	$databaseName = false,
	$password = "secret"
) inherits tungsten::tungstenvertica::params {
  anchor{"tungsten::tungstenvertica::prereq": }
  anchor{"tungsten::tungstenvertica::end": }
  
  if $package == false {
    # Do nothing
  } else {
    exec { "disable_transparent_hugepage_enabled":
      command => "/bin/echo never > /sys/kernel/mm/transparent_hugepage/enabled",
      unless  => "/bin/grep -c '\[never\]' /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null",
    } ->
    exec { "enable_deadline_scheduler":
      command => "/bin/echo deadline > /sys/block/sda/queue/scheduler",
      unless  => "/bin/grep -c '\[deadline\]' /sys/block/sda/queue/scheduler 2>/dev/null",
    } ->
    exec { "enable_readahead":
      command => "/sbin/blockdev --setra 2048 /dev/sda1",
    } ->
    package {"mcelog": 
      ensure=>present
    } ->
    group { "verticadba": 
      ensure => present,
    } ->
    user { "dbadmin":
      gid => 'verticadba',
      shell => "/bin/bash",
      ensure => present,
    } ->
    file { "/home/dbadmin":
      path =>  '/home/dbadmin',
      ensure => "directory",
      owner => 'dbadmin',
      group => 'verticadba',
    } ->
    Anchor["tungsten::tungstenvertica::prereq"] ->
    file { "vertica-package" :
      path => $package,
      ensure => present
    } ->
    package { "vertica" : 
      source => $package,
      provider => $tungsten::tungstenvertica::params::provider
    } ~>
    exec { 'install-vertica':
      command => "/opt/vertica/sbin/install_vertica --hosts $fqdn -u dbadmin --failure-threshold HALT --license CE --accept-eula",
      logoutput => "on_failure",
      refreshonly => true,
    } ->
    service {"verticad":
  	  ensure => "running",
  	  enable => true
  	} ->
  	service {"vertica_agent":
  	  ensure => "running",
  	  enable => true
  	} ->
  	file { "/home/dbadmin/create-vertica-db":
      ensure => file,
      owner => 'dbadmin',
      mode => 700,
      content => template('tungsten/tungsten_create_vertica_db.erb'),
    } ~>
  	exec { 'create-vertica-db':
  	  command => "/bin/su -c /home/dbadmin/create-vertica-db - dbadmin",
  	  logoutput => "on_failure",
  	  creates => "/home/dbadmin/$databaseName"
  	} ->
    Anchor["tungsten::tungstenvertica::end"]
  }
}