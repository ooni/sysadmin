FROM debian:jessie
RUN apt-get update -y
RUN apt-get install git python python-pymongo python-yaml -y
WORKDIR /tmp/importer
RUN git clone https://github.com/TheTorProject/ooni-pipeline.git
RUN chmod u+rx /tmp/importer/ooni-pipeline/bin/oonipipeline
COPY config.sh /tmp/importer/config.sh
COPY import_wrapper.sh /tmp/importer/import_wrapper.sh
RUN chmod u+rx /tmp/importer/import_wrapper.sh
CMD ./import_wrapper.sh

