#!/bin/sh

# exit on unset variable or non-0 return code.
set -eu

# apt-get install -y assume yes

apt-get update
apt-get dist-upgrade -y
apt-get install -y sudo tor

wget "https://bootstrap.pypa.io/get-pip.py"
python get-pip.py
# update-alternatives?

apt-get install -y build-essential python-dev python-setuptools
apt-get install -y openssl libssl-dev libyaml-dev libsqlite3-dev libffi-dev
