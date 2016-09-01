
// 系统呼入号码处理
function sys_proc_callin_teleno(ch,chtype,devno,connip,connport,callingno,calledno,calledno2)
begin
    
    return callingno,calledno,calledno2
end

// 系统呼入过滤
function sys_filter_callin(ch,chtype,projectid,flowid,callingno,calledno,calledno2)
begin
    call_flag = 1
    send_ubm_flag = 1
    ubm = 1
    send_acm_flag = 1
    acm = 1
    send_ans_flag = 1
    ans = 1
    db_filter_flag = 0
    return (call_flag,send_ubm_flag,ubm,send_acm_flag,acm,send_ans_flag,ans,db_filter_flag)
end

// 系统呼出过滤
function sys_filter_callout(projectid,flowid,callingno,calledno,calledno2)
begin
    return True
end

// SIP注册
function sys_sip_registion_info(sip_authoruser_projectid,sip_userid,sip_ip,sip_port,sip_info,regmode,reginfoid,regflag)
begin
    return sip_authoruser_projectid,sip_userid,sip_ip,sip_port,sip_info,regmode,reginfoid,regflag
end

// 系统呼叫（呼入呼出）
// calldir: 呼叫方向。0 呼入、1 呼出
function sys_call_begin(calldir,ch,devno,devtype,projectid,flowid,callingno,calledno,calledno2,all_callin,dti_callin,sip_callin,fxo_callin,all_callout,dti_callout,sip_callout,fxo_callout,fxs_offhook)
begin
#   print("1")
#   TraceCh("2")
    TraceCh(ch,"sys_call_begin : %s"%(str([calldir,ch,devno,devtype,projectid,flowid,callingno,calledno,calledno2,all_callin,dti_callin,sip_callin,fxo_callin,all_callout,dti_callout,sip_callout,fxo_callout,fxs_offhook])))
    calltime = GetDate()
    pos = 0
    unitid = -1
    clientid = 18
    clienttype = 18
    cmd = 0
    cmdtype = 211
#   data = """{"id":"%ld","jsonrpc":"2.0","method":"callproc","params":{"name":"","procname":"p_cc_test1","args":["%s",%d,%d,%d,"%s",%d,"%s","%s","%s","%s","%s",%d,%d,%d,%d,%d,%d,%d,%d,%d]}}"""%(MakeId(),calltime,pos,calldir,ch,devno,devtype,projectid,flowid,callingno,calledno,calledno2,all_callin,dti_callin,sip_callin,fxo_callin,all_callout,dti_callout,sip_callout,fxo_callout,fxs_offhook)
//  SmartBusSendUserData(unitid,clientid,clienttype,cmd,cmdtype,data)
    
end

// 系统呼叫结束
// calldir: 呼叫方向。0 呼入、1 呼出
function sys_call_end(calldir,ch,devno,devtype,projectid,flowid,callingno,calledno,calledno2,all_callin,dti_callin,sip_callin,fxo_callin,all_callout,dti_callout,sip_callout,fxo_callout,fxs_offhook)
begin
    TraceCh(ch,"sys_call_end : %s"%(str([calldir,ch,devno,devtype,projectid,flowid,callingno,calledno,calledno2,all_callin,dti_callin,sip_callin,fxo_callin,all_callout,dti_callout,sip_callout,fxo_callout,fxs_offhook])))
    calltime = GetDate()
    pos = 1
    unitid = -1
    clientid = 18
    clienttype = 18
    cmd = 0
    cmdtype = 211
    data = """{"id":"%ld","jsonrpc":"2.0","method":"callproc","params":{"name":"","procname":"p_cc_test1","args":["%s",%d,%d,%d,"%s",%d,"%s","%s","%s","%s","%s",%d,%d,%d,%d,%d,%d,%d,%d,%d]}}"""%(MakeId(),calltime,pos,calldir,ch,devno,devtype,projectid,flowid,callingno,calledno,calledno2,all_callin,dti_callin,sip_callin,fxo_callin,all_callout,dti_callout,sip_callout,fxo_callout,fxs_offhook)
//  SmartBusSendUserData(unitid,clientid,clienttype,cmd,cmdtype,data)
end

function sys_channel_close(id,nodeid,cdrid,processid,callid,ch,devno,ani,dnis,dnis2,orgcallno,dir,devtype,busitype,callstatus,endtype,ipscreason,callfailcause,callbegintime,connectbegintime,callendtime,talk_duration,projectid,flowid,additionalinfo1,additionalinfo2,additionalinfo3,additionalinfo4,additionalinfo5)
begin
    args = (id,nodeid,cdrid,processid,callid,ch,devno,ani,dnis,dnis2,orgcallno,dir,devtype,busitype,callstatus,endtype,ipscreason,callfailcause,callbegintime,connectbegintime,callendtime,talk_duration,projectid,flowid,additionalinfo1,additionalinfo2,additionalinfo3,additionalinfo4,additionalinfo5)
    #
    Trace('{} {}'.format(sys_channel_close, args))
    # choose the target
    local_unit_id = GetServerNodeID()
    local_candidates = []
    remote_candidates = []
    for unit_id, client_id, client_type, add_info in SmartbusGetNodeInfo(10):
        if unit_id == local_unit_id:
            local_candidates.append((unit_id, client_id, client_type))
        elif not local_only:
            remote_candidates.append((unit_id, client_id, client_type))
    if local_candidates:
        target_addr = randchoice(local_candidates)
    elif (not local_only) and remote_candidates:
        target_addr = randchoice(remote_candidates)
    else:
        raise IvrError(0, '找不到可用的bus客户端')
    # send
    unit_id, client_id, _ = target_addr
    data = dict(method='sys.on_chan_closed', params=args)
    SmartbusSendData(unit_id, client_id, 0xff, 0, 3, json.dumps(data, ensure_ascii=False))
end
