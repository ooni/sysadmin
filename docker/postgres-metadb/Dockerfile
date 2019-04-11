# Build: run ooni-sysadmin.git/scripts/docker-build from this directory

FROM postgres:9.6.12

RUN set -ex \
    && apt-get update \
    && apt-get install -y curl awscli \
    && rm -rf /var/lib/apt/lists/* \
    && :

COPY metadb_s3_archive \
    /usr/local/bin/
