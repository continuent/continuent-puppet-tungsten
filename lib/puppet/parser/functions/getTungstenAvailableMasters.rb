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

module Puppet::Parser::Functions
  newfunction(:getTungstenAvailableMasters, :type => :rvalue) do |args|
    clusterHash = args[0]
    
    availableMasters = []
    if clusterHash.is_a?(Array)
      # We already have an array, so no further work is needed
      availableMasters = clusterHash
    elsif clusterHash.is_a?(Hash)
      # Review each key-pair and pull out hostnames set for the possible settings
      clusterHash.each_pair do |currentClusterName, cluster|
        ["members", "dataservice-hosts", "master", "masters", "slaves"].each{
          |key|
          if cluster.has_key?(key)
            cluster[key].to_s().split(",").each{
              |i|
              availableMasters << i
            }
          end
        }
      end
    end
    
    # Dedup and sort the list so the offset values do not change from run to run
    availableMasters = availableMasters.uniq().sort()
    return availableMasters
  end
end