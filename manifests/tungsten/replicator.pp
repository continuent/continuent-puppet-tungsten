# == Class: tungsten::tungsten::replicator See README.md for documentation.
#
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

class tungsten::tungsten::replicator (
	$location = true,
) inherits tungsten::params {
	include tungsten::prereq
	
	if $location == true {
	  # Install the tungsten-replicator package using configured repositories
		Class["tungsten::prereq"] ->
		package { 'tungsten-replicator':
			ensure => present,
		}
	} elsif $location != false {
	  case fileextension($location) {
	    ".rpm": {
	      # Install the tungsten-replicator package from the provided location
    		Class["tungsten::prereq"] ->
    		package { "tungsten-replicator":
    			ensure => present,
    			provider => rpm,
    			source => $location,
    		}
	    }
	    ".gz": {
	      # Get the true basename of the file in case it is a .tar.gz file
	      if fileextension(filebasename($location)) == ".tar" {
	        $basename = filebasename(filebasename($location))
	        $arguments = "zxf"
	      } else {
	        $basename = filebasename($location)
	        $arguments = "xf"
	      }
	      
	      # Unpack the tungsten-replicator package from the provided location
	      Class["tungsten::prereq"] ->
    		exec { "unpack-tungsten-replicator":
    		  path => ["/bin", "/usr/bin"],
    		  cwd => "/opt/continuent/software",
    		  command => "tar $arguments $location",
    		  user => $tungsten::prereq::systemUserName,
    			creates => "/opt/continuent/software/$basename",
    		} ~>
    		exec { "install-tungsten-replicator":
    		  path => ["/bin", "/usr/bin"],
    		  command => "/opt/continuent/software/$basename/tools/tpm update --tty --log=/opt/continuent/service_logs/tungsten-configure.log > /opt/continuent/service_logs/rpm.output 2>&1",
    		  user => $tungsten::prereq::systemUserName,
    		  onlyif => "test -f /etc/tungsten/tungsten.ini",
      		refreshonly => true,
      		returns => [0, 1],
    		}
	    }
    	default: {
    	  fail("Unable to install the Tungsten Replicator from $location because the file type is not recognized.")
    	}
	  }
	}
}