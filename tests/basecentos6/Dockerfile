FROM centos:centos6
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN rpm -i http://mirror.bytemark.co.uk/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
RUN rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs && \
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
RUN yum -y install puppet git
