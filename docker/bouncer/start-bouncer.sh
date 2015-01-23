#!/bin/sh
mkdir -p /data/bouncer/etc
mkdir -p /data/bouncer/var/log/ooni
docker run -d --name="ooni-canonical-bouncer" -v /data/bouncer/var/log/ooni:/var/log/ooni -v /data/bouncer/:/var/spool/ooni/backend/ ooni/bouncer
