#!/bin/sh
set -o errexit

./gen-basic-auth.sh
./gen-ssl-key-and-cert-munin.sh
./gen-ssl-key-and-cert-nginx.sh
ansible-playbook -i hosts top.yaml -vvvv
