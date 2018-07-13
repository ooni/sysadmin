#!/bin/sh

# exit on unset variable or non-0 return code.
set -eu

cat <<EOF
[Unit]
Description=ooni-api

[Service]
ExecStart=/usr/bin/node $ooni_api_dir/server.js
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=ooni-api
User=$ooni_api_user
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF
