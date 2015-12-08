These scripts install and configure oonibackend on a Centos 7 system.

In an attempt to illustrate the ordering of things, the scripts (and templates)
you shouldn't need to configure or run are prepended with an underscore.

All configurable locations, users, files, etc. should be set from
`install-ooni-backend.sh`.

## install-ooni-backend.sh
This is the top-level script you want to run. It contains all the configurable
variables the other scripts expect.

## _install-packages.sh
This is the `yum`- and `pip`-related stuff.

## _oonibackend.conf.sh
Configuration template for oonibackend.

## _oonibackend.service.sh
Systemd service file to start and monitor oonibackend.

## _tor.repo
Yum repository config file to pull tor from Tor Project's site.

## _torproject-rpm-key.asc
PGP public key so RPM can validate the tor package.
