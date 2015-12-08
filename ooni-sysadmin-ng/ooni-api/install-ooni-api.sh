#!/bin/sh

set -eu

# 'npm install' chokes a micro instance, so we give it some swap
sudo /bin/dd if=/dev/zero of=/swap bs=1M count=1024
sudo chmod 0600 /swap
sudo /sbin/mkswap /swap
sudo /sbin/swapon /swap
sudo sh -c 'echo "/swap swap swap defaults 0 0" >> /etc/fstab'
sudo mount -a

sudo yum update -y
sudo yum install -y git wget screen bzip2

node_package="node-v5.1.0-linux-x64.tar.gz"
wget https://nodejs.org/dist/v5.1.0/$node_package
sudo tar --strip-components 1 -xzvf $node_package -C /usr/local

# centos /etc/sudoers takes this out of the path
# PATH=$PATH:/usr/local/bin
# something in the npm install shells out and fails to find node,
# so this hack:
sudo ln -s /usr/local/bin/node /usr/bin/node

sudo /usr/local/bin/npm install -g jshint bower grunt-cli strongloop strong-pm

sudo /usr/local/bin/slc pm-install --systemd
sudo systemctl enable strong-pm
sudo systemctl start strong-pm

git clone https://github.com/TheTorProject/ooni-api.git
cd ooni-api

## set db host and pass variables
cat > server/datasources.production.js <<EOF
module.exports = {
  "db": {
    "host": "$ooni_db_host",
    "port": "5432",
    "database": "ooni_pipeline",
    "username": "ooni",
    "password": "$ooni_db_password",
    "name": "postgres",
    "debug": false,
    "connector": "postgresql",
    "ssl": true
  },
  "mem": {
    "name": "mem",
    "connector": "memory"
  }
}
EOF

# figure out how to get 'slc build' not to choke on the grunt step,
# which fails without the --force flag
# slc build should replace the npm, bower, grunt things below

npm install --development
# has to be interactive to do the angular dep resolution....
bower update #--config.interactive=false
grunt build --force

# until we figure that out, we just run the --commit stage
slc build --commit
slc deploy
# ? # slc ctl start 1
# for some reason it takes about a minute for the app to come up
# and possibly more for the bower_components?! they 404, i come back later and they're there...

sudo iptables -t nat -A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3001
