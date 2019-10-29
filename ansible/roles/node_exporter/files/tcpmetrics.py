#!/usr/bin/env python3
"""
Extract RTT metrics from /bin/ip tcp_metrics show
Generate percentiles and save them to
/run/nodeexp/tcp_rtt_ms.prom for node exporter / Prometheus
"""

import os, subprocess, time

percentiles = (.5, .8, .9, .95, .99)
outfn = "/run/nodeexp/tcp_rtt_ms.prom"

def main():
    cmd = ["/bin/ip", "tcp_metrics", "show"]
    while True:
        rtt_list = []
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
        for line in p.stdout:
            line = line.rstrip().decode()
            i = line.find(" rtt ")
            if i == -1:
                continue
            rtt = line[i + 5 :].split(None, 1)[0]
            if not rtt.endswith("us"):
                continue
            rtt = int(rtt[:-2]) / 1000
            rtt_list.append(rtt)

        try:
            with open(outfn + ".tmp", "w") as f:
                rtt_list.sort()
                for p in percentiles:
                    v = rtt_list[int(p * len(rtt_list))]
                    p = int(p * 100)
                    print('tcp_rtt_ms_p%d %d' % (p, v), file=f)

                del rtt_list

            os.rename(outfn + ".tmp", outfn)
        except:
            pass

        time.sleep(3600)


if __name__ == "__main__":
    main()
