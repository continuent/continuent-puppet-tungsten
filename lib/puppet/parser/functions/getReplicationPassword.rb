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
#This module will determine what replication user to user
#Preference will be given to any user passed in the ini file

module Puppet::Parser::Functions
  newfunction(:getReplicationPassword, :type => :rvalue) do |args|
    replicationPassword         = args[0]
    tungstenIniContents     = args[1]
    iniReplicationPassword      =nil

    if tungstenIniContents == nil and replicationPassword == nil
      raise Puppet::ParseError, 'No passwords  passed'
    end

    if tungstenIniContents == ''
      #No ini file exists so just use the replicationUser
      return replicationPassword
    end

    tungstenIniContents.each do |iniLine|
      iniLine_a=iniLine.split('=')
      if iniLine_a[0]=='replication-password'
          iniReplicationPassword=iniLine_a[1]
      end
    end

    if iniReplicationPassword==nil
      raise Puppet::ParseError, "Unable to determine replication-password from ini file contents"
    else
      iniReplicationPassword
    end
  end
end