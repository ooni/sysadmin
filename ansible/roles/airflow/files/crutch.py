#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

import argparse
import os
import json

#from oonipl.cli import dirname
def dirname(s):
    if not os.path.isdir(s):
        raise ValueError('Not a directory', s)
    if s[-1] == '/':
        raise ValueError('Bogus trailing slash', s)
    return s

def is_bad(fpath):
    with open(fpath) as fd:
        row = fd.readline()
    try:
        j = json.loads(row)
    except Exception as exc:
        print 'non-json:', fpath, str(exc)
        return False
    sw = j.get('software_name')
    ver = str(j.get('software_version'))
    return sw == 'ooniprobe-android' and (ver == '2.0.0' or ver.startswith('2.0.0-'))

def parse_args():
    p = argparse.ArgumentParser(description='ooni-pipeline: drop bad data from private/reports-raw')
    p.add_argument('--bucket', metavar='DIR', type=dirname, help='Path to .../reports-raw/YYYY-MM-DD', required=True)
    p.add_argument('--stash', metavar='DIR', type=dirname, help='Path to .../private/canned', required=True)
    opt = p.parse_args()
    return opt

def main():
    opt = parse_args()
    for fname in os.listdir(opt.bucket):
        fpath = os.path.join(opt.bucket, fname)
        if os.path.isfile(fpath) and is_bad(fpath):
            print 'Bad:', fpath
            dest = os.path.join(opt.stash, fname)
            os.rename(fpath, dest)
        else:
            print 'Skip:', fpath

if __name__ == '__main__':
    main()
