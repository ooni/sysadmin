FROM debian:wheezy
RUN echo "deb http://nginx.org/packages/debian/ wheezy nginx" >> \
/etc/apt/sources.list.d/nginx.list
RUN apt-key adv --fetch-keys "http://nginx.org/keys/nginx_signing.key"
RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install nginx openssl ca-certificates

RUN rm -rf /etc/nginx/conf.d/* /srv/www/*

ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf
