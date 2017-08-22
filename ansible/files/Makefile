.PHONY: all
all: exporter_ca.key.vault exporter_ca.cert scraper_ca.key.vault scraper_ca.cert

# certificate to sign keys for exporters on the hosts
exporter_ca.cert: exporter_ca.key.vault
	../vault view $^ | openssl req -x509 -new -key /dev/stdin -sha256 -days 3650 -subj '/O=OONI/OU=CA/CN=Prometheus Exporter CA' -out $@

# certificate to sign keys for scrapers on monitoring servers so hosts can authenticate them
scraper_ca.cert: scraper_ca.key.vault
	../vault view $^ | openssl req -x509 -new -key /dev/stdin -sha256 -days 3650 -subj '/O=OONI/OU=CA/CN=Prometheus Scraper CA' -out $@

%_ca.key.vault:
	openssl genrsa 2048 | ../vault encrypt --output $@
