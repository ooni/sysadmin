#!/bin/sh

# exit on unset variable or non-0 return code.
set -eu

cat <<EOF
module.exports = {
  "db": {
    "host": "$ooni_db_host",
    "port": "5432",
    "database": "ooni_pipeline",
    "username": "ooni",
    "password": "$ooni_db_password",
    "name": "postgres",
    "debug": false,
    "connector": "postgresql",
    "ssl": true
  },
  "mem": {
    "name": "mem",
    "connector": "memory"
  }
}
EOF
