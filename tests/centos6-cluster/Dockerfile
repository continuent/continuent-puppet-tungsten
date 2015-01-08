FROM centos:centos6
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN rpm -i http://mirror.bytemark.co.uk/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
RUN rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs && \
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
RUN yum -y install puppet git tar openssh-server
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN rpm -i http://releases.continuent.com.s3.amazonaws.com/ct-2.0.4/continuent-tungsten-2.0.4-589.noarch.rpm
RUN /usr/bin/ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_key
RUN /usr/bin/ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN /usr/bin/ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key
ADD ./tungsten.ini /etc/tungsten/tungsten.ini
ADD ./start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh
EXPOSE 7  22 2112 7800 7801 7802 7803 7804 7805 10000 10001 11999 12000 9999 3306 13306
CMD bash -C '/usr/bin/start.sh';'bash'
