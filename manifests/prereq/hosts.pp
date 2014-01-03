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
class continuent_install::prereq::hosts(
	$hostsFile = []  ,
    $skipHostConfig = false
) {
	#Add the hosts for all of the nodes
      define createHosts  ($hostsFile=$title, $skipHostConfig) {
		$servers = split($hostsFile, ' ')
        if $skipHostConfig == false {
          host { $servers[1]:
            ip => $servers[0]
          }
        }  else {
          if $servers[1] != $fqdn {
              host { $servers[1]:
                ip => $servers[0]
              }
          }
        }

	}
    createHosts { $hostsFile:
          skipHostConfig => $skipHostConfig }
}