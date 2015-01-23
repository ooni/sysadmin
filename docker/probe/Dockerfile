FROM debian:wheezy
MAINTAINER Arturo Filastò <art@torproject.org>
RUN apt-get -y update
RUN apt-get install -y python-pip python-dev git
RUN pip install ansible==1.7.1
ADD http://www.random.org/strings/?num=10&len=8&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new uuid
RUN git clone http://github.com/TheTorProject/ooni-sysadmin.git /tmp/ooni-sysadmin
WORKDIR /tmp/ooni-sysadmin/
RUN git submodule update --init
WORKDIR /tmp/ooni-sysadmin/ansible
RUN ansible-playbook -v install-ooniprobe-bridge-reachability.yml -c local --extra-vars "ooni_collector=httpo://pepjm62lph5blky5.onion ooni_user=root ooni_home=/root/ ooni_start_tor=true experimental_tor=yes"
WORKDIR /data/bridge_reachability
CMD ["/usr/sbin/cron", "-f"]
