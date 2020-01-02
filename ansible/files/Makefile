.PHONY: all
all: exporter_ca.cert scraper_ca.cert pusher_ca.cert

SHELL = /bin/bash

# There are no CRLs, so in case of any client's key comprometation it may be required to re-generate whole CA...

# certificate to sign keys for exporters on the hosts
exporter_ca.cert: exporter_ca.key.vault
	../vault view $^ | openssl req -x509 -new -key /dev/stdin -sha256 -days 3650 -subj '/O=OONI/OU=CA/CN=Prometheus Exporter CA' -out $@

# certificate to sign keys for scrapers on monitoring servers so hosts can authenticate them
scraper_ca.cert: scraper_ca.key.vault
	../vault view $^ | openssl req -x509 -new -key /dev/stdin -sha256 -days 3650 -subj '/O=OONI/OU=CA/CN=Prometheus Scraper CA' -out $@

# certificate to sign keys for various processes uploading data to Prometheus Pushgateway
# uploading to Pushgateway is done with `curl`, Pushgateway server certificate is issued by `Let's encrypt`
pusher_ca.cert: pusher_ca.key.vault
	../vault view $^ | openssl req -x509 -new -key /dev/stdin -sha256 -days 3650 -subj '/O=OONI/OU=CA/CN=Prometheus Pusher CA' -out $@

# certificate to sign keys for PostgreSQL servers for `sslmode=verify-full`
postgres_ca.cert: postgres_ca.key.vault
	../vault view $^ | openssl req -x509 -new -key /dev/stdin -sha256 -days 3650 -subj '/O=OONI/OU=CA/CN=PostgreSQL Server CA' -out $@

# This rule is here to record CN for the certificate.
hellais_nas.cert: hellais_nas.key pusher_ca.cert pusher_ca.key.vault
	openssl req -new -key hellais_nas.key -sha256 -days 3650 -subj '/O=OONI/OU=Prometheus Pusher/CN=hellais NAS' | \
	openssl x509 -req -sha256 -days 3650 -CA pusher_ca.cert -CAkey <(../vault view pusher_ca.key.vault) -set_serial 0x`head -c 16 /dev/urandom | xxd -plain` -out $@

%_ca.key.vault:
	openssl genrsa 2048 | ../vault encrypt --output $@

%.key:
	touch $@ && chmod 600 $@ && openssl genrsa 2048 >$@
