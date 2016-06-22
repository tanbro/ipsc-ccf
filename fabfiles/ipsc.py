# -*- encoding: utf-8 -*-

from __future__ import with_statement
from fabric.api import *

IPSC_DIR = '/home/hesong/ipsc'
IPSC_SOL_DIR = '/home/hesong/service_logic'


@roles('ipsc')
@task
def start():
    with cd(IPSC_DIR):
        run('./fight -s')


@roles('ipsc')
@task
def stop():
    with cd(IPSC_DIR):
        run('./fight -q')


@roles('ipsc')
@task
def reload():
    with cd(IPSC_DIR):
        run('./reload')


@roles('ipsc')
@task
def restart():
    with cd(IPSC_DIR):
        execute(stop)
        execute(start)


@roles('ipsc')
@task
def upload():
    put('../ipsc_solution', IPSC_SOL_DIR)


@roles('ipsc')
@task
def deploy():
    execute(upload)
    execute(reload)
