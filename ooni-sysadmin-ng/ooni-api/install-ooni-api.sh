#!/bin/sh

set -eu

# 'npm install' chokes a micro instance, so we give it some swap
/bin/dd if=/dev/zero of=/swap bs=1M count=1024
chmod 0600 /swap
/sbin/mkswap /swap
/sbin/swapon /swap
echo "/swap swap swap defaults 0 0" >> /etc/fstab
mount -a

yum update -y
yum install -y git wget screen bzip2

node_package="node-v5.1.0-linux-x64.tar.gz"
wget https://nodejs.org/dist/v5.1.0/$node_package
tar --strip-components 1 -xzvf $node_package -C /usr/local

npm install -g jshint bower grunt-cli strongloop

export ooni_api_user="ooni-api"
adduser --system $ooni_api_user

export ooni_api_dir="/home/$ooni_api_user/ooni-api"
git clone https://github.com/TheTorProject/ooni-api.git $ooni_api_dir
sh _datasources.production.js.sh > \
    $ooni_api_dir/server/datasources.production.js

cd $ooni_api_dir
chown -R $ooni_api_user $ooni_api_dir
npm install --development
bower update --config.interactive=false
grunt build --force

iptables -t nat -A PREROUTING -p tcp -m tcp \
    --dport 80 -j REDIRECT --to-ports 3000

sh _ooni-api.service.sh > /etc/systemd/system/ooni-api.service
systemctl daemon-reload
systemctl enable ooni-api.service
systemctl start ooni-api.service
