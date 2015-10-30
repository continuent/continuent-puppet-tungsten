FROM centos:centos5
MAINTAINER Neil Armitage <narmitage@vmware.com>
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
RUN rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-5.noarch.rpm
RUN rm /etc/yum.repos.d/CentOS-Base.repo
RUN yum clean all
ADD ./CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum -y install puppet
