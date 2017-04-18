FROM puckel/docker-airflow:1.8.0

USER root

RUN set -ex \
    && curl --location -o /tmp/dumb-init_1.2.0_amd64.deb https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb \
    && echo '9af7440986893c904f24c086c50846ddc5a0f24864f5566b747b8f1a17f7fd52  /tmp/dumb-init_1.2.0_amd64.deb' >/tmp/SHA256SUM \
    && sha256sum --strict --check /tmp/SHA256SUM \
    && dpkg -i /tmp/dumb-init_1.2.0_amd64.deb \
    && rm -f /tmp/dumb-init_1.2.0_amd64.deb \
    && : \
    && apt-get --purge -y autoremove \
    && rm -rf /root/.cache \
    && find / -xdev -perm /u+s,g+s -type f -exec chmod u-s,g-s '{}' + \
    && :

COPY entrypoint.sh /entrypoint.sh

USER airflow

# One can't enforce ulimit or get OOM on PID=1
ENTRYPOINT ["/usr/bin/dumb-init", "-v", "/entrypoint.sh"]
