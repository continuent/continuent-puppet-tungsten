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
class install_replicator {
	file { "/etc/tungsten":
		ensure => "directory",
		owner	=> "root",
		group	=> "root",
		mode => 750,
	}

	file { "tungsten.ini":
		path => "/etc/tungsten/tungsten.ini",
		owner => root,
		group => root,
		mode => 644,
		content => template("continuent_install/tungsten_rep.erb"),
		require => File["/etc/tungsten"],
	}

	if $::continuent_install::replicatorRepo == 'stable' {
		exec { "replicator_repo":
			path => ["/bin", "/usr/bin"],
			command => "rpm -i http://releases.continuent.com.s3.amazonaws.com/replicator-release-stable-0.0-1.x86_64.rpm",
		}
	} else {
		exec { "replicator_repo":
			path => ["/bin", "/usr/bin"],
			command => "rpm -i http://releases.continuent.com.s3.amazonaws.com/replicator-release-nightly-0.0-1.x86_64.rpm",
		}
	}

	package { 'tungsten-replicator':
		ensure => present,
		require => [Exec['replicator_repo'],File['tungsten.ini'],Class['mysql_config'],Class['tungsten_config'],Class['tungsten_hosts'],Class['unix_user']],
	}
}