
// 项目呼入电话号码处理

function prj_proc_callin_teleno(ch,chtype,devno,connip,connport,callingno,calledno,calledno2)

begin
	
	
	return callingno,calledno,calledno2

end



// 项目呼入信令控制

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

// 项目呼出过滤
function prj_filter_callout(flowid,callingno,calledno,calledno2)
begin
	return True
end

// 项目物理通道关闭
function prj_channel_close(id,nodeid,cdrid,processid,callid,ch,devno,ani,dnis,dnis2,orgcallno,dir,devtype,busitype,callstatus,endtype,ipscreason,callfailcause,callbegintime,connectbegintime,callendtime,talk_duration,projectid,flowid,additionalinfo1,additionalinfo2,additionalinfo3,additionalinfo4,additionalinfo5)

begin

//	param=(('id',id,200,1),('nodeid',nodeid,200,1),('processid',processid,3,1),('callid',callid,3,1),('chno',ch,3,1),('devno',devno,200,1),('callingno',ani,200,1),('calledno',dnis,200,1),('calledno2',dnis2,200,1),('orgcallno',orgcallno,200,1),('calldir',dir,3,1),('devtype',devtype,3,1),('busitype',busitype,200,1),('talked',callstatus,3,1),('endtype',endtype,3,1),('ipsc_reason',ipscreason,3,1),('callfail_cause',callfailcause,3,1),('begintime',callbegintime,200,1),('answertime',connectbegintime,200,1),('endtime',callendtime,200,1),('projectid',projectid,200,1),('flowid',flowid,200,1),('additional1',additionalinfo1,200,1),('additional2',additionalinfo2,200,1),('additional3',additionalinfo3,200,1),('additional4',additionalinfo4,200,1),('additional5',additionalinfo5,200,1))
//	res = AsynExecDbSP("SYSDB",'"CC_IVR_p_InsertCdr"',param)
//	if res[0] < 1:
//		Trace('prj_channel_close fail : res=%d errmsg="%s".'%(res[0],res[1]))
end
