FROM centos:centos7
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs && \
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
RUN yum -y install puppet git tar openssh-server
RUN mkdir -p /etc/puppet/modules
RUN puppet module install continuent-tungsten
RUN puppet module install puppetlabs-mysql
RUN rm -rf /etc/puppet/modules/tungsten
ADD tungsten /etc/pupppet/modules/tungsten
