FROM debian:wheezy
RUN apt-get update -y
RUN apt-get install git python python-yaml -y
WORKDIR /tmp/sanitize
RUN git clone https://github.com/TheTorProject/ooni-pipeline.git
RUN chmod u+rx /tmp/sanitize/ooni-pipeline/tasks/sanitise.py
COPY config.sh /tmp/sanitize/config.sh
COPY sanitise_wrapper.sh /tmp/sanitize/sanitise_wrapper.sh
RUN chmod u+rx /tmp/sanitize/sanitise_wrapper.sh
CMD ./sanitise_wrapper.sh

