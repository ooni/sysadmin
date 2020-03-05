sudo docker run --net=host --rm -ti --user 2100:2100 \
        -v /srv/pl-psql:/srv/pl-psql:rw \
        -v /srv/pl-psql_ssl:/srv/pl-psql_ssl:ro \
        -v /etc/passwd:/etc/passwd:ro \
        -v /etc/groups:/etc/groups:ro \
        --env PGDATA=/srv/pl-psql \
        --env PGDATABASE=metadb \
        --env PGUSER=shovel \
        --env PGPASSWORD="{{ shovel_postgres_password }}" \
        --env PGHOST="37.218.240.56" \
        --env AWS_DEFAULT_REGION=us-east-1 \
        --env AWS_ACCESS_KEY_ID="{{ metadb_wal_s3_key_id }}" \
        --env AWS_SECRET_ACCESS_KEY="{{ metadb_wal_s3_access_key }}" \
        --env PUSHGATEWAY_CERT="/srv/pl-psql_ssl/pusher/{{ inventory_hostname }}.cert" \
        --env PUSHGATEWAY_KEY="/srv/pl-psql_ssl/pusher/{{ inventory_hostname }}.key" \
        openobservatory/sysadmin-postgres-metadb:20190419-572779cb \
        metadb_s3_tarz
