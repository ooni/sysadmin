FROM openobservatory/airflow:1.8.0-oo1

# docker_apt_ver should match {{ docker_apt_ver }} for dom0
ARG docker_apt_ver=1.12.6-0~debian-jessie

USER root

ADD docker-trampoline /usr/local/bin/

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends sudo apt-transport-https ca-certificates \
    && : \
    && curl -sSL -o /tmp/dockerproject.gpg https://apt.dockerproject.org/gpg \
    && echo 'c836dc13577c6f7c133ad1db1a2ee5f41ad742d11e4ac860d8e658b2b39e6ac1  /tmp/dockerproject.gpg' >/tmp/SHA256SUM \
    && sha256sum --strict --check /tmp/SHA256SUM \
    && apt-key add /tmp/dockerproject.gpg \
    && apt-key adv --fingerprint 58118E89F3A912897C070ADBF76221572C52609D \
    && echo 'deb https://apt.dockerproject.org/repo debian-jessie main' >/etc/apt/sources.list.d/dockerproject.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-engine=${docker_apt_ver} \
    && : \
    && echo 'ALL ALL = (ALL:ALL) NOPASSWD: /usr/local/bin/docker-trampoline' >/etc/sudoers.d/af-docker \
    && chmod 440 /etc/sudoers.d/af-docker \
    && chmod 755 /usr/local/bin/docker-trampoline \
    && : \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

# switch it back
USER airflow
