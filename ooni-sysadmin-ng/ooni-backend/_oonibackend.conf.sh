#!/bin/sh

# this script expects to be run by install-ooni-backend.sh which creates
# users, directories, sets owners, keeps things in once place, etc.
# exit on unset variable or non-0 return code.
set -eu

cat > oonibackend.conf <<EOF
helpers:
  daphn3:
    address: null
    pcap_file: null
    port: $daphn3_port
    yaml_file: null
  dns:
    address: null
    resolver_address: $dns_resolver_address
    tcp_port: $dns_port_tcp
    udp_port: $dns_port_udp
  dns_discovery:
    address: null
    resolver_address: null
    tcp_port: $dns_discover_port_tcp
    udp_port: $dns_discover_port_udp
  http-return-json-headers:
    address: null
    port: $http_return_json_headers_port
    server_version: Apache
  ssl:
    address: null
    certificate: $ssl_cert
    private_key: $ssl_key
    port: $ssl_port
  tcp-echo:
    address: null
    port: $tcp_echo_port
main:
  archive_dir: $archive_dir
  bouncer_file: $bouncer_file
  chroot: null
  database_uri: sqlite://oonib_test_db.db
  db_threadpool_size: 10
  debug: false
  deck_dir: $deck_dir
  euid: null
  gid: null
  input_dir: $input_dir
  logfile: $log_dir/oonibackend.log
  no_save: true
  nodaemon: true
  originalname: null
  pidfile: null
  policy_file: $policy_file
  profile: null
  report_dir: $report_dir
  rundir: .
  socks_port: 9055
  stale_time: 3600
  tor2webmode: false
  tor_binary: null
  tor_datadir: $tor_datadir
  tor_hidden_service: true
  uid: null
  umask: null
  uuid: null
EOF
