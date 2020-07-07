#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Monitor certbot certificates
"""

# Compatible with Python3.7 - linted with Black

import subprocess
from datetime import datetime, timezone

import prometheus_client as prom

NODEEXP_FN = "/run/nodeexp/monitor_certs.prom"


def main():
    prom_reg = prom.CollectorRegistry()
    gauge = prom.Gauge("certificate_age", "", ["domain"], registry=prom_reg)
    out = subprocess.check_output(["certbot", "certificates"])
    out = out.decode("utf-8")
    for line in out.splitlines():
        if line.startswith("  Certificate Name: "):
            domain_name = line.split()[-1]

        elif line.startswith("    Expiry Date: "):
            #    Expiry Date: 2020-09-12 08:16:47+00:00 (VALID: 79 days)
            exp = line[17:42]
            exp = datetime.strptime(exp, "%Y-%m-%d %H:%M:%S%z")
            delta = exp - datetime.now(timezone.utc)
            s = int(delta.total_seconds())
            gauge.labels(domain_name).set(s)

    prom.write_to_textfile(NODEEXP_FN, prom_reg)


if __name__ == "__main__":
    main()
