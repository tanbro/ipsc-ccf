# -*- encoding: utf-8 -*-

from __future__ import with_statement

from io import BytesIO

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


@roles('ipsc')
@task
def pull(branch='master'):
    repo_dir = '/root/yunhuni-peer-comm-cti-flow'

    with cd (repo_dir):
        run('git fetch')
        run('git checkout --force %s' % branch)
        run('git reset --hard origin/%s' % branch)
        #
        commit_hash = run('git log -n 1 --pretty=%h', pty=False).strip()
        commit_tag = run('git tag -l --contains HEAD', pty=False).strip()
        commit_date = run('git log -n 1 --pretty=%ai', pty=False).strip()
        version_file = BytesIO()
        version_file.write('hash=%s\n' % commit_hash)
        version_file.write('date=%s\n' % commit_date)
        version_file.write('tag=%s\n' % commit_tag)
        version_file.write('branch=%s\n' % branch)
        run('/bin/cp -arf ipsc_solution/projects/sys %s/ipsc_solution/projects' % IPSC_SOL_DIR)
        put(version_file, '%s/ipsc_solution/projects/sys/version.txt' % IPSC_SOL_DIR)
