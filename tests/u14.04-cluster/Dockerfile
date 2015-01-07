FROM ubuntu:14.04
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN apt-get update
RUN apt-get install -y  puppet git tar openssh-server  wget
RUN mkdir -p /etc/puppet/modules
RUN mkdir -p  /var/run/sshd
RUN puppet module install continuent-tungsten
RUN puppet module install puppetlabs-mysql
RUN rm -rf /etc/puppet/modules/tungsten
ADD tungsten /etc/pupppet/modules/tungsten
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ADD ./puppet.pp /root/puppet.pp
RUN puppet apply /root/puppet.pp
RUN wget http://releases.continuent.com.s3.amazonaws.com/ct-2.0.4/continuent-tungsten_2.0.4-589_all.deb
RUN dpkg -i continuent-tungsten_2.0.4-589_all.deb
ADD ./tungsten.ini /etc/tungsten/tungsten.ini
ADD ./start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh
EXPOSE 7  22 2112 7800 7801 7802 7803 7804 7805 10000 10001 11999 12000 9999 3306 13306
CMD bash -C '/usr/bin/start.sh';'bash'
