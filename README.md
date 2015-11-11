# OONI sysadmin

In here shall go all code related to system administration of the OONI
infrastructure.


# OONI infrastructure overview


## Backend infrastructure

hostname | role | maintainers | notes |
------------- | ------------- | ----------- |----------- |
bouncer.infra.ooni.nu         | canonical bouncer, canonical collector |hellais, andaraz| | 
vps770.greenhost.nl  | collector bridge reachability,  |hellais, andaraz| |
ooni-1.default.orgtech.uk0.bigv.io | collector, reports mirror |hellais, andaraz| |
ooni-deb         | debian repository, collector |hellais, aagbsn | what should we do 'bout this? | 
marcello         | development/playground |hellais | | 
ooni-tpo-collector | backup collector |hellais, aagbsn | |
manager.infra.ooni.nu         | DISCONTINUED |hellais | | 
pipeline.infra.ooni.nu | DISCONTINUED | hellais, andaraz| |

## Probing infrastructure
hostname | role | maintainers | notes | next due date
-------- | ---- | ---------- | ------ |------------- |
probe ru | bridge reachability study | hellais, griffin | are these OK? | |
probe ua | bridge reachability study | hellais, griffin | are these OK? | |
probe cn | bridge reachability study | hellais | this is offline. | 2015-05-10 |
probe ir | bridge reachability study | hellais | is this still live? /me thinks not | 2015-03-21 |

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
