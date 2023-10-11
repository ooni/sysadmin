#!/bin/bash

# Deployed by ansible
# See roles/ooni-backend/templates/dehydrated_haproxy_hook.sh
#
# Deploys chained privkey and certificates for haproxy
# Reloads haproxy as needed

deploy_challenge() {
  # Create/update a map file to serve the ACME challenge and reload haproxy
  local DOMAIN="${1}" TOKEN="${2}" VALUE="${3}"
  logger "deploy_cert updating map"
  echo "${TOKEN} ${VALUE}" > /var/lib/dehydrated/acme.map
  systemctl reload haproxy.service
}


deploy_cert() {
  # Collate TLS privkey and certs and reload haproxy
  local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"
  # Called once for each certificate
  logger "deploy_cert hook reading ${KEYFILE} ${CERTFILE} ${FULLCHAINFILE}"
  cat "${KEYFILE}" "${CERTFILE}" "${FULLCHAINFILE}" > "${KEYFILE}.haproxy"
  logger "deploy_cert reloading haproxy"
  systemctl reload haproxy.service
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_cert|deploy_challenge)$ ]]; then
  "$HANDLER" "$@"
fi
