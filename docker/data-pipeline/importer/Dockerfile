FROM debian:jessie
RUN apt-get update -y
RUN apt-get install git python python-yaml python-pymongo -y
WORKDIR /tmp/importer
RUN git clone https://github.com/TheTorProject/ooni-pipeline.git
COPY config.sh /tmp/importer/config.sh
COPY run.sh /tmp/importer/run.sh
RUN chmod u+rx /tmp/importer/run.sh
CMD ./run.sh
