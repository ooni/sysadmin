FROM debian:wheezy
RUN apt-get -y update
WORKDIR /tmp/raw
ADD rsync-from-collectors.sh rsync-from-collectors.sh
RUN chmod -R a+x /tmp/raw/rsync-from-collectors.sh
CMD /tmp/raw/rsync-from-collectors.sh /data/raw
