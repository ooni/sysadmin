Below are some notes on how to perform an upgrade from PostgreSQL 9 to PostgreSQL 12.

These commands have been tested on a AWS debian buster host. The will most
likely also work on a similar setup.

You will need to install both pg12 and pg9, with the following commands:

```
sudo apt-get install gnupg
sudo vi /etc/apt/sources.list.d/postgresql
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo   apt-get install postgresql-12
sudo apt-get install postgresql-server-dev-12
sudo apt-get install postgresql-9.6
sudo systemctl stop postgresql@9.6-main.service
sudo systemctl stop postgresql@12-main.service
```

The data directory from PostgreSQL 9 should be copied into `/sr/pl-psql` from the old host.

You should then fix the permissions and symlink it to the canonical location:
```
sudo chown -R postgres:postgres /srv/pl-psql
sudo ln -s /srv/pl-psql /var/lib/postgresql/9.6/main
sudo ln -s /srv/pl-psql-12 /var/lib/postgresql/12/main
```

We are going to be restoring pg12 into `/srv/pl-psql-12`

Since you probably ran the upgrade command from a running instance, you should
delete the pidfile to ensure the upgrade command doesn't complain that pg is
still running, like so:

```
sudo rm /srv/pl-psql/postmaster.pid
```

The PG9 installation of the OONI metadb has an issue related to the docker image being used:
https://github.com/bitnami/bitnami-docker-postgresql/issues/74

Basically some of the default tables have an non default locale set to them, so the upgrade process will not work because it will complain of a local mismatch between the source and target database.

This can be fixed by starting the PG12 instance (the target) and running on the
database the following queries:
```
UPDATE pg_database SET datcollate='en_US.utf8', datctype='en_US.utf8' WHERE datname='postgres';
UPDATE pg_database SET datcollate='en_US.utf8', datctype='en_US.utf8' WHERE datname='template1';
```

Once this is done, you will now be able to perform a database upgrade by running:
```
sudo -H -u postgres /usr/lib/postgresql/12/bin/pg_upgrade \
    --link \
    -b /usr/lib/postgresql/9.6/bin/ \
    -B /usr/lib/postgresql/12/bin/ \
    -d /srv/pl-psql \
    -D /srv/pl-psql-12/ \
    -o '-c config_file=/srv/pl-psql/postgresql.conf' \
    -O '-c config_file=/etc/postgresql/12/main/postgresql.conf'
```

The `--link` command will not copy the files to the destination, but just symlink them,k making you save up on a lot of disk space!

You can now start your fresh you pg12 database!
```
sudo systemctl start postgresql@12-main.service
```
