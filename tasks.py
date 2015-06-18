from __future__ import absolute_import, print_function, unicode_literals

import logging
import logging.config
import json
import time
import traceback
import sys
import os

from invoke.config import Config
from invoke import Collection, ctask as task

config = Config(runtime_path="invoke.yaml")

os.environ["PYTHONPATH"] = os.environ.get("PYTHONPATH") if os.environ.get("PYTHONPATH") else ""
os.environ["PYTHONPATH"] = ":".join(os.environ["PYTHONPATH"].split(":") + [config.core.ooni_sysadmin_path])

class Timer(object):
    def __init__(self):
        self.start_time = None
        self.end_time = None

    @property
    def runtime(self):
        if self.start_time is None:
            raise RuntimeError("Did not call start")
        if self.end_time:
            return self.end_time - self.start_time
        return time.time() - self.start_time

    def start(self):
        self.start_time = time.time()

    def stop(self):
        self.end_time = time.time()
        return self.runtime


def _create_cfg_files():
    with open("logging.cfg", "w") as fw:
        fw.write("""[loggers]
keys=root,ooni-sysadmin

[handlers]
keys=stream_handler,file_handler

[formatters]
keys=formatter

[logger_root]
level={loglevel}
handlers=

[logger_ooni-sysadmin]
level={loglevel}
handlers=stream_handler,file_handler
qualname=ooni-sysadmin

[handler_stream_handler]
class=StreamHandler
level={loglevel}
formatter=formatter
args=(sys.stdout,)

[handler_file_handler]
class=FileHandler
level={loglevel}
formatter=formatter
args=('{logfile}',)

[formatter_formatter]
""".format(loglevel=config.logging.level, logfile=config.logging.filename))
        fw.write("format=%(asctime)s - %(name)s - %(levelname)s - %(message)s")
        fw.write("\n")
    logging.config.fileConfig("logging.cfg", disable_existing_loggers=True)
    return logging.getLogger('ooni-sysadmin')

logger = _create_cfg_files()

@task
def setup_remote_syslog(ctx):
    if not os.path.exists("/usr/local/bin/remote_syslog"):
        if sys.platform.startswith("darwin"):
            filename = "remote_syslog_darwin_amd64.tar.gz"
        elif sys.platform.startswith("linux"):
            filename = "remote_syslog_linux_amd64.tar.gz"
        else:
            logger.error("This platform does not support remote_syslog")
            return
        ctx.run("cd /tmp/")
        ctx.run("wget -O /tmp/{filename}"
                " https://github.com/papertrail/remote_syslog2/releases/download/v0.13/{filename}".format(
            filename=filename))
        ctx.run("tar xvzf /tmp/{filename} -C /tmp/".format(filename=filename))
        ctx.run("cp /tmp/remote_syslog/remote_syslog /usr/local/bin/remote_syslog")
    pid_file = "remote_syslog.pid"
    try:
        with open(pid_file) as f:
            pid = f.read().strip()
        pid = int(pid)
        os.kill(pid, 0)
    except (OSError, IOError):
        command = ("/usr/local/bin/remote_syslog"
                   " -d {papertrail_hostname}"
                   " -p {papertrail_port}"
                   " --pid-file={pid_file}"
                   " ooni-sysadmin.log".format(
                       papertrail_hostname=config.papertrail.hostname,
                       papertrail_port=config.papertrail.port,
                       pid_file=pid_file
                   ))
        logger.info("Running %s" % command)
        ctx.run(command, pty=True)


@task(setup_remote_syslog)
def start_probe(ctx, private_key="private/ooni-pipeline.pem",
                instance_type="m3.medium",
                playbook="trackmap",
                region="us-east-1"):
    timer = Timer()
    timer.start()
    logger.info("Starting a %s AWS instance"
                " and running on it %s" % (instance_type, playbook))

    os.environ["ANSIBLE_HOST_KEY_CHECKING"] = "false"
    os.environ["AWS_ACCESS_KEY_ID"] = config.aws.access_key_id
    os.environ["AWS_SECRET_ACCESS_KEY"] = config.aws.secret_access_key
    try:
        command = ("ansible-playbook --private-key {private_key}"
                   " -i inventory playbook.yaml"
                   " --extra-vars=".format(private_key=private_key))
        command += "'%s'" % json.dumps({
            "instance_type": instance_type,
            "playbook": playbook,
            "region": region
        })
        result = ctx.run(command, pty=True)
        logger.info(str(result))
    except Exception:
        logger.error("Failed to run ansible playbook")
        logger.error(traceback.format_exc())
    logger.info("start_computer runtime: %s" % timer.stop())

ns = Collection(start_probe)
