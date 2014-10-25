FROM debian:wheezy
RUN apt-get update -y
RUN apt-get install git python python-yaml -y
WORKDIR /tmp/importer
RUN git clone https://github.com/TheTorProject/ooni-pipeline.git
RUN chmod u+rx /tmp/importer/ooni-pipeline/tasks/import.py
CMD /tmp/importer/ooni-pipeline/tasks/import.py
