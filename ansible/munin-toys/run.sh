#!/bin/sh
if [ -z "$AWS_ACCESS_KEY" ]; then echo "set AWS_ACCESS_KEY"; exit; fi
if [ -z "$AWS_SECRET_KEY" ]; then echo "set AWS_SECRET_KEY"; exit; fi
ansible-playbook --private-key private/ssh-key -i hosts top.yaml -vvvv
