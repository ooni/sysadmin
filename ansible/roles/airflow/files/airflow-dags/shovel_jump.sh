#!/bin/sh
exec sudo --non-interactive /usr/local/bin/docker-trampoline \
    "{{ task.task_id }}" "{{ ds }}" "{{ execution_date.isoformat() }}" "{{ (execution_date + dag.schedule_interval).isoformat() }}"
