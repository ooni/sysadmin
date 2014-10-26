FROM debian:wheezy
RUN apt-get update -y
RUN apt-get install git python python-yaml -y
WORKDIR /tmp/importer
RUN git clone https://github.com/TheTorProject/ooni-pipeline.git
RUN chmod u+rx /tmp/importer/ooni-pipeline/bin/oonipipeline
CMD ./ooni-pipeline/bin/oonipipeline import
