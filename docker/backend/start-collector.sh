#!/bin/bash
mkdir -pv /data/collector/{archive,tor,decks,inputs,raw_reports,etc,var/log/ooni}
docker run -d --name="bridge-reachability-collector" -v /data/collector/:/data/ ooni/collector
