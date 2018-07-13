#!/bin/sh
set -eu

# ooniprobe saves some things under ~/.ooni/
export ooniprobe_user="ooniprobe"
adduser --system --create-home $ooniprobe_user

# XXX TODO
# probably incomplete--I'm on a system with oonibackend already
yum install -y libpcap-devel geoip-devel libdnet-devel gmp-devel
pip install ooniprobe obfsproxy fteproxy

export ooniprobe_logfile="/var/log/ooniprobe.log"
touch $ooniprobe_logfile
chown $ooniprobe_user $ooniprobe_logfile

sh _ooniprobe.conf.sh
sh _ooniprobe-bridge-run.service.sh

cp ooniprobe.conf /etc/
cp _ooniprobe-bridges.txt /etc/ooniprobe-bridges.txt

cp ooniprobe-bridge-run.service /etc/systemd/system/
cp _ooniprobe-bridge-run.timer /etc/systemd/system/ooniprobe-bridge-run.timer

systemctl daemon-reload
systemctl enable ooniprobe-bridge-run
systemctl start ooniprobe-bridge-run
