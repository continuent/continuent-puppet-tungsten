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
#
#

require 'rubygems'
require 'json'
require 'pp'
require 'tempfile'



vagrantType='vb'
#vagrantType'ec2'


allTestsPassed=true



system ("rm -rf module")
system ("mkdir module")
system ("cp -r ../{files,lib,manifests,templates} module/")
def capture_stdout
  stdout = $stdout.dup
  Tempfile.open 'stdout-redirect' do |temp|
    $stdout.reopen temp.path, 'w+'
    yield if block_given?
    $stdout.reopen stdout
    temp.read
  end
end


loop = 1

#tests to run
runTypes = Dir['tests/*.pp']
#runTypes = %w(run_std.pp)

runTypes.sort!
noOfTests=runTypes.count
puts "Test run consists of #{noOfTests} tests"

#Some test require MySQL to be installed on the hosts already - simulating a pre-installed customer config
#putting the test in this array will trigger an extra test puppet class to be called to pre-install and config mysql
#before running the test
#requireMysql = %w(run_std_no_mysql.pp run_sor_no_mysql.pp run_no_install_no_mysql.pp)

#Some test require MySQLJ to be installed on the hosts already - simulating a pre-installed customer config
#putting the test in this array will trigger an extra test puppet class to be called to pre-install and config mysql
#before running the test
#requireMysqlj     = %w(run_std_no_mysqlj.pp )
#dontCheckCluster  = %w(run_no_install.pp run_no_install_no_mysql.pp sandbox.pp rvm.pp replicator.pp replicator_nightly.pp connector_only.pp build_ini.pp)
#dontTerminate     = %w(1prov_setup.pp run_std_no_mysql.pp)
#checkConnector    = %w(connector_only.pp)
#
#requirePerconaRepo = %w(run_no_install.pp run_no_install_no_mysql.pp)


    testNumber=1

    runTypes.each do |runType|

        runType=File.basename(runType)
        runTypeShort=File.basename(runType,".*")

        runDetails=JSON.parse(File.read("tests/#{runTypeShort}.json"))
        pp runDetails

        puts "(#{testNumber}/#{noOfTests}) Running test #{runType} - #{runDetails['description']}  "
        puts '   - calling Vagrant to launch a clean node'
        puts "   - vagrant type = #{vagrantType}"
        puts "   - number of nodes = #{runDetails['nodes']}"

        system('vagrant destroy -f')

        system("rm VagrantFile ; cp Vagrantfile.#{vagrantType}.#{runDetails['nodes']} VagrantFile")
        system('vagrant up')

        puts '   - Installing and running puppet modules on each node'

        for n in 1..runDetails['nodes']
          puts "     - Provisioning node #{n} "
          system ("vagrant ssh db#{n} -c 'sudo mkdir /etc/puppet/modules/continuent_install'")
          system ("vagrant ssh db#{n} -c 'sudo cp -r /vagrant/module/* /etc/puppet/modules/continuent_install'")

          #puppetOutput = system "vagrant ssh db#{n} -c 'cd /vagrant/tests; sh run_test.sh #{runType} #{runDetails['pre-reqs'].join(',')}'"

          puppetOutput = capture_stdout do
            system "vagrant ssh db#{n} -c 'cd /vagrant/tests; sh run_test.sh #{runType} #{runDetails['pre-reqs'].join(',')}'"
          end

          pp puppetOutput
          puppetError=false
          if puppetOutput.include?('Error:')
            puppetError=true
            puts '>>>>>>>>>>>>>>>> PUPPET ERROR <<<<<<<<<<<<<< '
            allTestsPassed=false
          end
        end




            #sleep 20
            #
            #if !puppetError
            #    if dontCheckCluster.include?(runType)
            #
            #      if checkConnector.include?(runType)
            #        #output=vagrantSSH( "echo 'ls'|/opt/continuent/tungsten/tungsten-connector/bin/connector status")
            #
            #        #if output.include?('Tungsten Connector Service is running')
            #        #  puts '   - connector installed ok - will terminate instance'
            #        #else
            #        #  puts '>>>>>>>>>>  CONNECTOR FAILED TO LAUNCH  <<<<<<<<<<<<<<<<<<<'
            #        #  allTestsPassed=false
            #        #end
            #      else
            #        puts '   - no cluster to check for this runtype - will terminate instance'
            #      end
            #    else
            #
            #      #cctrlOutput=vagrantSSH("echo 'ls'|/opt/continuent/tungsten/tungsten-manager/bin/cctrl")
            #
            #      #if cctrlOutput.include?('ONLINE')
            #      #  ??
            #      #else
            #      #  puts '>>>>>>>>>>  CLUSTER FAILED TO LAUNCH  <<<<<<<<<<<<<<<<<<<'
            #      #  allTestsPassed=false
            #      #end
            #    end

        #end


        #system ('vagrant destroy -f')
        testNumber=testNumber+1
    end


if allTestsPassed
  puts '------- All Tests completed OK ------------'
  exit 0
else
  puts '------- TEST FAILURES EXIST ------------'
  exit 2
end

