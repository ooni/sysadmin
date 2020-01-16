#!/bin/bash

if curl -f -m 5 -s {{ web_connectivity_ipv4 }}:{{ web_connectivity_port }}/status | grep '{"status": "ok"}' > /dev/null
then exit 0
else
    systemctl restart web-connectivity-th.service
fi
