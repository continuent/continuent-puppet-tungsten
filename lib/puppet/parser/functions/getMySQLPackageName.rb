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
  newfunction(:getMySQLPackageName, :type => :rvalue) do |args|
    packageType   = args[0]
    build         = args[1]
    version       = args[2]
    os            = lookupvar('operatingsystem')
    packageServer = nil
    packageClient = nil


    # percona centos 51 55 56
    # ubuntu 5.5 5.6
    #
    # maria centos no versions
    #
    # mysql no version

    # if os =~ /(?i:centos|redhat|oel)/) {
    #   osRelease   = lookupvar('operatingsystemmajrelease')
    # }
    #
    # if os =~ /(?i:amazon)/) {
    #   osRelease   = lookupvar('epel_version')
    # }
    #
    # if os =~ /(?i:debian|ubuntu)/) {
    #   osRelease   = lookupvar('operatingsystemrelease ')
    # }

    if (os !~ /(?i:centos|redhat|oel|amazon|ubuntu|debian)/)
      raise Puppet::ParseError, "Unsupported Operating System"
    end

    if build == 'percona'
      if (os =~ /(?i:centos|redhat|oel|amazon)/)
        if (version !~ /(?i:5.1|5.5|5.6)/)
          raise Puppet::ParseError, "Unsupported Version for the Percona Repo on $os"
        end
        version=version.gsub(".", "")
        packageServer="Percona-Server-server-#{version}"
        packageClient="Percona-Server-client-#{version}"
      else
        if (version !~ /(?i:5.5|5.6)/)
          raise Puppet::ParseError, "Unsupported Version for the Percona Repo on $os"
        end
        packageServer="percona-server-server-#{$version}"
        packageClient="percona-server-client-#{$version}"
      end
    end

    if build == 'mariadb'
      if (os =~ /(?i:centos|redhat|oel|amazon)/)
        packageServer="MariaDB-server"
        packageClient="MariaDB-client"
      else
        packageServer="mariadb-server"
        packageClient="mariadb-client"
      end
    end

    if build == 'mysql'
        packageServer="mysql-community-server"
        packageClient="mysql-community-client"
    end

    if packageType=='server'
      return packageServer
    else
      return packageClient
    end

  end
end
