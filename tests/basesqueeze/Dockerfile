FROM debian:squeeze
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN apt-get update
RUN apt-get install -y wget
RUN wget --no-check-certificate  https://apt.puppetlabs.com/puppetlabs-release-squeeze.deb
RUN dpkg -i puppetlabs-release-squeeze.deb
RUN apt-get update
RUN apt-get install -y  puppet git tar openssh-server  wget
RUN mkdir -p /etc/puppet/modules
RUN mkdir -p  /var/run/sshd
RUN puppet module install continuent-tungsten
RUN puppet module install puppetlabs-mysql
RUN rm -rf /etc/puppet/modules/tungsten
RUN git clone  $WORKGIT /etc/puppet/modules/tungsten
