#!/bin/sh
mkdir -p /data/collector/{archive,tor,decks,inpurs,raw_reports,etc,var/log/ooni}
docker run -d --name="bridge-reachability-collector" -v /data/collector/:/data/ ooni/collector
