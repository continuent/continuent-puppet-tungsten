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
#This module will determine what application user to user
#Preference will be given to any user passed in the ini file

module Puppet::Parser::Functions
  newfunction(:getApplicationUser, :type => :rvalue) do |args|
    applicationUser         = args[0]
    tungstenIniContents     = args[1]
    iniApplicationUser      =nil

    if tungstenIniContents == nil and applicationUser == nil
      raise Puppet::ParseError, 'No userNames  passed'
    end

    if tungstenIniContents == '' || tungstenIniContents == false
      #No ini file exists so just use the applicationUser
      return applicationUser
    end

    tungstenIniContents.each do |iniLine|
      iniLine_a=iniLine.split('=')
      if iniLine_a[0]=='application-user'
          iniApplicationUser=iniLine_a[1]
      end
    end

    if iniApplicationUser==nil
      if applicationUser==nil
        raise Puppet::ParseError, "Unable to determine application-user from ini file contents"
      else
        applicationUser
      end
    else
      iniApplicationUser
    end
  end
end