#!/bin/sh
mkdir -p /data/collector
docker run -d --name="bridge-reachability-collector" -v /data/collector/:/data/ ooni/collector
