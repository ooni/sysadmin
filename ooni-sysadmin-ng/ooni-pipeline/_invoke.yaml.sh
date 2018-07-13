#!/bin/sh

# exit on unset variable or non-0 return code.
set -eu

cat <<EOF
core:
  tmp_dir: "/tmp"
  ssh_private_key_file: null
  ooni_pipeline_path: "/home/centos/ooni-pipeline"
aws:
  access_key_id: "$aws_key_id"
  secret_access_key: "$aws_key"
  ssh_private_key_file: "private/ooni-pipeline.pem"
kafka:
  hosts: "127.0.0.1:9092"
logging:
  filename: "ooni-pipeline.log"
  level: "INFO"
spark:
  spark_submit: "/home/hadoop/spark/bin/spark-submit"
  master: "yarn-client"
postgres:
  host: "$postgres_host"
  database: "ooni_pipeline"
  username: "ooni"
  password: "$postgres_password" 
  table: "reports"
celery:
  broker_url: ""
  result_backend: ""
ooni:
  bridge_db_path: "s3n://ooni-private/bridge_reachability/bridge_db.json"
EOF
