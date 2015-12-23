#!/bin/sh
set -eu

# ansible ec2 module doesn't return fingerprint from boto... enterprise ready!
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook \
    --private-key ~/ooni/ooni-pipeline.pem \
    -e role=ooni-pipeline \
    -e "@private-vars.yaml" \
    -i /dev/null \
    master-deploy-playbook.yaml \
