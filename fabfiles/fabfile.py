# -*- encoding: utf-8 -*-

from __future__ import with_statement
from fabric.api import *

env.roledefs = {
    'ipsc': [
        'root@192.168.22.10',
        'root@192.168.2.100'
    ],
    'docs': ['bind@101.200.220.202:21210'],
}
env.password = "DO7fuhj29ohlshdf"


import ipsc
import docs


@task
def deploy():
    execute(ipsc.deploy)
    execute(docs.deploy)