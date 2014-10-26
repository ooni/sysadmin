#!/bin/bash

. ./config.sh

mkdir -p /data/raw
docker run -d --name="sanitizer" -v $OONI_RAW_DIR:$OONI_RAW_DIR -v $OONI_SANITISED_DIR:$OONI_SANITISED_DIR -v $OONI_ARCHIVE_DIR:$OONI_ARCHIVE_DIR ooni/sanitizer
