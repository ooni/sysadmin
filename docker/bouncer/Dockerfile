FROM debian:wheezy
MAINTAINER Arturo Filastò <art@torproject.org>
RUN apt-get -y update
RUN apt-get install -y python-yaml python-jinja2 git
RUN git clone http://github.com/ansible/ansible.git /tmp/ansible
WORKDIR /tmp/ansible
ENV PATH /tmp/ansible/bin:/sbin:/usr/sbin:/usr/bin:/bin/:/usr/local/bin
ENV ANSIBLE_LIBRARY /tmp/ansible/library
ENV PYTHONPATH /tmp/ansible/lib:$PYTHON_PATH
RUN git clone http://github.com/TheTorProject/ooni-sysadmin.git /tmp/ooni-sysadmin
ADD inventory /etc/ansible/hosts
WORKDIR /tmp/ooni-sysadmin/
RUN git submodule update --init
WORKDIR /tmp/ooni-sysadmin/ansible
RUN ansible-playbook -v install-oonibackend.yml -c local
CMD ["/usr/local/bin/oonib", "-c", "/etc/oonibackend.conf"]
