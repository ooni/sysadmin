#!/bin/sh
mkdir -p /data/collector/archive
mkdir -p /data/collector/tor
docker run -d --name="bridge-reachability-collector" -v /data/collector/:/data/ ooni/collector
