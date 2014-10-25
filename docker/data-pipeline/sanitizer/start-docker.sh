#!/bin/dash

mkdir -p /data/raw
docker run -d --name="sanitizer" -v /data/raw:/data/raw -v /data/sanitized:/data/sanitized -v /data/sanitized-archive:/data/sanitized-archive ooni/sanitizer
