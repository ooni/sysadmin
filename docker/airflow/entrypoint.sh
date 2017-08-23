#!/usr/bin/env bash

AIRFLOW_HOME="/usr/local/airflow"
CMD="airflow"
TRY_LOOP="20"

: ${REDIS_HOST:="redis"}
: ${REDIS_PORT:="6379"}
: ${REDIS_PASSWORD:=""}
: ${REDIS_DB:="0"}

: ${POSTGRES_HOST:="postgres"}
: ${POSTGRES_PORT:="5432"}
: ${POSTGRES_USER:="airflow"}
: ${POSTGRES_PASSWORD:="airflow"}
: ${POSTGRES_DB:="airflow"}

: ${SMTP_HOST:=""}
: ${SMTP_PORT:=""} # default is 465 for smtps, 587 for other
: ${SMTP_SECURITY:="starttls"} # starttls / smtps (SMTP over TLS) / insecure
: ${SMTP_USER:=""} # SMTP auth
: ${SMTP_PASSWORD:=""}
: ${SMTP_MAIL_FROM:=""} # both `From` header and `MAIL FROM` SMTP envelope

: ${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}

if [ -n "$FERNET_KEY" ] && ! python -c 'import cryptography.fernet, sys; cryptography.fernet.Fernet(sys.argv[1])' "$FERNET_KEY"; then
    echo "$(date) - malformed FERNET_KEY disables encryption"
    exit 1
fi

# Configure SMTP
if [ -n "$SMTP_HOST" ]; then
    case "$SMTP_SECURITY" in
        starttls)
            sed -i "s/[# ]*smtp_ssl\>.*/smtp_ssl = False/; s/[# ]*smtp_starttls\>.*/smtp_starttls = True/" "$AIRFLOW_HOME"/airflow.cfg
            grep -q '^smtp_starttls = True$' "$AIRFLOW_HOME"/airflow.cfg || exit 1 # defence against forgotten variable in airflow.cfg
            ;;
        smtps)
            sed -i "s/[# ]*smtp_ssl\>.*/smtp_ssl = True/; s/[# ]*smtp_starttls\>.*/smtp_starttls = False/" "$AIRFLOW_HOME"/airflow.cfg
            grep -q '^smtp_ssl = True$' "$AIRFLOW_HOME"/airflow.cfg || exit 1 # defence
            ;;
        insecure)
            sed -i "s/[# ]*smtp_ssl\>.*/smtp_ssl = False/; s/[# ]*smtp_starttls\>.*/smtp_starttls = False/" "$AIRFLOW_HOME"/airflow.cfg
            ;;
        *)
            echo "$(date) - malformed SMTP_SECURITY (${SMTP_SECURITY})"
            exit 1
            ;;
    esac
    sed -i "s/[# ]*smtp_host\>.*/smtp_host = ${SMTP_HOST}/" "$AIRFLOW_HOME"/airflow.cfg
    if [ -z "$SMTP_PORT" ]; then
        case "$SMTP_SECURITY" in
            starttls|insecure) SMTP_PORT=587 ;;
            smtps)             SMTP_PORT=465 ;;
        esac
    fi
    sed -i "s/[# ]*smtp_port\>.*/smtp_port = ${SMTP_PORT}/" "$AIRFLOW_HOME"/airflow.cfg
    if [ -n "$SMTP_USER" ]; then
        sed -i "s/[# ]*smtp_user\>.*/smtp_user = ${SMTP_USER}/" "$AIRFLOW_HOME"/airflow.cfg
    fi
    if [ -n "$SMTP_PASSWORD" ]; then
        sed -i "s/[# ]*smtp_password\>.*/smtp_password = ${SMTP_PASSWORD}/" "$AIRFLOW_HOME"/airflow.cfg
    fi
    if [ -n "$SMTP_MAIL_FROM" ]; then
        sed -i "s/[# ]*smtp_mail_from\>.*/smtp_mail_from = ${SMTP_MAIL_FROM}/" "$AIRFLOW_HOME"/airflow.cfg
    fi
fi

# Load DAGs examples (default: Yes)
if [ "$LOAD_EX" = "n" ]; then
    sed -i "s/load_examples = True/load_examples = False/" "$AIRFLOW_HOME"/airflow.cfg
fi

# Install custom python package if requirements.txt is present
if [ -e "/requirements.txt" ]; then
    $(which pip) install --user -r /requirements.txt
fi

# Update airflow config - Fernet key
sed -i "s|\$FERNET_KEY|$FERNET_KEY|" "$AIRFLOW_HOME"/airflow.cfg

# Wait for Postresql
if [ "$1" = "webserver" ] || [ "$1" = "worker" ] || [ "$1" = "scheduler" ] ; then
  i=0
  while ! nc -z $POSTGRES_HOST $POSTGRES_PORT >/dev/null 2>&1 < /dev/null; do
    i=$((i+1))
    if [ "$1" = "webserver" ]; then
      echo "$(date) - waiting for ${POSTGRES_HOST}:${POSTGRES_PORT}... $i/$TRY_LOOP"
      if [ $i -ge $TRY_LOOP ]; then
        echo "$(date) - ${POSTGRES_HOST}:${POSTGRES_PORT} still not reachable, giving up"
        exit 1
      fi
    fi
    sleep 10
  done
fi

if [ -n "$REDIS_PASSWORD" ]; then
    REDIS_CRED=":${REDIS_PASSWORD}@"
else
    REDIS_CRED=""
fi

# Update configuration depending the type of Executor
if [ "$EXECUTOR" = "Celery" ]
then
  # Wait for Redis
  if [ "$1" = "webserver" ] || [ "$1" = "worker" ] || [ "$1" = "scheduler" ] || [ "$1" = "flower" ] ; then
    j=0
    while ! nc -z $REDIS_HOST $REDIS_PORT >/dev/null 2>&1 < /dev/null; do
      j=$((j+1))
      if [ $j -ge $TRY_LOOP ]; then
        echo "$(date) - $REDIS_HOST still not reachable, giving up"
        exit 1
      fi
      echo "$(date) - waiting for Redis... $j/$TRY_LOOP"
      sleep 5
    done
  fi
  sed -i "s#celery_result_backend = db+postgresql://airflow:airflow@postgres/airflow#celery_result_backend = db+postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB#" "$AIRFLOW_HOME"/airflow.cfg
  sed -i "s#sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@postgres/airflow#sql_alchemy_conn = postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB#" "$AIRFLOW_HOME"/airflow.cfg
  sed -i "s#broker_url = redis://redis:6379/1#broker_url = redis://${REDIS_CRED}$REDIS_HOST:$REDIS_PORT/${REDIS_DB}#" "$AIRFLOW_HOME"/airflow.cfg
  if [ "$1" = "webserver" ]; then
    echo "Initialize database..."
    $CMD initdb
    exec $CMD webserver
  else
    sleep 10
    exec $CMD "$@"
  fi
elif [ "$EXECUTOR" = "Local" ]
then
  sed -i "s/executor = CeleryExecutor/executor = LocalExecutor/" "$AIRFLOW_HOME"/airflow.cfg
  sed -i "s#sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@postgres/airflow#sql_alchemy_conn = postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB#" "$AIRFLOW_HOME"/airflow.cfg
  sed -i "s#broker_url = redis://redis:6379/1#broker_url = redis://${REDIS_CRED}$REDIS_HOST:$REDIS_PORT/${REDIS_DB}#" "$AIRFLOW_HOME"/airflow.cfg
  echo "Initialize database..."
  $CMD initdb
  exec $CMD webserver &
  exec $CMD scheduler
# By default we use SequentialExecutor
else
  if [ "$1" = "version" ]; then
    exec $CMD version
    exit
  fi
  sed -i "s/executor = CeleryExecutor/executor = SequentialExecutor/" "$AIRFLOW_HOME"/airflow.cfg
  sed -i "s#sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@postgres/airflow#sql_alchemy_conn = sqlite:////usr/local/airflow/airflow.db#" "$AIRFLOW_HOME"/airflow.cfg
  echo "Initialize database..."
  $CMD initdb
  exec $CMD webserver
fi
