# == Class: tungsten::tungstenvertica::params See README.md for documentation.
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

class tungsten::tungstenvertica::params (
) {
	if ($operatingsystem =~ /(?i:centos|redhat|oel|OracleLinux|amazon|SLES)/) {
    # Do nothing
    $provider = "rpm"
	} elsif ($operatingsystem =~ /(?i:debian|ubuntu)/) {
	  # Do nothing
	  $provider = "dpkg"
	} else {
		fail("Installing Vertica in the ${module_name} module is not supported on an ${::operatingsystem} based system.")
	}
}
