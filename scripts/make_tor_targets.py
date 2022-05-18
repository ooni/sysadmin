import json
import hashlib

from urllib.request import urlopen

DIRAUTH_URL = "https://gitweb.torproject.org/tor.git/plain/src/app/config/auth_dirs.inc"
BRIDGES_URL = "https://bridges.torproject.org/moat/circumvention/builtin"

def parse_params(parts: list[str]) -> dict[str, list[str]]:
    params = {}
    for p in parts:
        k, v = p.split("=")
        params[k] = [v]
    return params

def parse_bridge_line(line : str) -> tuple[str, dict]:
    bridge = {}
    parts = line.split(" ")
    bridge["protocol"] = parts[0]
    bridge["address"] = parts[1]
    bridge["fingerprint"] = parts[2]
    bridge["params"] = parse_params(parts[3:])

    bridge_id = hashlib.sha256(
            bridge["address"].encode("ascii") + bridge["fingerprint"].encode("utf-8")
    ).hexdigest()

    return bridge_id, bridge

def get_bridges():
    with urlopen(BRIDGES_URL) as resp:
        j = json.loads(resp.read())

    bridges = {}
    for b in j["obfs4"]:
        bridge_id, bd = parse_bridge_line(b)
        assert bridge_id not in bridges
        bridges[bridge_id] = bd
    return bridges

def parse_dirauth(line : str) -> dict:
    # Example: tor26 orport=443 v3ident=14C131DFC5C6F93646BE72FA1401C02A8DF2E8B4 ipv6=[2001:858:2:2:aabb:0:563b:1526]:443 86.59.21.38:80 847B 1F85 0344 D787 6491 A548 92F9 0493 4E4E B85D
    da = {}
    parts = line.split(" ")
    da["name"] = parts[0]
    assert parts[1].startswith("orport=")
    da["or_port"] = parts[1].lstrip("orport=")
    da["dir_address"] = parts[-11]
    da["fingerprint"] = "".join(parts[-10:])
    return da

def get_dirauths():
    with urlopen(DIRAUTH_URL) as resp:
        config = resp.read().decode("utf-8")

    dir_auths = {}

    da_lines = []
    current_line = ""
    is_done = False
    for line in config.split("\n"):
        if is_done is True:
            current_line = ""
            is_done = False

        if line.endswith(","):
            is_done = True
            line = line.rstrip(",")

        line = line.strip().lstrip('"').rstrip('"')
        current_line += line
        if is_done:
            da_lines.append(current_line)

    for line in da_lines:
        da = parse_dirauth(line)

        or_address = da["dir_address"].split(":")[0] + ":" + da["or_port"]
        assert or_address not in dir_auths
        dir_auths[or_address] = {
            "address": or_address,
            "name": da["name"],
            "fingerprint": da["fingerprint"],
            "protocol": "or_port_dirauth"
        }

        assert da["dir_address"] not in dir_auths
        dir_auths[da["dir_address"]] = {
            "address": da["dir_address"],
            "name": da["name"],
            "fingerprint": da["fingerprint"],
            "protocol": "dir_port"
        }

    return dir_auths

def write_json(path : str, obj : dict):
    with open(path, "w") as out_file:
        json.dump(obj, out_file, indent=2, sort_keys=True)

    print(f"written {path} file")

def main():
    bridges = get_bridges()
    dir_auths = get_dirauths()

    res = {}
    res.update(dir_auths)
    res.update(bridges)

    write_json("ansible/roles/probe-services/templates/tor_targets.json", res)
    write_json("ansible/roles/ooni-backend/templates/tor_targets.json", res)

if __name__ == "__main__":
    main()
