CDR API
#######

.. module:: sys

CDR(Call detail record)在每一次呼叫结束后产生一条，无论是否呼通，主叫还是被叫。

有两种方法获得 CDR 数据：

#. 当物理通道关闭（实际的呼叫结束）时，CTI抛出 :func:`on_chan_closed` 事件，该事件的参数是一条 CDR 信息。
#. 从CDR文本日志文件可以获取若干条CDR。

当呼叫所使用的物理通道被关闭，该事件触发。

以下情况引发物理通道关闭：

* 拨号失败
* 呼叫断开（无论主动还是被动）
* 呼入被重定向（调用 :func:`call.redirect` 引发）
* 呼入被拒接（调用 :func:`call.reject` 引发）

:mod:`ext` 这一系列呼叫的结束也会引发通道关闭。

.. function:: on_chan_closed(*args)

  :param list args: 这一条CDR数据的值，是一个数组。

    .. tip:: CDR 文本日志的行数据中，使用逗号分隔的形式记录这个数组。

    其数组元素按照顺序分别是：

    #. ``id``: UUID
    #. ``nodeid``: IPSC节点ID（格式：区域ID.站ID.IPSC实例ID）
    #. ``cdrid`` CDR 记录ID
    #. ``processid``: 流水号（全局唯一，IPSC实例启动时开始计算，单个实例期间严格递增）
    #. ``callid``: 呼叫标识号（节点内全局唯一）
    #. ``ch``: 通道号：因交换机初始化时间不同，通道号可能会变化
    #. ``devno``: 设备号：
        * 中继：格式 “0:0:1:1”---“交换机号:板号:中继号:通道号”；
        * SIP：格式“0:0:1”---“交换机号:板号:通道号”；
        * FXO：格式“0:0:1”---“交换机号:板号:通道号”；
    #. ``ani``:	主叫号码
    #. ``dnis``: 被叫号码
    #. ``dnis2``: 原被叫号码
    #. ``orgcallno``: 原始号码
    #. ``dir``: 呼叫方向
        * `0`: 呼入
        * `1`: 呼出
        * `2`: 内部呼叫（保留）
    #. ``devtype``: 通道设备类型
        * `1`: 中继
        * `2`: SIP
        * `3`: H323
        * `4`: 模拟外线
        * `5`: 模拟内线
        * `10`:	逻辑通道
    #. ``busitype``: 业务类型字符串标志
    #. ``callstatus``: 呼通标志
        * `0`: 呼叫未接通
        * `1`: 呼叫接通
    #. ``endtype``: 结束类型
        * `0`: 空（初始值，未定义）
        * `1`: 本地拆线
        * `2`: 远端拆线
        * `3`: 设备拆线
    #. ``ipscreason``: 呼叫失败原因：IPSC定义reason值
    #. ``callfailcause``: 呼叫失败原因：设备、SS7、PRI、SIP的失败cause值
    #. ``callbegintime``: 开始时间（`YYYY-MM-DD HH:MM:SS`）
    #. ``connectbegintime``: 应答时间（`YYYY-MM-DD HH:MM:SS`）（呼叫未接通时，该时间为空）
    #. ``callendtime``: 挂断时间（`YYYY-MM-DD HH:MM:SS`）
    #. ``talkduration``: 通话时长（单位秒，应答时间-挂断时间，如果没有应答时间，通话时长为0）
    #. ``projectid``: 虚拟化项目ID
    #. ``flowid``: 流程ID
    #. ``additionalinfo1``: 附加信息1，本项目中用于记录资源ID(`res_id`)，资源的概念见 :doc:`mechanism` 一章。
    #. ``additionalinfo2``: 附加信息2，本项目中用于记录此呼叫的相关 ``user_data``
    #. ``additionalinfo3``: 附加信息3，未使用。
    #. ``additionalinfo4``: 附加信息4，未使用。
    #. ``additionalinfo5``: 附加信息5，未使用。
