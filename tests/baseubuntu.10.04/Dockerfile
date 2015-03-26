FROM ubuntu:10.04
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN apt-get update;apt-get -y install wget python-software-properties openjdk-6-jdk
RUN wget --no-check-certificate  https://apt.puppetlabs.com/puppetlabs-release-lucid.deb
RUN dpkg -i puppetlabs-release-lucid.deb
RUN  add-apt-repository ppa:pdoes/ppa

RUN apt-get update
RUN apt-get install -y  puppet  rsync
RUN /usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CD2EFD2A
