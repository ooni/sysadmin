FROM debian:jessie
RUN apt-get update -y
RUN apt-get install git python python-pymongo python-yaml -y
###RUN wget https://pypi.python.org/packages/source/p/pymongo/pymongo-2.7.2.tar.gz#md5=bbd229fe0ff43ee130eed9ffa9db7353
WORKDIR /tmp/sanitize
RUN git clone https://github.com/TheTorProject/ooni-pipeline.git
RUN chmod u+rx /tmp/sanitize/ooni-pipeline/bin/oonipipeline
COPY config.sh /tmp/sanitize/config.sh
COPY sanitise_wrapper.sh /tmp/sanitize/sanitise_wrapper.sh
RUN chmod u+rx /tmp/sanitize/sanitise_wrapper.sh
CMD ./sanitise_wrapper.sh

