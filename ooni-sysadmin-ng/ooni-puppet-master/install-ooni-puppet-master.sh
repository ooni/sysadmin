#!/bin/sh
#
# This script is written for CentOS 7.0

set -eu

yum update
yum upgrade -y
yum install -y git python-devel libyaml-devel libsqlite3-devel libffi-devel openssl screen
yum groupinstall -y "development tools"

wget "https://bootstrap.pypa.io/get-pip.py"
python get-pip.py
pip install certifi

pip install invoke

git clone https://github.com/TheTorProject/ooni-pipeline.git
cd ooni-pipeline
pip install -r requirements.txt

# XXX automate this
echo "Copy the private and configuration files over"
echo ""
echo "scp invoke.yaml puppet-master-1.infra.ooni.io:~/ooni-pipeline/invoke.yaml"
echo "scp -r private/* puppet-master-1.infra.ooni.io:~/ooni-pipeline/private"
