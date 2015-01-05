FROM ubuntu:10.04
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN apt-get update;apt-get -y install wget python-software-properties
RUN wget --no-check-certificate  https://apt.puppetlabs.com/puppetlabs-release-lucid.deb
RUN dpkg -i puppetlabs-release-lucid.deb
RUN  add-apt-repository ppa:pdoes/ppa

RUN apt-get update
RUN apt-get install -y  puppet git-core tar openssh-server  wget
RUN mkdir -p /etc/puppet/modules
RUN mkdir -p  /var/run/sshd
RUN puppet module install continuent-tungsten
RUN puppet module install puppetlabs-mysql
RUN rm -rf /etc/puppet/modules/tungsten
RUN git clone https://github.com/narmitag/continuent-puppet-tungsten.git /etc/puppet/modules/tungsten
