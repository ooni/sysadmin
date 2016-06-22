#!/bin/bash
mkdir -pv \
  /data/bouncer/{tls,archive,tor,decks,inputs,raw_reports,etc/ooni,var/log/ooni}
docker run --net=host -d --name="ooni-canonical-bouncer" \
	-v /data/bouncer/var/log/ooni:/var/log/ooni \
	-v /data/bouncer/:/usr/share/ooni/backend/ \
	-v /data/bouncer/inputs/:/usr/share/ooni/backend/inputs \
	-v /data/bouncer/decks:/usr/share/ooni/backend/decks ooni/bouncer \
	-v /data/bouncer/etc/ooni:/etc/ooni
