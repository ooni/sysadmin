#!/usr/bin/env python
from __future__ import print_function

import re
import os
import sys
import yaml
import json

if len(sys.argv) != 4:
    print("Usage: %s <reports_directory> <output yaml report list> "
          "<output json report list>" % sys.argv[0])
    sys.exit(1)

reports_directory = sys.argv[1]
reports_list_output_yaml = sys.argv[2]
reports_list_output_json = sys.argv[3]


def get_header(report_file):
    with open(report_file) as f:
        header = yaml.safe_load_all(f).next()
    return header


def list_report_files(directory):
    for dirpath, dirname, filenames in os.walk(directory):
        for filename in filenames:
            if filename.endswith(".yamloo"):
                yield os.path.join(dirpath, filename)


def write_yaml(report_list):
    with open(reports_list_output_yaml, 'w+') as f:
        yaml.safe_dump(report_list, f)


def write_json(report_list):
    with open(reports_list_output_json, 'w+') as f:
        json.dump(report_list, f)

report_list = []
for report_file in list_report_files(reports_directory):
    match = re.search("^" + re.escape(reports_directory) + "(.*)",
                      report_file)
    report_entry = get_header(report_file)
    report_entry['report_file'] = match.group(1)
    report_list.append(report_entry)

write_json(report_list)
write_yaml(report_list)
