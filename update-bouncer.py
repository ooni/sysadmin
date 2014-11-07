#!/usr/bin/env python

import yaml
import json
import urllib

MLAB_NS_QUERY_URL = "http://mlab-nstesting.appspot.com/ooni?policy=all"


def read_parts_from_mlabns():
    # Download the JSON list of slivers.
    response = urllib.urlopen(MLAB_NS_QUERY_URL)

    # mlab-ns's semantics are that a 404 means there are no slices online.
    if response.code == 8:
        return []

    json_list = response.read()
    # Parse the JSON response.
    sliver_list = json.loads(json_list)

    # Special case: If there's only one, it's not inside of an array.
    if not isinstance(sliver_list, list):
        sliver_list = [sliver_list]

    # Map each sliver into its part of the config file (in tool_extra).
    part_list = []
    for sliver in sliver_list:
        tool_extra_obj = json.loads(sliver['tool_extra'])
        for hs, value in tool_extra_obj.items():
          if 'policy' in value and 'input' not in value['policy']:
              value['policy']['input'] = []
        part_list.append(tool_extra_obj)

    return part_list


def assemble_bouncer_config(base_bouncer, parts):
    merged_parts = {}
    for part in parts:
        merged_parts.update(part)
    bouncer_config = base_bouncer
    bouncer_config['collector'].update(merged_parts)
    return yaml.safe_dump(bouncer_config)


def write_bouncer_config(path, bouncer_config_contents):
    try:
        f = open(path, 'w')
        f.write(bouncer_config_contents)
        f.close()
    except IOError:
        print "Couldn't write to bouncer config file."
        exit(1)


dst_bouncer_path = '/data/bouncer-nkvphnp3p6agi5qq/bouncer.yaml'
base_bouncer_path = '/data/bouncer-nkvphnp3p6agi5qq/bouncer-base.yaml'
base_bouncer = yaml.safe_load(open(base_bouncer_path))
parts = read_parts_from_mlabns()
bouncer_config = assemble_bouncer_config(base_bouncer, parts)
write_bouncer_config(dst_bouncer_path, bouncer_config)
