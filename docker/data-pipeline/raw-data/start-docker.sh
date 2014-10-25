#!/bin/dash

mkdir -p /data/raw
docker run -d --name="rsync-collector-raw" -v /data/raw/:/data/raw ooni/rsync-collector-raw

