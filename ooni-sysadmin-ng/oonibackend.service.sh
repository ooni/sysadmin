#!/bin/sh

# exit on unset variable or non-0 return code.
set -eu

cat > oonibackend.service <<EOF
[Unit]
Description=oonibackend

[Service]
User=$oonib_user
Restart=always
ExecStart=$oonib_bin -c /etc/oonibackend.conf

[Install]
WantedBy=multi-user.target
EOF
