FROM centos:centos5
MAINTAINER Neil Armitage <narmitage@vmware.com>
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
RUN rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-5.noarch.rpm
RUN yum -y install puppet git tar openssh-server
RUN mkdir -p /etc/puppet/modules
RUN puppet module install continuent-tungsten
RUN puppet module install puppetlabs-mysql
RUN rm -rf /etc/puppet/modules/tungsten
ADD tungsten /etc/pupppet/modules/tungsten
