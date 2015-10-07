#!/bin/sh
openssl req -x509 -newkey rsa:2048 \
    -keyout private/ssl-key-munin.pem -out private/ssl-cert-munin.pem \
    -days 400 -nodes -subj '/CN=selfie'
