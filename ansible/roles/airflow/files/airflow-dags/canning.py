# -*- coding: utf-8 -*-
import subprocess
from airflow import DAG
from airflow.exceptions import AirflowException # signal ERROR
from airflow.operators.bash_operator import BashOperator
from airflow.operators.sensors import BaseSensorOperator
from datetime import datetime, timedelta

class ReportsRawReadySensor(BaseSensorOperator):
    def poke(self, context):
        retcode = subprocess.call(['sudo', '--non-interactive', '/usr/local/bin/docker-trampoline', 'is-reports-raw-ready',
            context['ds'], context['execution_date'].isoformat(), (context['execution_date'] + context['dag'].schedule_interval).isoformat()])
        if retcode == 42:
            return True
        elif retcode == 13:
            return False
        else:
            raise AirflowException('Unexpected `is-reports-raw-ready` exit code: {:d}'.format(retcode))

dag = DAG(
    dag_id='hist_canning',
    schedule_interval=timedelta(days=1),
    start_date=datetime(2012, 12, 5),
    end_date=datetime(2017, 7, 5), # NB: end_date is included
    default_args={
        'email': 'leon+airflow@darkk.net.ru',
        'retries': 1,
    })

BashOperator(
    pool='datacollector_disk_io',
    task_id='canning',
    bash_command='canning.sh',
    dag=dag)

BashOperator(
    pool='datacollector_disk_io',
    task_id='autoclaving',
    bash_command='autoclaving.sh',
    dag=dag)

BashOperator(
    pool='datacollector_disk_io',
    task_id='simhash_text',
    bash_command='simhash_text.sh',
    dag=dag)

BashOperator(pool='datacollector_disk_io', task_id='meta_pg', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='reports_raw_s3_ls', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='reports_raw_cleanup', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='sanitised_s3_ls', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='sanitised_check', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='sanitised_cleanup', bash_command='shovel_jump.sh', dag=dag)

dag.set_dependency('canning', 'autoclaving')
dag.set_dependency('autoclaving', 'simhash_text')
dag.set_dependency('autoclaving', 'meta_pg')

dag.set_dependency('reports_raw_s3_ls', 'reports_raw_cleanup')
dag.set_dependency('canning', 'reports_raw_cleanup')

dag.set_dependency('autoclaving', 'sanitised_check')

dag.set_dependency('autoclaving', 'sanitised_cleanup')
dag.set_dependency('sanitised_s3_ls', 'sanitised_cleanup')
dag.set_dependency('sanitised_check', 'sanitised_cleanup')
