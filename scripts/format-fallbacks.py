import requests
from pprint import pprint
import json

j = {}
r = requests.get("https://raw.githubusercontent.com/torproject/tor/131e2d99a45bd86b8379664cccb59bfc66f80c96/src/app/config/fallback_dirs.inc")
lines = r.text.split("\n")
for idx, line in enumerate(lines):
    if "nickname" in line:
        nickname = line.split(" ")[1]
        nickname = nickname.split("=")[1]

        orline = lines[idx-1]
        if "ipv6" in orline:
            orline = lines[idx-2] + orline
        orline = orline.replace('"', "")

        parts = orline.split(" ")
        ip = parts[0]
        orport = parts[1]
        fingerprint = parts[2]

        orport = orport.split("=")[1]
        fingerprint = fingerprint.split("=")[1]
        address = f"{ip}:{orport}"
        j[address] = {
            "fingerprint": fingerprint,
            "address": address,
            "name": nickname,
            "protocol": "or_port_dirauth"
        }
print(json.dumps(j, indent="  "))
