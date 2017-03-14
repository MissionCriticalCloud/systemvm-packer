FROM debian:8

ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://deb.debian.org/debian/ jessie contrib" > /etc/apt/sources.list.d/contrib.list

RUN  apt-get update
RUN  apt-get install -y qemu-system-x86
RUN  apt-get install -y virtualbox
RUN  apt-get install -y libguestfs-tools
RUN  apt-get install -y linux-image-amd64
RUN  apt-get install -y wget curl unzip zip bzip2
RUN  wget https://releases.hashicorp.com/packer/0.10.2/packer_0.10.2_linux_amd64.zip -O /packer.zip
RUN  unzip /packer.zip && mv /packer /usr/bin/packer

#ADD . /systemvm-packer

CMD "/bin/bash"
