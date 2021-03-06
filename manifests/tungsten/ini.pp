# == Class: tungsten::tungsten::ini See README.md for documentation.
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

class tungsten::tungsten::ini ( $installRedoReaderSoftware=false, $redoReaderTopology=false
) inherits tungsten::tungsten {
	include tungsten::prereq

	if $installRedoReaderSoftware != false {

		#Check the topoloy is valid
		$validTopologies=['OracleToOracle','MySQLToOracle','OracleToMySQL']
		validate_re($redoReaderTopology,$validTopologies)

		$iniTemplate="tungsten_$redoReaderTopology.erb"
	} else {
		$iniTemplate='tungsten.erb'
	}

	Class["tungsten::prereq"] ->
	file { "tungsten.ini":
		path		=> "/etc/tungsten/tungsten.ini",
		owner => $tungsten::prereq::systemUserName,
		group => "root",
		mode => 644,
		content => template("tungsten/$iniTemplate"),
	}
}
