FROM centos:centos6
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN rpm -i http://mirror.bytemark.co.uk/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
RUN rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs && \
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
RUN yum -y install puppet git tar openssh-server
RUN mkdir -p /etc/puppet/modules
RUN puppet module install continuent-tungsten
RUN puppet module install puppetlabs-mysql
RUN rm -rf /etc/puppet/modules/tungsten
RUN git clone https://github.com/narmitag/continuent-puppet-tungsten.git /etc/puppet/modules/tungsten
