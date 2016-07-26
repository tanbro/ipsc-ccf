# -*- encoding: utf-8 -*-

from __future__ import with_statement

import os.path

from fabric.api import *
from fabric.contrib.project import rsync_project
from fabvenv import virtualenv


SPHINX_PROJECT_ROOT_DIR = '/home/bind/yunhuni-peer-comm-cti-flow'
PYTHON_VENV_DIR = '/home/bind/yunhuni-peer-comm-cti-flow/env'


@roles('docs')
@task
def upload():
    run('mkdir -p %s/docs' % SPHINX_PROJECT_ROOT_DIR)
    filepairs = []
    for root, dirs, files in os.walk('../docs'):
        if '_build' in dirs:
            dirs.remove('_build')
        for filename in files:
            src_file = '%s/%s' % (root, filename)
            dst_file = os.path.join(SPHINX_PROJECT_ROOT_DIR, src_file.lstrip('./\\')).replace('\\', '/')
            run('mkdir -p %s' % os.path.dirname(dst_file))
            put(src_file, dst_file)


@roles('docs')
@task
def build(clean=False, target='html'):
    with virtualenv(PYTHON_VENV_DIR):
        with cd('%s/docs' % SPHINX_PROJECT_ROOT_DIR):
            if clean:
                run("make clean")
            run("make %s" % target)
            run("/bin/cp -arf _build/html/* /www/docs_yunhuni_com/cti-api")


@roles('docs')
@task
def rebuild(target='html'):
    execute(build, clean=True, target=target)


@roles('docs')
@task
def deploy():
    execute(upload)
    execute(rebuild)
