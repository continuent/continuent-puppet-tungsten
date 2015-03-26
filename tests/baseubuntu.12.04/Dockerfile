FROM ubuntu:12.04
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN apt-get update;apt-get -y install wget openjdk-7-jdk rubygems sudo
RUN wget --no-check-certificate  https://apt.puppetlabs.com/puppetlabs-release-precise.deb
RUN dpkg -i puppetlabs-release-precise.deb
RUN apt-get update
RUN apt-get install -y  puppet  rsync
RUN /usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CD2EFD2A
