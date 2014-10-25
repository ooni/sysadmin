#!/bin/dash

mkdir -p /data/raw
docker run -d --name="rsync-collector-raw" -v /data/raw/:/data/raw -v /data/collector-raw-data:/data/collector-raw-data ooni/rsync-collector-raw

