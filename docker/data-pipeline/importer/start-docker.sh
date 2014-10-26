#!/bin/dash

docker run -d --name="importer" -v /data/sanitized:/data/sanitized -v /data/public:/data/public
