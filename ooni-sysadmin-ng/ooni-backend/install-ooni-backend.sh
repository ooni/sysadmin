#!/bin/sh

# exit on unset variable or non-0 return code.
set -eu

sh _install-packages.sh

# we export these variables to pass them to the oonibackend.conf.sh and
# oonibackend.service.sh templates.
export oonib_bin=$(which oonib)

# directories owned by and daemon running as this user.
# --system means no login and no shell.
export oonib_user="oonib"
adduser --system --no-create-home $oonib_user

export dns_resolver_address="8.8.8.8:53"

# some of these features can be disabled with a value of "null".
export http_return_json_headers_port="57001"
export tcp_echo_port="57002"
export daphn3_port="57003"
export dns_port_tcp="57004"
export dns_port_udp="57004"
export dns_discover_port_tcp="57005"
export dns_discover_port_udp="57005"
export ssl_port="57006"

export log_dir="/var/log/ooni"
export deck_dir="/usr/share/ooni/backend/decks"
export input_dir="/usr/share/ooni/backend/inputs"

export tor_datadir="/var/spool/ooni/backend/tor"
export archive_dir="/var/spool/ooni/backend/archive"
export report_dir="/var/spool/ooni/backend/raw_reports"

export policy_file="/var/spool/ooni/backend/policy.yaml"
export bouncer_file="/var/spool/ooni/backend/bouncer.yaml"

export ssl_dir="/etc/oonib/ssl"
export ssl_key=$ssl_dir"/key.pem"
export ssl_cert=$ssl_dir"/cert.pem"

for dir in "
$log_dir \
$deck_dir \
$input_dir \
$tor_datadir \
$archive_dir \
$report_dir \
$ssl_dir \
"; do
    mkdir -p $dir
    chown $oonib_user $dir
done

# stick some environment variables in the templates and copy them into place
sh _oonibackend.conf.sh
cp oonibackend.conf /etc/

sh _oonibackend.service.sh
cp oonibackend.service /etc/systemd/system/

# make self-signed cert for https tests
openssl req -x509 -newkey rsa:4096 \
    -keyout $ssl_key -out $ssl_cert \
    -days 400 -nodes -subj '/CN=selfie'
chown $oonib_user $ssl_dir/*
chmod 0600 $ssl_dir/*

# map http, ssl, dns ports so they're at the normal places on the outside
iptables -t nat -A PREROUTING -p tcp -m tcp \
    --dport 80 -j REDIRECT --to-ports $http_return_json_headers_port

iptables -t nat -A PREROUTING -p tcp -m tcp \
    --dport 443 -j REDIRECT --to-ports $ssl_port

#iptables -t nat -A PREROUTING -p tcp -m udp \
#    --dport 53 -j REDIRECT --to-ports $dns_port_udp
#
#iptables -t nat -A PREROUTING -p tcp -m tcp \
#    --dport 53 -j REDIRECT --to-ports $dns_port_tcp

# enable and start the service
systemctl daemon-reload
systemctl enable oonibackend.service
systemctl start oonibackend.service
