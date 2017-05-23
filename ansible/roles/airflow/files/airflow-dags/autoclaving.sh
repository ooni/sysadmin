#!/bin/sh
exec sudo --non-interactive /usr/local/bin/docker-trampoline \
    autoclaving.py "{{ ds }}" "{{ execution_date.isoformat() }}" "{{ (execution_date + dag.schedule_interval).isoformat() }}" \
    --canned-root /data/ooni/private/canned \
    --bridge-db /data/ooni/private/bridge_db/bridge_db.json \
    --autoclaved-root /data/ooni/public/autoclaved
