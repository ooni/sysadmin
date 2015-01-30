FROM debian:wheezy
RUN apt-get update -y
RUN apt-get install git python python-yaml -y
WORKDIR /tmp/importer
RUN git clone https://github.com/TheTorProject/ooni-pipeline.git
COPY config.sh /tmp/importer/config.sh
COPY importer_wrapper.sh /tmp/importer/importer_wrapper.sh
RUN chmod u+rx /tmp/importer/importer_wrapper.sh
CMD ./importer_wrapper.sh
