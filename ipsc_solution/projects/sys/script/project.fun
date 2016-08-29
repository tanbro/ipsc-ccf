

function prj_proc_callin_teleno(ch,chtype,devno,connip,connport,callingno,calledno,calledno2)
begin
	
	return callingno,calledno,calledno2
end


function prj_filter_callin(ch,chtype,flowid,callingno,calledno,calledno2)
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


// 项目物理通道关闭
function prj_channel_close(id,nodeid,cdrid,processid,callid,ch,devno,ani,dnis,dnis2,orgcallno,dir,devtype,busitype,callstatus,endtype,ipscreason,callfailcause,callbegintime,connectbegintime,callendtime,talk_duration,projectid,flowid,additionalinfo1,additionalinfo2,additionalinfo3,additionalinfo4,additionalinfo5)
begin
	args = (id,nodeid,cdrid,processid,callid,ch,devno,ani,dnis,dnis2,orgcallno,dir,devtype,busitype,callstatus,endtype,ipscreason,callfailcause,callbegintime,connectbegintime,callendtime,talk_duration,projectid,flowid,additionalinfo1,additionalinfo2,additionalinfo3,additionalinfo4,additionalinfo5)
	Trace('{} {}'.format(prj_channel_close, args))
	jsonrpc.send_event('call.on_chan_closed', {"res_id": additionalinfo1, "user_data": additionalinfo2, "ipsc_info": args})
end
