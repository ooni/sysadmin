# Streaming PostgreSQL replication

This is a fast guide for setting up a hot standby slave PostgreSQL server that
runs read-only queries for replication or migration purposes with minimal
downtime.

Since PostgreSQL 9.4 we can use a new feature; `pg_replication_slots` provide
an automated way to ensure that the master does not remove WAL segments until
they have been received by all standbys. For this feature to take effect we
need to set `max_replication_slots` > 1 in `postgresql.conf` and create a
replication slot name.

0. Create a replication slot name in **master** PostgreSQL server:
`SELECT * FROM pg_create_physical_replication_slot('replication_node');`

1. Create a replication user on the **master** PostgreSQL server:

`CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'aPassw0rd';"`

2. Enable access for replication user to `pg_hba.conf`

`hostssl replication replicator IP/32 md5`

3. Set streaming replication in **master** `postgresql.conf` and restart
   PostgreSQL:

```
wal_level = hot_standby
max_wal_senders = 7
max_replication_slots = 1

```

4. **Slave** streaming replication configuration `postgresql.conf`:

```
wal_level = hot_standby
max_wal_senders = 7
hot_standby = on
```

**Note**: `max_worker_processes` should match in both master and slave config.

5. While PostgreSQL is stopped in **slave** remove the old cluster directory:

`rm -rf /var/lib/postgresql/9.5/main`

6. Initiate a base backup with `pb_basebackup`

`su - postgres -c "pg_basebackup -v -P -h IP -D /var/lib/postgresql/9.5/main \
-U replicator -c fast -X stream"`

7. Add a `recovery.conf` file (in Debian under `/var/lib/postgresql/9.5/main/`)
   with similar contents:

```
standby_mode = 'on'
primary_conninfo = 'host=IP port=5432 user=replicator password=aPassw0rd'
# Standby mode is exited and the server switches to normal operation when
# pg_ctl promote is run or a trigger file is found (trigger_file).
trigger_file = '/tmp/postgresql.trigger.8u2js12x'
primary_slot_name = 'replication_node'
```

**Note**: Check that `recovery.conf` can be accessed by postgres user (`chown
postgres: /var/lib/postgresql/9.5/main/recovery.conf`).

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

PostgreSQL log should show something similar to:

`LOG:  database system is ready to accept read only connections`

## Promote slave to be the current master

In case of failure or migration purposes you should first stop the **master**
PostgreSQL instance (`service postgresql stop`) and promote **slave** to be the
master instead in order to accept read/write connections:

`touch /tmp/postgresql.trigger.8u2js12x`

**Note**: There is no need for PostgreSQL instance in **slave** (current
master) to be restarted. Adding the `trigger_file` set in `recovery.conf` will
trigger PostgreSQL to promote **slave** to **master**.

PostgreSQL log should show something similar to:

```
LOG:  trigger file found: /tmp/postgresql.trigger.8u2js12x
LOG:  redo is not required
LOG:  database system is ready to accept read only connections
LOG:  selected new timeline ID: 3
LOG:  archive recovery complete
```

## Further documentation

* https://www.postgresql.org/docs/9.5/static/hot-standby.html
* http://www.rassoc.com/gregr/weblog/2013/02/16/zero-to-postgresql-streaming-replication-in-10-mins/
* https://wiki.postgresql.org/wiki/Streaming_Replication
* http://blog.2ndquadrant.com/postgresql-9-4-slots/
