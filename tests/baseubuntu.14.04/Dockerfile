FROM ubuntu:14.04
MAINTAINER Neil Armitage <narmitage@vmware.com>

RUN apt-get update
RUN apt-get install -y  puppet rsync openjdk-7-jdk
#Percona
RUN /usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CD2EFD2A
#MariaDB
RUN /usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CBCB082A1BB943DB
#MySQL
/usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 5072E1F5
