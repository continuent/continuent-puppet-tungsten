# == Class: tungsten::oracle See README.md for documentation.
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

class tungsten::tungstenoracle (
	$oracleVersion                      = '12',
	$oracleBinaries											= '/vagrant/downloads'
)   {


    class { 'oracle' :
      oracleVersion => $oracleVersion,
			installFiles => $oracleBinaries
  	}->
		exec {"tungsten-oinstall":
		  unless => "/bin/grep -q 'oinstall\\S*tungsten ' /etc/group",
		  command => "/usr/sbin/usermod -aG oinstall tungsten",
		  require => [User['tungsten'],Group['oinstall']]
		}

}
