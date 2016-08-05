

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

// prj_agent_queue() : ��ϯ�ŶӺ�����ϵͳ��ѯ�ú��������Ŀ����ϯ�������ڸú����г�ʱ��ѭ�������ȴ�����
// ������ֻ�������������ڵ���ϯ��������֮��������������������ڡ�
// skillgroupid_set �ǹ��˺�ļ���
// allow_notready,allow_offhook,allow_lock ����Χ������
// queue_duration,in_ring_duration �ⲿʹ��
function prj_agent_queue(queue_step,queue_model_id,agentid,termid,ism3g,option,skillgroupid,agent_list)
begin
		queue_result = 0
		out_agentid = -1
		agentmgr = GetAgentMgr()
		
		if queue_step == 0 and len(agent_list) <= 0:
			return (-1,queue_step,out_agentid)
			
		if queue_step == 0: queue_step = 1
			
		if queue_model_id == 'QM_LOOP':
			if len(agent_list) > 0:
				on = -1
				ooaid = -1
				agent_list.sort(reverse=True)
				oaid = agent_list[0]
				for aid in agent_list:
					if agentmgr.IsAgentQueueReady(aid,skillgroupid,termid):
						n = agentmgr.GetAgentLastRingTimeMS(aid,termid,ism3g)
						if n > on:
							on = n
							ooaid = oaid
						oaid = aid
				
				out_agentid = ooaid
				if ooaid < 0:
					queue_result = -4
				else:
					queue_result = 1
				queue_step += 1

		else:
			queue_result = -2
					
		return (queue_result,queue_step,out_agentid)
end