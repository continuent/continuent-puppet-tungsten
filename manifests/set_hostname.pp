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
class set_hostname {
	file { "/etc/hostname":
		ensure => present,
		owner => root,
		group => root,
		mode => 644,
		content => "$::continuent_install::nodeHostName\n",
		notify => Exec["set-hostname"],
	}

	if $::continuent_install::installMysql == true {
		exec { "set-hostname":
			command => "/bin/hostname -F /etc/hostname",
			unless => "/usr/bin/test `hostname` = `/bin/cat /etc/hostname`",
			notify => Service[$::continuent_install::mysqlServiceName],
			require => Package['mysql-server'],
		}
	}
	else {
		exec { "set-hostname":
			command => "/bin/hostname -F /etc/hostname",
			unless => "/usr/bin/test `hostname` = `/bin/cat /etc/hostname`",
		}
	}
}