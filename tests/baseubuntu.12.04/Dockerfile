FROM ubuntu:12.04
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN apt-get update;apt-get -y install wget
RUN wget --no-check-certificate  https://apt.puppetlabs.com/puppetlabs-release-precise.deb
RUN dpkg -i puppetlabs-release-precise.deb
RUN apt-get update
RUN apt-get install -y  puppet git tar openssh-server  wget
RUN mkdir -p /etc/puppet/modules
RUN mkdir -p  /var/run/sshd
RUN puppet module install continuent-tungsten
RUN puppet module install puppetlabs-mysql
RUN rm -rf /etc/puppet/modules/tungsten
ADD tungsten /etc/pupppet/modules/tungsten
