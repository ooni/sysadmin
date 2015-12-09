#!/bin/sh

# exit on unset variable or non-0 return code.
set -eu

cat > ooniprobe-bridge-run.service <<EOF
[Unit]
Description=ooniprobe-bridge-reachability

[Service]
User=$ooniprobe_user
WorkingDirectory=/home/$ooniprobe_user
Type=simple
ExecStart=ooniprobe  -l /var/log/ooniprobe.log -f /etc/ooniprobe.conf \
    -c httpo://pepjm62lph5blky5.onion blocking/bridge_reachability \
    -f /etc/ooniprobe-bridges.txt -t 400
EOF
