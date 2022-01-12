# Gunicorn configuration file
# Managed by ansible, see roles/ooni-backend/tasks/main.yml
# and templates/api.gunicorn.py

workers = 12

loglevel = "info"
proc_name = "ooni-api"
reuse_port = True
statsd_host = "127.0.0.1:8125"
statsd_prefix = "ooni-api"
