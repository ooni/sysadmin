FROM debian:wheezy
RUN apt-get -y update
RUN apt-get install rsync openssh-client -y
WORKDIR /tmp/raw
ADD rsync-from-collectors.sh /tmp/raw/rsync-from-collectors.sh
ADD collectors.list /tmp/raw/collectors.list
RUN chmod -R a+x /tmp/raw/rsync-from-collectors.sh
CMD /tmp/raw/rsync-from-collectors.sh /tmp/raw/collectors.list /data/raw
