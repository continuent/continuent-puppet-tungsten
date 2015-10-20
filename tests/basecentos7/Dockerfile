FROM centos:centos7
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs && \
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
RUN rm /etc/yum.repos.d/CentOS-Base.repo
RUN yum clean all
ADD ./CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum -y install puppet
