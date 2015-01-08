FROM ubuntu:10.04
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN apt-get update;apt-get -y install wget python-software-properties
RUN wget --no-check-certificate  https://apt.puppetlabs.com/puppetlabs-release-lucid.deb
RUN dpkg -i puppetlabs-release-lucid.deb
RUN  add-apt-repository ppa:pdoes/ppa

RUN apt-get update
RUN apt-get install -y  puppet  
