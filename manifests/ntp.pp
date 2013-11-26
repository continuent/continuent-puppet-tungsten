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
class ntp {
	case $operatingsystem {
		centos, redhat: {
			$service_name = 'ntpd'
			$conf_file		= 'ntp.conf.el'
		}
		debian, ubuntu: {
			$service_name = 'ntp'
			$conf_file		= 'ntp.conf.debian'
		}
	}

	package { 'ntp':
		ensure => installed,
	}

	service { 'ntp':
		name			=> $service_name,
		ensure		=> running,
		enable		=> true,
		subscribe => File['ntp.conf'],
	}

	file { 'ntp.conf':
		path		=> '/etc/ntp.conf',
		ensure	=> file,
		require => Package['ntp'],
		content => template("continuent_install/${conf_file}.erb"),
	}
}