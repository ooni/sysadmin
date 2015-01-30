#!/bin/sh

. ./config.sh
docker run -d --name="web-server" -v \
$OONI_PUBLIC_DIR:/srv/www/ -p 80:80 ooni/web-server
