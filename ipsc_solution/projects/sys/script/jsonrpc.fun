#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# @brief      随机获取一个可用的 smartbus 客户端（非IPSC） #
#
# @param      local_only      只用本地客户端？ #
# @param      raise_if_empty  找不到客户端就抛出 IndexError 异常？
#
# @return     客户端的 unit,id,type三段地址。没有可用返回 None
#


def get_client(local_only=False, raise_if_empty=True):
    local_unit_id = GetServerNodeID()
    local_candidates = []
    remote_candidates = []
    for unit_id, client_id, client_type, add_info in SmartbusGetNodeInfo(10):
        if unit_id == local_unit_id:
            local_candidates.append((unit_id, client_id, client_type))
        elif not local_only:
            remote_candidates.append((unit_id, client_id, client_type))
    if local_candidates:
        return randchoice(local_candidates)
    elif (not local_only) and remote_candidates:
        return randchoice(remote_candidates)
    elif raise_if_empty:
        raise IvrError(0, '找不到可用的bus客户端')
    else:
        return None


# 事件通知
def send_event(method, params=None):
    if not method.startswith('sys.'):
        method = 'sys.' + method
    data = dict(method=method, params=params or {})
    unit_id, client_id, _ = jsonrpc.get_client()
    SmartbusSendData(unit_id, client_id, 0xff, 0, 3,
                     json.dumps(data, ensure_ascii=False))


# 正常结果回复
def send_result(to, id_, result=None):
    data = dict(id=id_, result=result)
    SmartbusSendData(to[0], to[1], 0xff, 0, 3,
                     json.dumps(data, ensure_ascii=False))


# Error 回复
def send_error(to, id_, code=0, message='', data=None):
    error = dict(code=code, message=message, data=data)
    data = dict(id=id_, error=error)
    SmartbusSendData(to[0], to[1], 0xff, 0, 3,
                     json.dumps(data, ensure_ascii=False))
