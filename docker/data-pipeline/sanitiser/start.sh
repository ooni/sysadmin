#!/bin/bash

. ./config.sh

docker run -d --name="sanitiser" -v /data/private:/data/private -v $OONI_RAW_DIR:$OONI_RAW_DIR -v $OONI_SANITISED_DIR:$OONI_SANITISED_DIR -v $OONI_ARCHIVE_DIR:$OONI_ARCHIVE_DIR ooni/sanitiser
