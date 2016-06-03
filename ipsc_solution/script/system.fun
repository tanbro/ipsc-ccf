

function sys_proc_callin_teleno(ch,chtype,devno,connip,connport,callingno,calledno,calledno2)
begin
	
	return callingno,calledno,calledno2
end


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