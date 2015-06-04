# == Class: tungsten::tungstenhadoop::tools See README.md for documentation.
#
# Copyright (C) 2015 VMware, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.  You may obtain
# a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

class tungsten::tungstenhadoop::tools (
) {
  package {"tungstenhadoop::tools::git":
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
