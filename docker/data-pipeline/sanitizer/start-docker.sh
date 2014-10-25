#!/bin/dash

mkdir -p /data/raw
#docker run -d --name="sanitizer" -v /data/raw/:/data/raw -v /data/sanitized:/data/sanitized -v /data/public-archive:/data/public-archive -e bridge_maping=/data/raw/path_to_ip_port_based_mapping.json ooni/sanitizer
docker run -d --name="sanitizer" -v /data/raw:/data/raw -v /data/sanitized:/data/sanitized -v /data/public-archive:/data/sanitized-archive ooni/sanitizer

