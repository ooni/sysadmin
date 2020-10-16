#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Monitor certbot certificates
"""

# Compatible with Python3.7 - linted with Black

import subprocess
from datetime import datetime, timezone

import statsd  # debdeps: python3-statsd

metrics = statsd.StatsClient("localhost", 8125, prefix="certificates")


def main():
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
            s = delta.total_seconds()
            metrics.gauge(f"certificate_age.{domain_name}", s)


if __name__ == "__main__":
    main()
