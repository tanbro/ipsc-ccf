#!/usr/bin/env python
# -*- coding: utf-8 -*-

def on_call_ringing(res_id):
    call_map = _gd_['call_map'] # chan => call_info
    conf_map = _gd_['conf_map'] # res_id => call_info
    call_map_r = _gd_['call_map_r'] # res_id => call_info
    conf_map_r = _gd_['conf_map_r'] # res_id -> conf_info

    call_info = call_map_r[res_id]
    chan = call_info['chan']

    call_info['ring_time'] = now()
    call_info['answer_time'] = None
    call_info['state'] = 'Ring'

    jsonrpc.send_event(
    	method='call.on_ringing',
    	params={
        	'res_id': res_id,
        	'ring_time': call_info['ring_time'],
        	'user_data': call_info['params'].get('user_data'),
        },
    )
