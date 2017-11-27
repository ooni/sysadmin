#!/usr/bin/python
# -*- coding: utf-8 -*-

# Based off of do_droplet from ansible with modifications to work with the
# eclipsis API.
# requires ansible > 2.0.0

import time
import json
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.pycompat24 import get_exception
from ansible.module_utils.urls import fetch_url
from ansible.module_utils.basic import env_fallback

class DropletException(Exception):
    pass

class RestException(Exception):
    pass

class Response(object):

    def __init__(self, resp, info):
        self.body = None
        if resp:
            self.body = resp.read()
        self.info = info

    @property
    def json(self):
        if self.body:
            return json.loads(self.body)
        elif "body" in self.info:
            return json.loads(self.info["body"])
        else:
            return None

    @property
    def status_code(self):
        return self.info["status"]

class Rest(object):

    def __init__(self, module, headers, baseurl):
        self.module = module
        self.headers = headers
        self.baseurl = baseurl

    def _url_builder(self, path):
        if path[0] == '/':
            path = path[1:]
        return '%s/%s' % (self.baseurl, path)

    def send(self, method, path, data=None, headers=None):
        url = self._url_builder(path)
        if data is not None:
            data = self.module.jsonify(data)

        resp, info = fetch_url(self.module, url, data=data, headers=self.headers, method=method)

        response = Response(resp, info)

        if response.status_code >= 500:
            raise RestException('500: Internal server error in '
                                '%s: %s %s %s %s' % (method, url, data, self.headers, response.json))
        else:
            return response

    def get(self, path, data=None, headers=None):
        return self.send('GET', path, data, headers)

    def put(self, path, data=None, headers=None):
        return self.send('PUT', path, data, headers)

    def post(self, path, data=None, headers=None):
        return self.send('POST', path, data, headers)

    def delete(self, path, data=None, headers=None):
        return self.send('DELETE', path, data, headers)

class DODroplet(object):

    def __init__(self, module):
        api_token = module.params['api_token']
        api_baseurl = module.params['api_baseurl']
        self.module = module
        self.rest = Rest(module, {'Authorization': 'Bearer {}'.format(api_token),
                         'Content-type': 'application/json'},
                         api_baseurl)

    def get_key_or_fail(self, k):
        v = self.module.params[k]
        if v is None:
            self.module.fail_json(msg='Unable to load %s' % k)
        return v

    def poll_action_for_complete_status(self, action_id):
        url = 'actions/{}'.format(action_id)
        end_time = time.time() + self.module.params['wait_timeout']
        while time.time() < end_time:
            time.sleep(2)
            response = self.rest.get(url)
            status = response.status_code
            json = response.json
            if status == 200:
                if json['action']['status'].startswith("Instance force stopped."):
                    return True
                if json['action']['status'] == 'completed':
                    return True
                elif json['action']['status'] == 'errored':
                    raise DropletException('Request to api has failed')
            elif status >= 400:
                raise DropletException(json['message'])
        raise DropletException('Unknown error occured %s' % json)

    def power_on_droplet_request(self, droplet_id):
        url = 'droplets/%s/actions' % droplet_id
        data = {'type':'power_on'}
        response = self.rest.post(url, data=data)
        status = response.status_code
        json = response.json
        if status == 201:
            if self.module.params['wait'] == True:
                return self.poll_action_for_complete_status(json['action']['id'])
            else:
                return True
        elif status >= 400:
            raise DropletException(json['error'])
        else:
            raise DropletException('Unknown error occured')

    def power_off_droplet_request(self, droplet_id):
        url = 'droplets/%s/actions' % droplet_id
        data = {'type': 'power_off'}
        response = self.rest.post(url, data=data)
        status = response.status_code
        json = response.json
        if status == 201:
            if self.module.params['wait'] == True:
                return self.poll_action_for_complete_status(json['action']['id'])
            else:
                return True
        elif status >= 400:
            raise DropletException(json['error'])
        else:
            raise DropletException('Unknown error occured')

    def create_droplet_request(self, name, size, image, region, disk,
                               ssh_key_id):
        data = {
            "name": name,
            "size": size,
            "disk": disk,
            "image": image,
            "region": region,
            "ssh_keys": ssh_key_id,
        }
        response = self.rest.post('/droplet', data=data)
        status = response.status_code
        json = response.json
        if status == 202:
            droplet = json['droplet']
            if self.module.params['wait'] == True:
                droplet_status = droplet['status']
                droplet_id = droplet['id']
                while droplet_status != 'running':
                    time.sleep(2)
                    droplet = self.find_droplet_request(id=droplet_id)
                    droplet_status = droplet['status']
            return droplet
        elif status >= 400:
            raise DropletException(json['error'])
        else:
            raise DropletException('Unknown error occured')

    def delete_droplet_request(self, droplet_id):
        url = 'droplets/%s' % droplet_id
        response = self.rest.delete(url)
        status = response.status_code
        json = response.json
        if status == 204:
            return True
        elif status == 404:
            return False
        elif status >=400:
            raise DropletException(json['error'])
        else:
            raise DropletException('Unknown error occured')

    def find_droplet_request(self, id=None, name=None):
        if id is not None:
            url = 'droplets/%s' % id
            response = self.rest.get(url)
            status = response.status_code
            json = response.json
            if status == 200:
                return json['droplet']
            elif status == 404:
                return None
            elif status >= 400:
                raise DropletException(json['error'])
            else:
                raise DropletException('Unknown error occured')
        elif name is not None:
            url = 'droplets';
            response = self.rest.get(url)
            status = response.status_code
            json = response.json
            if status == 200:
                for droplet in json['droplets']:
                    if droplet['name']==name:
                        return droplet
                return None
            elif status >= 400:
                raise DropletException(json['message'])
            else:
                raise DropletException('Unknown error occured')
        else:
            return None

    def create_droplet(self):
        droplet = None
        changed = False
        if self.module.params['unique_name']:
            droplet = self.find_droplet_request(name=self.get_key_or_fail('name'))
        else:
            droplet = self.find_droplet_request(id=self.module.params['id'])
        if droplet is None:
            droplet = self.create_droplet_request(
                name=self.get_key_or_fail('name'),
                region=self.get_key_or_fail('region'),
                size=self.get_key_or_fail('size'),
                disk=self.get_key_or_fail('disk'),
                image=self.get_key_or_fail('image'),
                ssh_key_id=self.module.params['ssh_key_id'],
            )
            changed = True
        else:
            if droplet['status'] == 'off':
                changed = self.power_on_droplet_request(droplet['id'])
                droplet = self.find_droplet_request(id=droplet['id'])
            elif droplet['status'] == 'archive':
                raise DropletException('Droplet is in archive state')
        self.module.exit_json(changed=changed, droplet=droplet)

    def delete_droplet(self):
        droplet_id = None
        changed = False
        if self.module.params['unique_name']:
            droplet = self.find_droplet_request(name=self.get_key_or_fail('name'))
            if droplet is not None:
                droplet_id = droplet['id']
        else:
            droplet_id = self.get_key_or_fail('id')
            droplet = self.find_droplet_request(id=droplet_id)

        if droplet['status'] == 'running':
            self.power_off_droplet_request(droplet_id)

        if droplet_id is not None:
            changed = self.delete_droplet_request(droplet_id)

        self.module.exit_json(changed=changed)

def core(module):
    state = module.params['state']
    droplet = DODroplet(module)
    if state == 'present':
        droplet.create_droplet()
    elif state == 'absent':
        droplet.delete_droplet()

def main():
    module = AnsibleModule(
        argument_spec=dict(
            state=dict(choices=['present', 'absent'], required=True),
            api_token = dict(
                aliases=['API_TOKEN'],
                no_log=True,
                fallback=(env_fallback, ['DO_API_TOKEN', 'DO_API_KEY']),
                required=True
            ),
            api_baseurl=dict(type='str', default="https://portal.eclips.is/portal/api/v2"),
            name=dict(type='str'),
            unique_name=dict(type="bool", default='no'),
            size=dict(aliases=['size_id']),
            disk=dict(aliases=['disk_size']),
            image=dict(type='int', aliases=['image_id']),
            region=dict(aliases=['region_id']),
            wait=dict(type="bool", default=True),
            wait_timeout=dict(type="int", default=60),
            ssh_key_id=dict(type='int')
        ),
        required_together=(
            ['size', 'image', 'region', 'disk'],
        ),
        required_one_of=(
            ['id', 'name'],
        ),
    )

    try:
        core(module)
    except DropletException:
        e = get_exception()
        module.fail_json(msg=e.message)
    except RestException:
        e = get_exception()
        module.fail_json(msg=e.message)
    except KeyError:
        e = get_exception()
        module.fail_json(msg='Unable to load %s' % e.message)
    except Exception:
        e = get_exception()
        module.fail_json(msg=e.message)

if __name__ == '__main__':
    main()
