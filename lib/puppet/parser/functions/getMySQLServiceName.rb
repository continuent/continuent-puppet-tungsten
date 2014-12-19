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
  newfunction(:getMySQLServiceName, :type => :rvalue) do |args|
    build         = args[0]
    version       = args[1]
    os            = lookupvar('operatingsystem')
    serviceName   = nil

    if (os !~ /(?i:centos|redhat|oel|amazon|ubuntu|debian)/)
      raise Puppet::ParseError, "Unsupported Operating System"
    end

    if build == 'percona'
      serviceName = 'mysql'
    end

    if build == 'mariadb'
      serviceName = 'mysql'
    end

    if build == 'mysql'
        serviceName = 'mysqld'
    end

    return serviceName

  end
end
