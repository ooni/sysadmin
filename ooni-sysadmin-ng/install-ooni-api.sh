#!/bin/sh

# This is tested on CentOS 7.1

sudo yum install -y epel-release
sudo yum install -y nodejs git screen bzip2
sudo npm install -g jshint bower grunt-cli strongloop
git clone https://github.com/TheTorProject/ooni-api.git
cd ooni-api

npm install --development
bower update --config.interactive=false
grunt build

NODE_ENV="production" node .
