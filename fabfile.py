# -*- encoding: utf-8 -*-

from __future__ import with_statement
from fabric.api import *

env.roledefs = {
    'dev': ['root@192.168.2.100'],
}
env.password = "hesong"

IPSC_DIR = '/home/hesong/ipsc'
IPSC_SOL_DIR = '/home/hesong/service_logic'


@task
def start():
    with cd(IPSC_DIR):
        run('./fight -s')


@task
def stop():
    with cd(IPSC_DIR):
        run('./fight -q')


@task
def reload():
    with cd(IPSC_DIR):
        run('./reload')


@task
def restart():
    with cd(IPSC_DIR):
        execute(stop)
        execute(start)


@task
def upload(reloading=True):
    put('ipsc_solution', IPSC_SOL_DIR)
    if reloading:
        execute(reload)
