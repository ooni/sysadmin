# Streaming PostgreSQL replication

This is a fast guide for setting up a hot standby slave PostgreSQL server that
runs read-only queries for replication or migration purposes with minimal
downtime.

1. Create a replication user on the **master** PostgreSQL server:

`CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'aPassw0rd';"`

2. Enable access for replication user to `pg_hba.conf`

`hostssl replication replicator IP/32 md5`

3. Set streaming replication in **master** `postgresql.conf` and restart
   PostgreSQL:

```
wal_level = hot_standby
max_wal_size = 2GB
max_wal_senders = 7

```

4. **Slave** streaming replication configuration `postgresql.conf`:

```
wal_level = hot_standby
max_wal_senders = 15
hot_standby = on
```

**Note**: This is a basic setup of a rather small DB (250G). You could experiment
with the options: `max_wal_senders` to set the maximum number of concurrent
connections from standby servers, `max_wal_size` (default 1G) and
`min_wal_size` (default 80M).

5. While PostgreSQL is stopped in **slave** remove the old cluster directory:

`rm -rf /var/lib/postgresql/9.5/main`

6. Initiate a base backup with `pb_basebackup`

`su - postgres -c "pg_basebackup -v -P -h IP -D /var/lib/postgresql/9.5/main \
-U replicator -v -P -c fast -X stream"`

7. Add a `recovery.conf` file (in Debian under `/var/lib/postgresql/9.5/main/`)
   with similar contents:

```
standby_mode = 'on'
primary_conninfo = 'host=IP port=5432 user=replicator password=aPassw0rd'
# Standby mode is exited and the server switches to normal operation when
# pg_ctl promote is run or a trigger file is found (trigger_file).
trigger_file = '/tmp/postgresql.trigger.8u2js12x'
```

8. Start PostgreSQL service in slave and check the status of replication in
   **master** with:

`su - postgres -c 'psql -x -c "select * from pg_stat_replication;"'`

You should see something similar:

```
pid  | usesysid |  usename   | application_name | client_addr | client_hostname | client_port |         backend_start         | backend_xmin |   state   | sent_location | write_location | flush_location | replay_location | sync_priority | sync_state
------+----------+------------+------------------+-------------+-----------------+-------------+-------------------------------+--------------+-----------+---------------+----------------+----------------+-----------------+---------------+------------
 3053 | 16969670 | replicator | walreceiver      | IP         |                 |       53132 | 2016-08-27 17:29:59.025767+02 |              | streaming | 76/54003310   | 76/54003310    | 76/540060E8    | 76/540060E8     |             0 | async
(1 row)
```

9. Additional checks to ensure is working in **slave**:

`su - postgres -c 'psql select pg_is_in_recovery();` should show true (t).

PostgreSQL should show something similar to:

`LOG:  database system is ready to accept read only connections`

## Further documentation

* https://www.postgresql.org/docs/9.5/static/hot-standby.html
* http://www.rassoc.com/gregr/weblog/2013/02/16/zero-to-postgresql-streaming-replication-in-10-mins/
