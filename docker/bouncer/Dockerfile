FROM debian:wheezy
MAINTAINER Arturo Filastò <art@torproject.org>
RUN apt-get -y update
RUN apt-get install -y python-pip python-dev git
RUN pip install ansible==1.7.1
ADD inventory /etc/ansible/hosts
RUN git clone http://github.com/TheTorProject/ooni-sysadmin.git /tmp/ooni-sysadmin
WORKDIR /tmp/ooni-sysadmin/
RUN git submodule update --init
WORKDIR /tmp/ooni-sysadmin/ansible
RUN ansible-playbook -v install-oonibackend.yml -c local
CMD ["/usr/local/bin/oonib", "-c", "/etc/oonibackend.conf"]
