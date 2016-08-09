# OONI sysadmin

In here shall go all code related to system administration of the OONI
infrastructure.


# OONI infrastructure overview


## Backend infrastructure

hostname | role | maintainers | notes |
------------- | ------------- | ----------- |----------- |
bouncer.infra.ooni.nu         | canonical bouncer, canonical collector |hellais, anadahz| |
vps770.greenhost.nl  | collector bridge reachability,  |hellais, anadahz| |
ooni-1.default.orgtech.uk0.bigv.io | collector, reports mirror |hellais, anadahz| |
ooni-deb         | debian repository, collector |hellais, aagbsn | what should we do 'bout this? |
marcello         | development/playground |hellais | |
ooni-tpo-collector | backup collector |hellais, aagbsn | |
manager.infra.ooni.nu         | DISCONTINUED |hellais | |
pipeline.infra.ooni.nu | DISCONTINUED | hellais, anadahz| |

## Probing infrastructure

hostname | role | maintainers | notes | next due date
-------- | ---- | ---------- | ------ |------------- |
probe ru | bridge reachability study | hellais, griffin | are these OK? | |
probe ua | bridge reachability study | hellais, griffin | are these OK? | |
probe cn | bridge reachability study | hellais | this is offline. | 2015-05-10 |
probe ir | bridge reachability study | hellais | is this still live? /me thinks not | 2015-03-21 |

hostname | role | maintainers | notes | cost | next due date
-------- | ---- | ---------- | ------ |----- |------------- |
probe ru | bridge reachability study | hellais, griffin | | 0 EUR/month | |
probe ua | bridge reachability study | hellais, griffin| | 0 EUR/month | |
probe cn | bridge reachability study | hellais | | 10 USD/month | 2015-05-10
probe ir | bridge reachability study | hellais | | 30 USD/month | 2015-03-21


## Donate to support OONI infrastructure

Send bitcoins to:
![bitcoin address](http://i.imgur.com/ILdOJ3V.png)
```
16MAyUCxfk7XiUjFQ7yawDhbGs43fyFxd
```

# Ansible roles

This is the section for using ansible roles to install and configure OONI
components.

Note: In order to use ansible you need Python 2.4 or later, but if you are
running less than Python 2.5 on the remote hosts, you will also need the
[python-simplejson]
(https://docs.ansible.com/ansible/intro_installation.html#managed-node-requirements)
package.

For Debian like systems you could use something similar to:
```
ansible host-group -i hosts-inventory-file -m raw -a \
"apt-get update && apt-get -y install python-simplejson"
```

## ooni-backend

This ansible role installs ooni-backend from git repo via pip in a python
virtual environment (virtualenv). The ooni-backend service is being started and
controlled via the [Supervisor](http://supervisord.org) service. This role
can be used for Debian releases and has been tested in Wheesy and Jessie Debian
releases.

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-oonibackend.yml -v
```
Note: The inventory file should include hosts in custom group.

## ooniprobe

This ansible role install ooniprobe via apt (stretch repo) or via pip from this
the git repo. This role can be used for Debian releases and has been tested in
Wheesy and Jessie Debian releases. By seting the conditional variable
`set_ooniprobe_pip` to true ooniprobe will be istalled from git via pip.
Setting the conditional variable `set_ooniprobe_go` to true will install the
golang-go package.

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-ooniprobe.yml -v
```

## Third party tools

This ansible role install third party tools required for some ooniprobe
tests. The following third party tools can be installed with this role:

Tool|oooniprobe test
----|---------------
OpenVPN|https://github.com/TheTorProject/ooni-spec/blob/master/test-specs/ts-015-openvpn.md
Psiphon|https://github.com/TheTorProject/ooni-spec/blob/master/test-specs/ts-014-psiphon.md
Lantern|https://github.com/TheTorProject/ooni-spec/blob/master/test-specs/ts-012-lantern.md

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-thirdparty.yml -v
```

## tor pluggable transports

This ansible role install the tor pluggable transports required for ooniprobe
bridge reachability test. The following tor pluggable transports will be
installed with this role:

Pluggagle Transport
-------------------
fteproxy
obfsproxy (obfs2,obfs3,scramblesuit)
obfs4proxy
meek (not implemented yet in bridge reachability test)

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-tor-pluggagle-trans.yml -v
```

## letsencrypt role

This ansible role installs the required dependencies and generates letsencrypt
certificates. Additionally is sets a monthly cron job that renews if needed the
generated certificates.

The role has 2 modes of deployment: docker ( variable flag letsencrypt_docker)
based and distribution package based (default).

Note: Currently the docker role deployment has no support to restart
ooni-backend services and the default role (software package deployment) should
be used instead.

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-letsencrypt.yml -v
```

## install tor bridge (obfs4)

This role install the dependencies needed for an obfs4proxy bridge, provisions
the bridge and fetches the fingerprint and the corresponding generated client
`torrc` configuration bridge line.
This role should be running with the following tags:
`install_tor`, `upgrades` and `install_obfs4`.

### execute role

```
ansible-playbook -i hosts ansible/install-tor-bridge.yml --tags "install_tor,upgrades,install_obfs4"
```

# Instructions

Unless otherwise indicated the instructions are for debian wheezy.

## Setting up docker

```
# Install kernel >3.8
echo "deb http://http.debian.net/debian wheezy-backports main" >> /etc/apt/sources.list
apt-get update
apt-get install -t wheezy-backports linux-image-amd64
apt-get install curl
# Install docker
curl -sSL https://get.docker.com/ | sh
```

# Disaster recovery procedure

This is the procedure to restore all the system of the OONI infrastructure if
everything goes bad.

## Restore OONI pipeline

```
cd ansible/server_migration/
ansible-playbook -i hosts pipeline.yml -vvvv
```

# M-Lab deployment
M-Lab [deployment process]
(https://github.com/m-lab/ooni-support/#m-lab-deployment-process).

# Upgrading OONI infrastructure

## ooni-backend

Collected notes on how to successful upgrade a running ooni-backend (bouncer
and collector).

1. Build the docker image of the new bouncer.
2. Start the new docker image mapping a new bouncer directory that is not the
   live one.
3. Run a couple of tests against the newly created image by specifying a custom
   bouncer and collector (the new one).
4. Take down the old bouncer.
5. Take up the new bouncer.

Currently ooni-backend is running in a docker build the most painful way to
upgrade to a new backend version is to create a new docker build image and use
temporary mapping volume directories.
After successfully building (you have already test it right?) the docker image
we should re-run the newly created docker image *but* with the correct (the
ones in the build script) volume directories.
The reports in progress will fail and schedule retries once the new bouncer and
collector are back up.

### Common pitfalls

* Ensure that the HS private keys of bouncer and collector are in right PATH
(collector/private_key , bouncer/private_key).
* Set the bouncer address in bouncer.yaml to the correct HS address.
* ooni-backend will *not* generate missing directories and fail to start

### Testing

Running a short ooni-probe test will ensure that the backend has been
successfully upgraded, an example test:

```
ooniprobe --collector httpo://CollectorAddress.onion blocking/http_requests \
--url http://ooni.io/
```
