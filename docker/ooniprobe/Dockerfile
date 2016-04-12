FROM debian:jessie
RUN apt-get -y update
RUN apt-get install -y python-pip python-dev git-core ansible
RUN git clone https://github.com/TheTorProject/ooni-sysadmin.git \
	/tmp/ooni-sysadmin
WORKDIR /tmp/ooni-sysadmin/
RUN git submodule update --init
WORKDIR /tmp/ooni-sysadmin/ansible
RUN ansible-playbook -vvvv -c local -i local, install-ooniprobe.yml \
	--extra-vars="set_ooniprobe_pip='true'"
WORKDIR $HOME
RUN ooniresources --update-geoip --update-inputs
