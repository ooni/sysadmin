# OONI sysadmin

In here live all the tools and scripts related to administering the
infrastructure that are part of OONI.

# Getting started

It is recommended you use a [python virtualenv](https://virtualenv.pypa.io/en/latest/) to install ansible and dnspython.

Once you activate the virtualenv you can install the correct version of ansible and dnspython with:

```
pip install ansible==2.9.16
```


# Ansible roles

It is required for all OONI team to run the same ansible version to minimise
compatibility issues.
All playbooks should include `ansible-version.yml` at the beginning of the
playbook, by including:
```
---
- import_playbook: ansible-version.yml
```

If you need some python packages **only** for ansible module to
work and don't need it in system-wide pip repository, then you should put these
modules in separate virtual environment and set proper
`ansible_python_interpreter` for the play. See `docker_py` role and grep for
`/root/venv` for examples.

If you need to store secrets in repository then store them as vaults using
`ansible/vault` script as a wrapper for `ansible-vault`. Store encrypted
variables with `vault_` prefix to make world [a more grepable place](http://docs.ansible.com/ansible/playbooks_best_practices.html#best-practices-for-variables-and-vaults)
and link location of the variable using same name without prefix in corresponding `vars.yml`.
`scripts/ansible-syntax-check` checks links between vaults and plaintext files during Travis build.
`ansible/play` wrapper for `ansible-playbook` will execute a playbook with
proper vault secret and inventory.

# SSH Config

You should configure your `~/.ssh/config` with the following:

```
Ciphers aes128-ctr,aes256-ctr,aes128-cbc,aes256-cbc
IdentitiesOnly yes
ServerAliveInterval 120
UserKnownHostsFile ~/.ssh/known_hosts ~/PATH/TO//ooni/sysadmin/ext/known_hosts

```

Replace `~/PATH/TO//ooni/sysadmin/ext/known_hosts` to where you have cloned the
`ooni/sysadmin` repo. This will ensure you use the host key fingeprints from
this repo instead of just relying on TOFU.

You probably also want to add:

```
host *.ooni.io
  user USERNAME
  identityfile ~/.ssh/id_rsa

host *.ooni.nu
  user USERNAME
  identityfile ~/.ssh/id_rsa
```

You should replace `USERNAME` with your username from `adm_login`.

On macOS you may want to also add:
```
host *
    UseKeychain yes
```

To use the Keychain to store passwords.

# M-Lab deployment

M-Lab [deployment process](https://github.com/m-lab/ooni-support/#m-lab-deployment-process).

# Upgrading OONI infrastructure

## ooni-backend pitfalls

* Ensure that the HS private keys of bouncer and collector are in right PATH
(collector/private_key , bouncer/private_key).
* Set the bouncer address in bouncer.yaml to the correct HS address.
* ooni-backend will *not* generate missing directories and fail to start

Running a short ooni-probe test will ensure that the backend has been
successfully upgraded, an example test:

```
ooniprobe --collector httpo://CollectorAddress.onion blocking/http_requests \
--url http://ooni.io/
```

# New host HOWTO

- come up with a name for $name.ooni.tld using DNS name policy
- create a VM to allocate IP address
- create `A` record for the domain name in namecheap web UI (API is hell)
- fetch external inventory with `./play ext-inventory.yml`, it'll create a git commit
- add $name.ooni.tld to _location tags_ section of `inventory` file, git-commit it
- write firewall rules to `templates/iptables.filter.part/$name.ooni.tld` if needed, git-commit it
- bootstrap VM with `./play dom0-bootstrap.yml -l $name.ooni.tld`
- update Prometheus with `./play deploy-prometheus.yml -t prometheus-conf`
- check `inventory` sanity with `./play inventory-check.yml` (everything should be `ok`, no changes, no failures), update `inventory-check.yml` with new checksum, git-commit it
- `git push` those commits

## DNS name policy

Public HTTP services are named `${service}.ooni.org` or `${service}.ooni.io`
(legacy). _Public_ means that it's part of some external system we can't
control: published APP or MK versions, web URLs and so on. Public names should
not be used as an `inventory_hostname` to ease migration.

VMs should have FQDN like `${location}-${name}-${number}.ooni.org`.
VMs can provide one or more public-facing services that can change over time.
The name should be as descriptive as possible e.g. the type of services
or the most important service being run. 

Various legacy names should be cleaned up during re-deploying VMs with newer
base OS version.

# Rename host HOWTO

First, try hard to avoid renaming hosts. It's pain:

- inventory_hostname is stamped in Prometheus SSL certificates
- inventory_hostname is stamped as FQDN inside of firewall rules
- inventory_hostname is stamped as filename for firewall rules
- hostname is stamped in `/etc/hosts` on the host
- hostname is stamped as `kernel.hostname` on the host
- some applications use hostname as configuration value, e.g. [MongoDB](https://docs.mongodb.com/manual/tutorial/change-hostnames-in-a-replica-set/)

But re-deploying is not also an options sometimes due to GH platform limitations.  So...

- use _New host HOWTO_ as a checklist to keep in mind
- `on-rename` tag can save some time while running `dom0-bootstrap`: `./play dom0-bootstrap.yml -t on-rename -l $newname.ooni.tld`
- grep ooni/sysadmin for `inventory_hostname`, $oldname, $newname (NB: not just oldname.ooni.tld, short name may be used somewhere as well)

# PostgreSQL replica bootstrap

[`pg_basebackup`](https://www.postgresql.org/docs/current/static/app-pgbasebackup.html)
is nice, but does not support network traffic compression out of box and has no
obvious way to resume interrupted backup. `rsync` solves that issue, but it
needs either WAL archiving (to external storage) to be configured or
`wal_keep_segments` to be non-zero, because otherwise WAL logs are rotated ASAP
(`min_wal_size` and `max_wal_size` do not set amount of WAL log available to
reader, these options set amount of disk space allocated to writer!).
Also [replication slot](https://www.postgresql.org/docs/current/static/functions-admin.html#FUNCTIONS-REPLICATION)
may reserve WAL on creation, but beware, it postpones WAL reservation till replica connection by default.

[`pg_start_backup()`](https://www.postgresql.org/docs/current/static/continuous-archiving.html#BACKUP-LOWLEVEL-BASE-BACKUP) +
`rsync -az --exclude pg_replslot --exclude postmaster.pid --exclude postmaster.opts` is a way to go.
And, obviously, don't exclude `pg_wal` (aka `pg_xlog`) if neither WAL archiving nor replication slot is not set up.

And don't forget to revoke `authorized_keys` if SSH was used for `rsync`!

You may also want to bootstrap the replica [from MetaDB snapshot in S3](docs/metadb-sharing.md)
and switch it to streaming replication afterwards.

# Updating firewall rules

If you need to update the firewalling rules, because you added a new host to
the `have_fw` group or you changed the hostname of a host, you should edit the
file `templates/iptables.filter.part/$HOSTNAME` and then run:

```
./play dom0-bootstrap.yml -t fw
```
