#!/bin/bash

# Deployed by ansible
# See roles/ooni-backend/templates/dehydrated_haproxy_hook.sh
#
# Deploys chained privkey and certificates for haproxy
# Reloads haproxy as needed

deploy_cert() {
  local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"
  # Called once for each certificate
  # /var/lib/dehydrated/certs/backend-hel.ooni.org/privkey.pem /var/lib/dehydrated/certs/backend-hel.ooni.org/cert.pem /var/lib/dehydrated/certs/backend-hel.ooni.org/fullchain.pem > /var/lib/dehydrated/certs/backend-hel.ooni.org/haproxy.pem
  # cp "${KEYFILE}" "${FULLCHAINFILE}" /etc/nginx/ssl/; chown -R nginx: /etc/nginx/ssl
  logger "deploy_cert hook reading ${KEYFILE} ${CERTFILE} ${FULLCHAINFILE}"
  cat "${KEYFILE}" "${CERTFILE}" "${FULLCHAINFILE}" > "${KEYFILE}.haproxy"
  logger "deploy_cert reloading haproxy"
  systemctl reload haproxy.service
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_cert)$ ]]; then
  "$HANDLER" "$@"
fi
