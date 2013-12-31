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

#@TODO Catch puppet output on failed runs
#@TODO Make rpm a parameter


require 'rubygems'
require 'json'
require 'pp'
require 'tempfile'



stopOnFailure=true

vagrantType='vb'
#vagrantType'ec2'


allTestsPassed=true


rpmFile="/tmp/continuent-tungsten-2.0.1-798.noarch.rpm"
rpmFileShort=File.basename(rpmFile)

system ("rm -rf module")
system ("mkdir module")
system ("cp -r ../{files,lib,manifests,templates} module/")
system ("cp #{rpmFile} .")
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
runTypes = Dir['tests/*.json']
runTypes = %w(run_std.json)

runTypes.sort!
noOfTests=runTypes.count
puts "Test run consists of #{noOfTests} tests"


testNumber=1

runTypes.each do |runType|

    runType=File.basename(runType)
    runTypeShort=File.basename(runType,".*")

    runDetails=JSON.parse(File.read("tests/#{runTypeShort}.json"))
    pp runDetails

    if runDetails.has_key?('scriptsPerNode')
      if runDetails['scriptsPerNode'].count != runDetails['nodes']
        puts "#{runDetails['nodes']} nodes have been specified for this run #{runTypeShort} but only"
        puts "#{runDetails['scriptsPerNode'].count} scripts have been specifed"
        exit 2
      end
    end

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


      puppetOutput=nil
      if runDetails.has_key?('scriptsPerNode')
        puts "   - Node db#{n}, module #{runDetails['scriptsPerNode'][n-1]}"
        puppetOutput = capture_stdout do
          system "vagrant ssh db#{n} -c 'cd /vagrant/tests; sh run_test.sh #{runDetails['scriptsPerNode'][n-1]} #{rpmFileShort} #{runDetails['pre-reqs'].join(',')} 2>&1'"
        end
      else
        puts "   - Node db#{n}, module #{runTypeShort}.pp"
        puppetOutput = capture_stdout do
          system "vagrant ssh db#{n} -c 'cd /vagrant/tests; sh run_test.sh #{runTypeShort}.pp #{rpmFileShort} #{runDetails['pre-reqs'].join(',')} 2>&1'"
        end
      end


      puppetError=false
      if puppetOutput.include?('Error:')
        puppetError=true
        puts '>>>>>>>>>>>>>>>> PUPPET ERROR <<<<<<<<<<<<<< '
        puts puppetOutput
        allTestsPassed=false
      else
        puts "     - Puppet Modules installed on db#{n} with no errors "
      end


    end

    #Run Checks
    for n in 1..runDetails['nodes']
      if runDetails['checkResults'].include?('clusterOk')
        puts "     - running clusterOk check on node #{n} "
        output = capture_stdout do
          system "vagrant ssh db#{n} -c 'sudo /opt/continuent/tungsten/cluster-home/bin/check_tungsten_online 2>&1'"
        end

        if !output.include?('OK')
          puts '>>>>>>>>>>>>>>>> CLUSTER ERROR <<<<<<<<<<<<<< '
          puts output
          allTestsPassed=false
        end

      end
    end

    if stopOnFailure && !allTestsPassed
      exit 2
    end
    system ('vagrant destroy -f')

    testNumber=testNumber+1
end


if allTestsPassed
  puts '------- All Tests completed OK ------------'
  exit 0
else
  puts '------- TEST FAILURES EXIST ------------'
  exit 2
end

