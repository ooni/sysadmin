# OONI MetaDB Sharing

This document will explain how you can setup a copy of the OONI metadb which
powers the OONI API and Explorer.

This can be useful to third parties that would like to do more advanced
analysis and presentations that are not currently supported by existing OONI
tools.

Last updated: 19th April

## Requirements

MUST:

* OS: `Linux`
* Architecture: `x86_64`
* Postgres version: `9.6`

Recommended:

* OS: Ubuntu > 16.04
* Memory: 16 GB
* vCPU: 4 cores
* Disk space: 1 TB

To get a better understanding of the current disk size requirements you can run:
```
curl -sS https://ooni-data.s3.amazonaws.com/metadb/Linux-x86_64-9.6/base/$(curl -sS https://ooni-data.s3.amazonaws.com/metadb/Linux-x86_64-9.6/base/latest)/pgdata.index.gz | zcat | awk '{s += $2} END {print s / 1073741824, "GiB"}'
```

## Setup

This guide has been tested on AWS using the instance type `t3.xlarge` with
`Ubuntu Server 16.04 LTS` (`ami-0565af6e282977273`), but should work on any
similar setup with minor adjustments.

### Create a VM and restore the metadb data dir from backup

1. Create a new EC2 instance `t3.xlarge` with AMI `Ubuntu Server 16.04 LTS`

2. In the Step 4. Add Storage add EBS volume of 1000GB of size

3. Login to the machine

4. Format and mount the volume. On EC2 with EBS this is done via (as root):
```
lsblk # This will tell you the volume label
mkfs -t ext4 /dev/nvme1n1 # to format it
mount /dev/nvme1n1 /mnt/ # mount it
```

5. Create a directory on the volume for the metadb dump
```
mkdir /mnt/metadb
```

6. Download the metadb sync script and run it:
```
wget https://raw.githubusercontent.com/ooni/sysadmin/master/scripts/metadb_s3_tarx
chmod +x metadb_s3_tarx
apt install make bc # Install some requirements
time ./metadb_s3_tarx DEST=/mnt/metadb fetch # This will take 1-2h to complete, so you should run it in a screen session or similar
```

### Install and configure PostgreSQL

It's very important that you use the exact version of postgresql we are using,
which at the time of writing is 9.6.

1. Add the postgresql repository
```
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release --short --codename)-pgdg main"
sudo apt update
```

2. Install postgresql
```
sudo apt install postgresql-9.6
```

3. Configure the postgres service to use the backed up metadb data dir and to be a `hot_standby`
```
sudo systemctl stop postgresql@9.6-main.service
sudo mv /var/lib/postgresql/9.6/main /var/lib/postgresql/9.6/main.dist
sudo chown -R postgres:postgres /mnt/metadb
sudo chmod 0700 /mnt/metadb
sudo ln -s /mnt/metadb /var/lib/postgresql/9.6/main
echo "hot_standby = 'on'" | sudo -u postgres dd of=/etc/postgresql/9.6/main/conf.d/hot_standby.conf
```

4. Restart the postgres service
```
sudo systemctl start postgresql@9.6-main.service
```

5. Check that it's up to date with the latest processed bucket:
```
sudo -u postgres psql -U postgres metadb -c 'SELECT MAX(bucket_date) FROM autoclaved'
```
You will get an error saying `FATAL:  the database system is starting up` until the WAL logs have been fully restored.
If you want you can monitor progress by doing `tail -f /var/log/postgresql/postgresql-9.6-main.log`.
Don't be scared if you see log lines saying `curl: (22) The requested URL
returned error: 404 Not Found` that is expected behavior and it means your
replica is in sync.

When you finally see as a result a `bucket_date` which is the day of yesterday the process is complete.

Congratulations you now have a working copy of the OONI metadb! :tada:

Have fun!
