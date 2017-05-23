#!/bin/sh
exec sudo --non-interactive /usr/local/bin/docker-trampoline \
    canning.py "{{ ds }}" "{{ execution_date.isoformat() }}" "{{ (execution_date + dag.schedule_interval).isoformat() }}" \
    --reports-raw-root /data/ooni/private/reports-raw \
    --canned-root /data/ooni/private/canned
