#!/bin/sh

# exit on unset variable or non-0 return code.
set -eu

cat > ooniprobe.conf <<EOF
# This is the configuration file for OONIProbe
# This file follows the YAML markup format: http://yaml.org/spec/1.2/spec.html
# Keep in mind that indentation matters.

basic:
    # Where OONIProbe should be writing it's log file
    logfile: $ooniprobe_logfile
privacy:
    # Should we include the IP address of the probe in the report?
    includeip: true
    # Should we include the ASN of the probe in the report?
    includeasn: true
    # Should we include the country as reported by GeoIP in the report?
    includecountry: true
    # Should we include the city as reported by GeoIP in the report?
    includecity: true
    # Should we collect a full packet capture on the client?
    includepcap: false
reports:
    # Should we place a unique ID inside of every report
    unique_id: true
    # This is a prefix for each packet capture file (.pcap) per test:
    pcap: null
    collector: null
advanced:
    geoip_data_dir: /usr/share/GeoIP
    debug: false
    # enable if auto detection fails
    #tor_binary: /usr/sbin/tor
    #obfsproxy_binary: /usr/bin/obfsproxy 
    # For auto detection
    interface: auto
    # Of specify a specific interface
    #interface: wlan0
    # If you do not specify start_tor, you will have to have Tor running and
    # explicitly set the control port and SOCKS port
    start_tor: true
    # After how many seconds we should give up on a particular measurement
    measurement_timeout: 60
    # After how many retries we should give up on a measurement
    measurement_retries: 2
    # How many measurements to perform concurrently
    measurement_concurrency: 10
    # After how may seconds we should give up reporting
    reporting_timeout: 80
    # After how many retries to give up on reporting
    reporting_retries: 3
    # How many reports to perform concurrently
    reporting_concurrency: 15
    oonid_api_port: 8042
    report_log_file: null
    inputs_dir: null
    decks_dir: null
tor:
    #socks_port: 8801
    #control_port: 8802
    # Specify the absolute path to the Tor bridges to use for testing
    #bridges: bridges.list
    # Specify path of the tor datadirectory.
    # This should be set to something to avoid having Tor download each time
    # the descriptors and consensus data.
    #data_dir: ~/.tor/
    torrc:
        #HTTPProxy: host:port
        #HTTPProxyAuthenticator: user:password
        #HTTPSProxy: host:port
        #HTTPSProxyAuthenticator: user:password
EOF
