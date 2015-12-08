#!/bin/sh

# exit on unset variable or non-0 return code.
set -eu

cp _tor.repo /etc/yum.repos.d/tor.repo
rpmkeys --import _torproject-rpm-key.asc

yum -y update
yum -y groupinstall "Development Tools"
yum -y install wget sudo tor python-devel python-setuptools \
    openssl-devel libyaml-devel libffi-devel sqlite-devel

wget "https://bootstrap.pypa.io/get-pip.py"
python get-pip.py

pip install oonibackend
