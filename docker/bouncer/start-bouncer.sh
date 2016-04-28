#!/bin/sh
mkdir -p /data/bouncer/{archive,tor,decks,inpurs,raw_reports,etc,var/log/ooni}
docker run -d --name="ooni-canonical-bouncer" \
	-v /data/bouncer/var/log/ooni:/var/log/ooni \
	-v /data/bouncer/:/usr/share/ooni/backend/ \
	-v /data/bouncer/inputs/:/usr/share/ooni/backend/inputs \
	-v /data/bouncer/decks:/usr/share/ooni/backend/decks ooni/bouncer
