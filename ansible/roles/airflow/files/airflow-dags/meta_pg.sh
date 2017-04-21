#!/bin/sh
exec sudo --non-interactive /usr/local/bin/docker-trampoline \
    centrifugation.py "{{ ds }}" "{{ execution_date.isoformat() }}" "{{ (execution_date + dag.schedule_interval).isoformat() }}" \
    --mode meta-pg \
    --autoclaved-root /data/ooni/public/autoclaved \
    --postgres "host=metadb user=oometa password=d88fOBNIBtVJyBf5ySOokV3J"
