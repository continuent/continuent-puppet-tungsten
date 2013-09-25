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
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


if ($operatingsystem =~ /(?i:centos|redhat|oel)/) {
#    file { 'launcher.repo':
#      path    => "/etc/yum.repos.d/launcher.repo",
#      ensure => file,
#      mode   => 644,
#      source => '/opt/continuent/launcher/puppet/testing/files/launcher.repo',
#    }
  file { 'Centos-Local.repo':
    path    => "/etc/yum.repos.d/Centos-Local.repo",
    ensure => file,
    mode   => 644,
    source => '/etc/puppet/modules/continuent_tungsten/testing/files/Centos-Local.repo',
   }
  file { "/etc/hosts":
    owner => root,
    group => root,
    ensure => file,
    mode => 644,
    source => '/etc/puppet/modules/continuent_tungsten/testing/files/hosts-centos',
  }
#  file { '/etc/yum.repos.d/':
#    ensure  => 'directory',
#    recurse => true,
#    purge   => true,
#  }
}

file { "/root/.ssh":
  ensure => 'directory',
  owner => 'root',
  mode => '700',
}

file {"/root/.ssh/id_rsa":
  ensure => file,
  mode => 600,
  owner   => root,
  group   => root,
source => '/etc/puppet/modules/continuent_tungsten/testing/files/tungsten_id_rsa',
  require => File['/root/.ssh'],
}

file {"/root/.ssh/id_rsa.pub":
  ensure => file,
  mode => 600,
  owner   => root,
  group   => root,
source => '/etc/puppet/modules/continuent_tungsten/testing/files/tungsten_id_rsa.pub',
  require => File['/root/.ssh'],
}

exec { "authk":
  command => "/bin/cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys",
  require => File['/root/.ssh/id_rsa.pub'],
}

file {"/etc/resolv.conf":
  ensure => file,
  mode => 777,
  owner   => root,
  group   => root,
  source => '/etc/puppet/modules/continuent_tungsten/testing/files/resolv.conf',
}



