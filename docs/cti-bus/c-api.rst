C API
########

`IPSC` 总线提供了一个原生的客户端函数库，应用服务的开发者需要通过使用这个库提供的 `C API` ，
实现各项程序功能。

这个函数库目前仅运行在 `linux x86_64 gcc` 环境中。

本章节罗列出该库中有用的函数、回调、常量。

函数
*****

初始化
=======

.. c:function::
  int SmartBusNetCli_Init(unsigned char unitid)

  :param unitid: 该客户端在总线体系中的节点ID。值必须大于等于 `16` 。

                 .. warning:: 节点 `ID` 在总线体系中必须全局唯一，不得重复。

  :return: 执行结果。 `0` 表示成功，其它见错误码。

  .. important:: 在使用其它库函数之前，必须先调用该函数进行初始化。

释放
=======

.. c:function::
  void SmartBusNetCli_Release()

设置回调函数
============

.. c:function::
  void SmartBusNetCli_SetCallBackFn(smartbus_cli_connection_cb client_conn_cb, smartbus_cli_recvdata_cb recv_cb, smartbus_cli_disconnect_cb disconnect_cb, smartbus_invokeflow_ret_cb invokeflow_ret_cb, smartbus_global_connect_cb global_connect_cb, void * arg)

  :param client_conn_cb:     客户端连接结果回调
  :param recv_cb:            接收数据回调
  :param disconnect_cb:      连接端口回调
  :param invokeflow_ret_cb:  调用流程返回回调
  :param global_connect_cb:  全局连接回掉
  :param arg:                回调函数自定义参数

设置回调函数（扩展）
=====================

.. c:function::
  void SmartBusNetCli_SetCallBackFnEx(const char * callback_name, void * callbackfn)

  :param callback_name:  待设定的回调函数名称
  :param callbackfn:     回调函数指针

创建连接
========

.. c:function::
  int SmartBusNetCli_CreateConnect(unsigned char local_clientid, int local_clienttype, const char * masterip, unsigned short masterport, const char * slaverip, unsigned short slaverport, const char * author_username, const char * author_pwd, const char * add_info)

  :param local_clientid:    客户端ID，亦即该连接在节点中的ID
  :param local_clienttype:  连接的客户端类型
  :param masterip:          要连接的总线服务器的IP地址
  :param masterport:        要连接的总线服务器的端口
  :param slaverip:          要连接的从属总线服务器的IP地址，如果不需要连接 `slaver` ，则填写 ``NULL``
  :param slaverport:        要连接的从属总线服务器的IP地址，如果不需要连接 `slaver` ，则填写 ``0xFFFF``
  :param author_username:   验证用户名，如不需要验证，则填写 ``NULL``
  :param author_pwd:        验证密码，如不需要验证，则填写 ``NULL``
  :param add_info:          附加信息
  :return:                  执行结果。 `0` 表示成功，其它见错误码。

启动流程
=========

.. c:function::
  int SmartBusNetCli_RemoteInvokeFlow(unsigned char local_clientid, int server_unitid, int ipscindex, const char * projectid, const char * flowid, int mode, int timeout, const char * in_valuelist)

  :param local_clientid: 用于发送该流程调用消息的本地客户端ID。
  :param server_unitid: 目标IPSC服务器节点ID。
  :param ipscindex: IPSC进程编号。
  :param projectid: 流程项目ID。
  :param flowid: 流程ID。
  :param mode: 调用模式。 ``0`` 表示调用需要流程返回执行结果； ``1`` 表示不需要流程返回执行结果。
  :param timeout: 调用需要流程返回执行结果时，等待结果的超时时间值，单位是毫秒
  :param in_valuelist: 流程输入参数里表。简单数据类型JSON数组（子流程开始节点的传人参数自动变换为list类型数据。）（对应的字符串内容最大长度不超过32K字节）
  :return: 大于 ``0`` 表示调用ID，用于流程结果返回匹配用途。小于 ``0`` 表示错误。

发送通知消息
============

.. c:function::
  int SmartBusNetCli_SendNotify(unsigned char local_clientid, int server_unitid, int processindex, const char * projectid, const char * title, int mode, int expires, const char * param)

  :param local_clientid:  用于发送消息的本地客户端ID
  :param server_unitid:   消息目标节点ID
  :param processindex:    消息目标的 `IPSC` 的编号
  :param projectid:       消息目标的流程项目ID
  :param title:           通知的标识
  :param mode:            调用模式
  :param expires:         消息有效期。单位ms
  :param param:           消息数据
  :return:                大于 ``0`` 表示调用ID，用于结果返回匹配用途。小于 ``0`` 表示错误。

回调
******

连接结果回调
============

.. c:function::
    typedef void (* smartbus_cli_connection_cb)(void * arg, unsigned char local_clientid, int accesspoint_unitid, int ack)

    :param args: 自定义回调传入参数，由 :c:func:`SmartBusNetCli_SetCallBackFn` 的 `arg` 参数指定。
    :param local_clientid: 连接结果发生变化的客户端的ID
    :param accesspoint_unitid: 所连接的总线服务的节点ID
    :param ack: 连接结果。 ``0`` 表示建立连接成功；小于 ``0`` 表示连接失败

连接断开回调
============

.. c:function::
  typedef void (* smartbus_cli_disconnect_cb)(void * arg, unsigned char local_clientid)

  :param args: 自定义回调传入参数，由 :c:func:`SmartBusNetCli_SetCallBackFn` 的 `arg` 参数指定。
  :param local_clientid: 连接断开的客户端的ID

接收数据回调
=============

.. c:function::
  typedef void (* smartbus_cli_recvdata_cb)(void * arg, unsigned char local_clientid, SMARTBUS_PACKET_HEAD * head, void * data, int size)

  :param args: 自定义回调传入参数，由 :c:func:`SmartBusNetCli_SetCallBackFn` 的 `arg` 参数指定。
  :param local_clientid: 收到数据的客户端的ID
  :param head: 数据包头
  :param data: 数据包体
  :param size: 包体字节长度
