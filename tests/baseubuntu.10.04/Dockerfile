FROM ubuntu:10.04
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN apt-get update;apt-get -y install wget python-software-properties openjdk-6-jdk
RUN wget --no-check-certificate  https://apt.puppetlabs.com/puppetlabs-release-lucid.deb
RUN dpkg -i puppetlabs-release-lucid.deb
RUN  add-apt-repository ppa:pdoes/ppa

RUN apt-get update
RUN apt-get install -y  puppet  rsync
#Percona
RUN /usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CD2EFD2A
#MariaDB
RUN /usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CBCB082A1BB943DB
#MySQL
/usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 5072E1F5
