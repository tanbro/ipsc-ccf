# -*- encoding: utf-8 -*-

from __future__ import with_statement
from fabric.api import *

env.roledefs = {
    'dev': ['root@192.168.2.100'],
    'test': ['root@192.168.22.10'],
    'docs': ['bind@101.200.220.202:21210'],
}
env.password = "zBl8*NTGS9KC!BtL"


import ipsc
import docs


@task
def deploy():
    execute(ipsc.deploy)
    execute(docs.deploy)