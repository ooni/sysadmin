# -*- coding: utf-8 -*-
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

with DAG(
    dag_id='sync_test_lists_dag',
    schedule_interval=timedelta(hours=1),
    start_date=datetime(2018, 10, 21),
    catchup=False,
    default_args={
        'email': 'leonid@openobservatory.org', # prometheus/alertmanager sends to team@ but airflow is more chatty
        'retries': 0,
    }) as fetcher:

    BashOperator(task_id='sync_test_lists', bash_command='shovel_jump.sh')
