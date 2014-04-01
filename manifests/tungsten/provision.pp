# == Class: tungsten::tungsten::provision See README.md for documentation.
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

class tungsten::tungsten::provision (
	$donor =  "autodetect",
) inherits tungsten::tungsten {
	exec { "tungsten::tungsten::provision":
		path => ["/bin", "/usr/bin", "/opt/continuent/tungsten/tungsten-replicator"],
		environment => "HOME=/root",
		logoutput => true,
		command => "/opt/continuent/tungsten/tungsten-replicator/scripts/tungsten_provision_slave --source=$donor --restore-to-datadir ",
	}
}