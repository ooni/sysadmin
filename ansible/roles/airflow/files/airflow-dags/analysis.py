# -*- coding: utf-8 -*-
#
# Use the existing shovel_jump.sh script to start the analysis script
#
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

dag = DAG(
    dag_id="analysis",
    schedule_interval=timedelta(days=1),
    start_date=datetime(2019, 6, 21),
    catchup=False,
    default_args={"retries": 0},
)
with dag:
    BashOperator(task_id="analysis", bash_command="shovel_jump.sh")
