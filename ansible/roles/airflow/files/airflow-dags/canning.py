# -*- coding: utf-8 -*-
import subprocess
from airflow import DAG
from airflow.exceptions import AirflowException # signal ERROR
from airflow.operators.bash_operator import BashOperator
from airflow.operators.sensors import BaseSensorOperator
from datetime import datetime, timedelta

class ReportsRawReadySensor(BaseSensorOperator):
    def poke(self, context):
        retcode = subprocess.call(['sudo', '--non-interactive', '/usr/local/bin/docker-trampoline', 'reports_raw_sensor',
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
    #end_date=datetime(2017, 7, 7), # NB: end_date is included
    default_args={
        'email': 'leonid@openobservatory.org', # prometheus/alertmanager sends to team@ but airflow is more chatty
        'retries': 1,
    })

# NB: removing an Operator from DAG leaves some trash in the database tracking
# old state of that operator, but it seems to trigger no issues with 1.8.0

ReportsRawReadySensor(task_id='reports_raw_sensor', poke_interval=5*60, timeout=12*3600, dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='canning', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='tar_reports_raw', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='reports_tgz_s3_sync', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='reports_tgz_s3_ls', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='reports_tgz_cleanup', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='canned_s3_sync', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='canned_s3_ls', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='canned_cleanup', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='autoclaving', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='meta_pg', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='reports_raw_cleanup', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='sanitised_s3_ls', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='sanitised_check', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='sanitised_cleanup', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='autoclaved_tarlz4_s3_sync', bash_command='shovel_jump.sh', dag=dag)
BashOperator(pool='datacollector_disk_io', task_id='autoclaved_jsonl_s3_sync', bash_command='shovel_jump.sh', dag=dag)

dag.set_dependency('reports_raw_sensor', 'canning')

dag.set_dependency('reports_raw_sensor', 'tar_reports_raw')
dag.set_dependency('canning', 'tar_reports_raw')

dag.set_dependency('tar_reports_raw', 'reports_tgz_s3_sync')

dag.set_dependency('reports_tgz_s3_sync', 'reports_tgz_s3_ls')

# reports_raw_cleanup -> reports_tgz_cleanup is NOT a dependency as reports_raw_cleanup uses only index file
dag.set_dependency('reports_tgz_s3_sync', 'reports_tgz_cleanup') # can't cleanup unless synced
dag.set_dependency('reports_tgz_s3_ls', 'reports_tgz_cleanup') # data dependency

dag.set_dependency('canning', 'canned_s3_sync')

dag.set_dependency('canned_s3_sync', 'canned_s3_ls')

# reports_raw_cleanup -> canned_cleanup is NOT a dependency as reports_raw_cleanup uses only index file
dag.set_dependency('autoclaving', 'canned_cleanup') # uses `canned` data
dag.set_dependency('tar_reports_raw', 'canned_cleanup') # may use `canned` data
dag.set_dependency('canned_s3_sync', 'canned_cleanup') # can't cleanup unless synced
dag.set_dependency('canned_s3_ls', 'canned_cleanup') # data dependency

dag.set_dependency('canning', 'autoclaving')

dag.set_dependency('autoclaving', 'meta_pg')

# reports_raw_cleanup is done when both tasks are finished and have same data
# reports_raw_cleanup does not remove unknown files as a safeguard
dag.set_dependency('canning', 'reports_raw_cleanup')
dag.set_dependency('tar_reports_raw', 'reports_raw_cleanup')

dag.set_dependency('autoclaving', 'sanitised_check')

dag.set_dependency('autoclaving', 'autoclaved_tarlz4_s3_sync')

dag.set_dependency('autoclaving', 'autoclaved_jsonl_s3_sync')

dag.set_dependency('autoclaving', 'sanitised_cleanup')
dag.set_dependency('sanitised_s3_ls', 'sanitised_cleanup')
dag.set_dependency('sanitised_check', 'sanitised_cleanup')
