# python 3 headers, required if submitting to Ansible
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import json
from ansible.errors import AnsibleError, AnsibleParserError
from ansible.plugins.lookup import LookupBase
from ansible.utils.display import Display

display = Display()
class LookupModule(LookupBase):

    def run(self, terms, variables=None, **kwargs):
        ips = []
        assert len(terms) == 1
        gh_droplets = terms[0]
        with open(gh_droplets) as in_file:
            j = json.load(in_file)
        for droplet in filter(lambda d: d['status'] == 'running', j['droplets']):
            for v4 in droplet['networks']['v4']:
                ips.append(v4['ip_address'])
        return [ips]
