# OONI sysadmin

In here shall go all code related to system administration of the OONI
infrastructure.


# OONI infrastructure overview


## Backend infrastructure

hostname | role | maintainers | notes | cost |
------------- | ------------- | ----------- |----------- |----------- |
pipeline.infra.ooni.nu | pipeline, canonical reports mirror | hellais, andaraz| | 50 USD/month |
bouncer.infra.ooni.nu         | canonical bouncer, canonical collector |hellais, andaraz| | 0 EUR/month | 
vps770.greenhost.nl  | collector bridge reachability,  |hellais, andaraz| | 0 EUR/month |
ooni-1.default.orgtech.uk0.bigv.io | collector, reports mirror |hellais, andaraz| | 0 EUR/month |

## Probing infrastructure
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
