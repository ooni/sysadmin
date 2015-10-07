#!/bin/sh
openssl req -x509 -newkey rsa:2048 \
    -keyout private/ssl-key-nginx.pem -out private/ssl-cert-nginx.pem \
    -days 400 -nodes -subj '/CN=selfie'
