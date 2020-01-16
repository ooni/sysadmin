#!/bin/bash
#
# Simple liveness check for wcth
# Logs can be retrieved with sudo journalctl -f --identifier=wcth-monitor
#
set -euo pipefail
restart() {
  logger -t wcth-monitor "test-helper liveness check failed"
  systemctl restart web-connectivity-th.service
}

trap restart SIGPIPE ERR

url="{{ web_connectivity_ipv4 }}:{{ web_connectivity_port }}/status"
logger "checking test-helper at $url"
logger -t wcth-monitor "checking wcth at $url"
curl -f -m 5 -s "$url" | grep -q '{"status": "ok"}'
