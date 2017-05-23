#!/bin/sh
exec sudo --non-interactive /usr/local/bin/docker-trampoline \
    centrifugation.py "{{ ds }}" "{{ execution_date.isoformat() }}" "{{ (execution_date + dag.schedule_interval).isoformat() }}" \
    --mode simhash-text \
    --autoclaved-root /data/ooni/public/autoclaved \
    --simhash-root /data/ooni/public/simhash
