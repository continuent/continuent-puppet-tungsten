FROM debian:wheezy
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN apt-get update
RUN apt-get install -y wget openjdk-7-jdk
RUN wget --no-check-certificate  https://apt.puppetlabs.com/puppetlabs-release-squeeze.deb
RUN dpkg -i puppetlabs-release-squeeze.deb
RUN apt-get update
RUN apt-get install -y  puppet rsync
