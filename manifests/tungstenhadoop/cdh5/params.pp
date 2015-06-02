# == Class: tungsten::tungstenhadoop::cdh5::params See README.md for documentation.
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

class tungsten::tungstenhadoop::cdh5::params (
) {
  if $architecture != "x86_64" {
    fail("The ${module_name} module is not able to install ${architecture}.")
  }
  
	if ($operatingsystem =~ /(?i:centos|redhat|oel|OracleLinux|amazon)/) {
	  if ($operatingsystem =~ /(?i:amazon)/) {
      $repo = "http://archive.cloudera.com/cdh5/one-click-install/redhat/${::epel_version}/${::architecture}/cloudera-cdh-5-0.${::architecture}.rpm"
    } else {
      $repo = "http://archive.cloudera.com/cdh5/one-click-install/redhat/${::operatingsystemmajrelease}/${::architecture}/cloudera-cdh-5-0.${::architecture}.rpm"
    }
	  
	} elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
    fail("The ${module_name} module is not supported on an ${::operatingsystem} based system.")
	} else {
		fail("The ${module_name} module is not supported on an ${::operatingsystem} based system.")
	}
}
