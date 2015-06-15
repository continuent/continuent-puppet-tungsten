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
    osversion     = lookupvar('operatingsystemmajrelease')
    osreleasename = lookupvar('lsbdistcodename')
    packageServer = nil
    packageClient = nil


    if (os !~ /(?i:centos|redhat|oel|OracleLinux|amazon|ubuntu|debian)/)
      raise Puppet::ParseError, "Unsupported Operating System - #{os} "
    end

    if build == 'percona'
      if (os =~ /(?i:centos|redhat|oel|OracleLinux|amazon)/)
        if (version !~ /(?i:5.1|5.5|5.6)/)
          raise Puppet::ParseError, "Unsupported Version (#{version})  for the Percona Repo on #{os}"
        end
        version=version.gsub(".", "")
        packageServer="Percona-Server-server-#{version}"
        packageClient="Percona-Server-client-#{version}"
      else
        if (version !~ /(?i:5.6)/)
          raise Puppet::ParseError, "Unsupported Version (#{version}) for the Percona Repo on #{os}"
        end
        packageServer="percona-server-server-#{version}"
        packageClient="percona-server-client-#{version}"
      end
    end

    if build == 'mariadb'
      if (version !~ /(?i:5.5|10.0)/)
        raise Puppet::ParseError, "Unsupported Version (#{version}) for the Mariadb Repo on #{os}"
      end

      if (os =~ /(?i:centos|redhat|oel|OracleLinux|amazon)/)
        packageServer="MariaDB-server"
        packageClient="MariaDB-client"
      else
        packageServer="mariadb-server"
        packageClient="mariadb-client"
      end
    end

    #5.7. is not supported my the puppetlab module as it regnerates old variables
    if build == 'mysql'
      if (version !~ /(?i:5.5|5.6)/)
        raise Puppet::ParseError, "Unsupported Version (#{version}) for the MySQL Repo on #{os}"
      end

      if (os =~ /(?i:centos|redhat|oel|OracleLinux|amazon)/) and  osversion == '5'
        raise Puppet::ParseError, "MySQL repo is Unsupported on Centos5"
      end

      if (os =~ /(?i:ubuntu|debian)/) and  (version !~ /(?i:5.6)/)
        raise Puppet::ParseError, "Unsupported Version (#{version}) for the MySQL Repo on #{os}"
      end
      if (os =~ /(?i:debian)/)
        raise Puppet::ParseError, "MySQL repo is Unsupported on Debian"
      end
      if (os =~ /(?i:ubuntu)/)  and  (osreleasename =~ /(?i:lucid)/)
        raise Puppet::ParseError, "MySQL repo is Unsupported  on Lucid"
      end
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
