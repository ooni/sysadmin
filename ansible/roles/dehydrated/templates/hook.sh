#!/usr/bin/env bash

# Deployed by ansible
# see ansible/roles/dehydrated/templates/hook.sh
#
deploy_cert() {
  local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"
  # This hook is called once for each certificate that has been produced.
  # Parameters:
  # - DOMAIN The primary domain name, i.e. the certificate common name (CN).
  # - KEYFILE The path of the file containing the private key.
  # - CERTFILE The path of the file containing the signed certificate.
  # - FULLCHAINFILE The path of the file containing the full certificate chain.
  # - CHAINFILE The path of the file containing the intermediate certificate(s).
  # - TIMESTAMP Timestamp when the specified certificate was created.

  logger "Deploying SSL certificate $DOMAIN $KEYFILE $CERTFILE $FULLCHAINFILE $CHAINFILE $TIMESTAMP"
  # cp ...
  #systemctl reload nginx
}
