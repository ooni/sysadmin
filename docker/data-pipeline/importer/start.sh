#!/bin/dash
. ./config.sh

docker run -d --name="importer" -v $OONI_SANITISED_DIR:$OONI_SANITISED_DIR -v $OONI_PUBLIC_DIR:$OONI_PUBLIC_DIR --env-file=./config.sh ooni/import
