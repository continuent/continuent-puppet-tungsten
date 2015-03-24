# == Class: tungsten::prereq::repo See README.md for documentation.
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

class tungsten::prereq::repo(
	$replicatorRepo							= false,
) {
  if ($operatingsystem =~ /(?i:centos|redhat|oel|OracleLinux|amazon)/) {
		if $replicatorRepo == "nightly" {
  		$url = "http://releases.continuent.com.s3.amazonaws.com/replicator-release-nightly-0.0-1.noarch.rpm"
  	} elsif $replicatorRepo == "stable" {
  		$url = "http://releases.continuent.com.s3.amazonaws.com/replicator-release-stable-0.0-1.noarch.rpm"
  	} elsif $replicatorRepo == true {
  		$url = "http://releases.continuent.com.s3.amazonaws.com/replicator-release-stable-0.0-1.noarch.rpm"
  	} else {
  		$url = false
  	}

  	if $url != false {
  		package { "replicator-release-$replicatorRepo":
  			provider => "rpm",
  			ensure => present,
  			source => $url,
  		}
  	}
	} elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
		if $replicatorRepo == "nightly" {
  		$url = "http://apt-nightly.tungsten-replicator.org/"
  		$release = "nightly"
  	} elsif $replicatorRepo == "stable" {
  		$url = "http://apt.tungsten-replicator.org/"
  		$release = "stable"
  	} elsif $replicatorRepo == true {
    		$url = "http://apt.tungsten-replicator.org/"
    		$release = "stable"
  	} else {
  		$url = false
  	}

  	if $url != false {
  		apt::source { 'continuent':
    		ensure => present,
    		include_src => false,
    		location => $url,
    		release => $release,
    		repos => 'main',
    		key => "7206C924",
    	}
  	}
	} else {
	  if $replicatorRepo != false {
		  fail("The ${module_name} module is not supported on an ${::operatingsystem} based system.")
		}
	}
}
