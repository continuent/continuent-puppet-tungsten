# == Class: tungsten::tungstenhadoop::cdh5 See README.md for documentation.
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

class tungsten::tungstenhadoop::cdh5 (
  $repo = $tungsten::tungstenhadoop::cdh5::params::repo
) inherits tungsten::tungstenhadoop::cdh5::params {
  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-cloudera':
    ensure => file,
    mode	 => 644,
    owner	=> "root",
    group	=> "root",
    source => 'puppet:///modules/tungsten/RPM-GPG-KEY-cloudera',
  } ->
  package { "cloudera-cdh-5-0.${::architecture}":
		provider => "rpm",
		ensure => present,
		source => $repo,
	} ->
	package { "hadoop-conf-pseudo": 
	  notify => Exec["exec-hdfs-namenode"]
	} ->
	exec {"exec-hdfs-namenode":
	  command => "/usr/bin/hdfs namenode -format",
	  user => "hdfs",
	  refreshonly => true
	} ->
	service {"hadoop-hdfs-datanode":
	  ensure => "running",
	  enable => true
	} ->
	service {"hadoop-hdfs-namenode":
	  ensure => "running",
	  enable => true
	} ->
	service {"hadoop-hdfs-secondarynamenode":
	  ensure => "running",
	  enable => true
	} ->
	exec {"exec-init-hdfs": 
	  command => "/usr/lib/hadoop/libexec/init-hdfs.sh",
	  unless => "/usr/bin/hadoop fs -ls /tmp"
	} ->
	exec {"exec-mkdir-user-tungsten": 
	  command => "/usr/bin/hadoop fs -mkdir /user/tungsten",
	  unless => "/usr/bin/hadoop fs -ls /user/tungsten",
	  notify => Exec["exec-chown-user-tungsten"],
	  user => "hdfs"
	} ->
	exec {"exec-chown-user-tungsten":
	  command => "/usr/bin/hadoop fs -chown -R tungsten:supergroup /user/tungsten",
	  user => "hdfs",
	  refreshonly => true
	} ->
	service {"hadoop-yarn-resourcemanager":
	  ensure => "running",
	  enable => true
	} ->
	service {"hadoop-yarn-nodemanager":
	  ensure => "running",
	  enable => true
	} ->
	service {"hadoop-mapreduce-historyserver":
	  ensure => "running",
	  enable => true
	} ->
	package {"hive": } ->
	package {"hive-metastore": } ->
	package {"hive-server2": } ->
	package {"hive-hbase": } ->
	service {"hive-metastore":
	  ensure => "running",
	  enable => true
	} ->
	service {"hive-server2":
	  ensure => "running",
	  enable => true
	} ->
	package {"tungstenhadoop::cdh5::git":
	  name => "git"
	} ->
	exec {"exec-git-continuent-tools-hadoop":
	  command => "/usr/bin/git clone https://github.com/continuent/continuent-tools-hadoop.git /opt/continuent/software/continuent-tools-hadoop",
	  creates => "/opt/continuent/software/continuent-tools-hadoop",
	  notify => Exec["exec-chown-continuent-tools-hadoop"]
	} ->
	exec {"exec-chown-continuent-tools-hadoop":
	  command => "/bin/chown -R tungsten: /opt/continuent/software/continuent-tools-hadoop",
	  refreshonly => true
	} 
}