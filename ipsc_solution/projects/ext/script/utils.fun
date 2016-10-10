#!/usr/bin/env python
# -*- coding: utf-8 -*-


def make_res_id(chan=None):
    return '{0[0]}.{0[1]}.{0[2]}-{1}.{2}-{3}'.format(GetIpscID().split('.'), GetProjectID(), GetFlowID(), GetProcessID(chan))


def parse_sip_uri(sip_uri):
    uri_parts = sip_uri.split(':', 2)
    destuserhost = ''
    destuser = ''
    destip = ''
    destport = 5060
    if len(uri_parts) == 1:
        destuserhost = uri_parts[0]
    elif len(uri_parts) == 2:
        if uri_parts[0] == 'sip':
            destuserhost = uri_parts[1]
        else:
            destuserhost = uri_parts[0]
            destport = int(uri_parts[1])
    else:
        destuserhost = uri_parts[1]
        destport = int(uri_parts[2])
    if not destuserhost:
        raise IvrError(0, '不支持的 SIP URI 表达式: %s' % sip_uri)
    userhost_parts = destuserhost.split('@', 1)
    if len(userhost_parts) == 1:
        destip = userhost_parts[0]
    else:
        destuser = userhost_parts[0]
        destip = userhost_parts[1]
    # if len(destuser) > 13:
    #     raise RuntimeError('Invalid number: %s. Too long.' % sip_uri)
    # if  len(destuser) < 7:
    #     raise RuntimeError('Invalid number: %s. Too short.' % sip_uri)
    # if destuser.startswith('00'):
    #     raise RuntimeError('Invalid number: %s. Starts with "00".' % sip_uri)
    # if not destuser.isdigit():
    #     raise RuntimeError('Invalid number: %s. Not digits.' % sip_uri)
    return destuser, destip, destport
