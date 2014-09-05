#!/bin/sh
mkdir -p /data/probe/bridge_reachability
docker run -d --name="bridge-reachability-probe" -v /data/probe/bridge_reachability/:/data/bridge_reachability/ ooni/probe-bridge-reachability
