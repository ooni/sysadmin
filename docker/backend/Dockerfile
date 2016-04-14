FROM debian:jessie
MAINTAINER Arturo Filastò <art@torproject.org>
RUN apt-get -y update
RUN apt-get install -y git-core ansible
RUN git clone https://github.com/TheTorProject/ooni-sysadmin.git /tmp/ooni-sysadmin
ADD inventory /etc/ansible/hosts
WORKDIR /tmp/ooni-sysadmin/
RUN git submodule update --init
WORKDIR /tmp/ooni-sysadmin/ansible
#RUN ansible-playbook -v install-oonibackend.yml -c local --extra-vars "archive_dir=/data/archive tor_datadir=/data/tor"
RUN ansible-playbook -v install-oonibackend.yml -c local --extra-vars \
	"archive_dir=/data/archive tor_datadir=/data/tor set_supervisord='false'"
CMD ["/usr/local/bin/oonib", "-c", "/etc/oonibackend.conf"]
