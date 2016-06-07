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
    for unit_id, client_id, client_type, add_info in SmartbusGetNodeInfo(0):
        if client_id > 5:
            if unit_id == local_unit_id:
                local_candidates.append((unit_id, client_id, client_type))
            elif not local_only:
                remote_candidates.append((unit_id, client_id, client_type))
    if local_candidates:
        return randchoice(local_candidates)
    elif (not local_only) and remote_candidates:
        return randchoice(remote_candidates)
    elif raise_if_empty:
        raise IndexError()
    else:
        return None


def send_method(method, id_=None, params=None):
    unit_id, client_id, client_type = jsonrpc.get_client()
    data = dict(method=method, params=params or [])
    if id_:
        data['id'] = id_
    SmartbusSendData(unit_id, client_id, client_type, 0, 3, json.dumps(data, ensure_ascii=False))


def send_result(id_, result=None):
    unit_id, client_id, client_type = jsonrpc.get_client()
    data = dict(id=id_, result=result)
    SmartbusSendData(unit_id, client_id, client_type, 0, 3, json.dumps(data, ensure_ascii=False))


def send_error(id_, code=0, message='', data=None):
    unit_id, client_id, client_type = jsonrpc.get_client()
    error = dict(code=code, message=message, data=data)
    data = dict(id=id_, error=error)
    SmartbusSendData(unit_id, client_id, client_type, 0, 3, json.dumps(data, ensure_ascii=False))


# def parse(txt):
#     obj = json.loads(txt)
#     if not isinstance(obj, dict):
#         raise ValueError('Sub-flow arguments[1] is not JSON object')
#     protocol_version = obj.get('jsonrpc')
#     is_request = 'method' in obj
#     is_response = 'result' in obj
#     is_error = 'error' in obj
#     if not int(is_request) + int(is_response) + int(is_error) == 1:
#         raise ValueError('Wrong JSON RPC data')
#     if is_request:
#         id_ = obj.get('id')
#         method = obj['method']
#         if not isinstance(method, str):
#             raise ValueError('Wrong "method" attribute')
#         args = []
#         kwargs = {}
#         if 'params' in obj:
#             params = obj['params']
#             if not isinstance(params, dict):
#                 raise ValueError('Wrong "params" attribute')
#             if not all([isinstance(k, str) for k in params]):
#                 raise ValueError('Wrong "params" attribute')
#         return jsonrpc.Request(id_, method, params)
#     elif is_response:
#         id_ = obj['id']
#         result = obj['result']
#         return jsonrpc.Response(id_ result)
#     elif is_error:
#         id_ = obj['id']
#         error = obj['error']
#         code = error['code']
#         if not isinstance(code, int):
#             raise ValueError('Wrong "error" "code" attribute')
#         message = error['message']
#         if not isinstance(message, str):
#             raise ValueError('Wrong "error" "message" attribute')
#         data = error.get('data')
#         return jsonrpc.Error(id_, code, message, data)


# class Request:
#     def __init__(self, id_, method, params):
#         self.id = id_
#         self.method = method
#         self.params = params


# def Response:
#     def __init__(self, id_ result):
#         self.id = id_
#         self.result = result


# def Error:
#     def __init__(self, id_ code, message, data):
#         self.id = id_
#         self.code = code
#         self.message = message
#         self.data = data

