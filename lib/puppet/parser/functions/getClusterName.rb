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
module Puppet::Parser::Functions
  newfunction(:getClusterName, :type => :rvalue) do |args|
    clusterHash = args[0]
    hostName    = args[1]
    clusterName=nil

    if clusterHash == nil
      raise Puppet::ParseError, 'No cluster data passed'
    end

    if hostName == nil
      raise Puppet::ParseError, 'No hostname passed'
    end

    clusterHash.each_pair do |currentClusterName, cluster|
      members_a=cluster['members'].split(',')
      if members_a.include?(hostName)
        clusterName=currentClusterName
      end
    end

    if clusterName==nil
      raise Puppet::ParseError, "Unable to determine cluster name from passed cluster data for host #{hostName}"
    else
      clusterName
    end
  end
end