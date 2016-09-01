外呼通知
############

.. module:: ext.duo_callback

状态
************

当 :term:`CTI` 服务器收到 :doc:`/api-spec/ext/notify_call` 指令后，就会尝试新建一个 `外呼通知` 资源，并返回资源 ID，其状态变化描述如下：

* 当资源被创建后，被叫尚未被呼通，处于初始状态(``Initiated``)。

* 等待外呼的结果

  * 如果呼叫成功，状态变为 ``Answered``，开始播放通知提示音。
  * 如果呼叫失败，资源将被释放，状态变为 ``Released``。

.. graphviz::

  digraph CallResourceState {

    Start [shape=point, color=blue, fontcolor=blue];
    Initiated [color=blue, fontcolor=blue];
    Released [shape=doublecircle, color=red, fontcolor=red];

    Start -> Initiated [label="启动"];
    Initiated -> Answered [label="呼叫成功"]
    Initiated -> Released [color=red];

    Answered -> Released [color=red];
  }

构造
************

.. function::
  construct(from_uri, to_uri, play_content, play_repeat, max_ring_seconds, user_data)

  :param str from_uri: 主叫号码 :term:`SIP URI`。

    主叫号码隐藏功能可通过该参数的不同赋值实现。

    :default: `None` 不指定主叫。此时主叫号码由线路及运营商的实际设置情况决定。

    .. attention:: 不是每个主叫号码都能被 VoIP 网关的外呼线路接受！

  :param to_uri: 见 :func:`sys.call.construct` 的同名参数
  :type to_uri: str, list

  :param play_content: 通知提示音内容。

    该参数格式定义见 :func:`sys.call.play_start` 的 `content` 参数

  :type play_content: str, list

  :param play_repeat: 重复播放次数。0表示不重复播放（只播放1次），1表示重复一次（共播放两次）

    :default: `1`

  :param int max_ring_seconds: 外呼时，收到对端振铃后，最大等待时间。振铃超过这个时间，则认为呼叫失败。

    :default: `50`

  :param str user_data: 应用服务自定义数据，可用于 `CDR` 标识。

    :default: `None`

  :return: 资源ID和IPSC相关信息。

    其格式结果(``result``)部分形如:

    .. code-block:: json

      {
        "res_id": "0.0.0-ext.notify_call-23479873432234",
        "user_data": "your user data",
        "ipsc_info": {
          "process_id": 23479873432234
        }
      }

    .. important::
      在后续的资源操作 :term:`RPC` 中，应用服务需要使用 ``res_id`` 参数确定要操作的资源。

事件
*********

结束
===========

.. function:: on_released(res_id, error, begin_time, answer_time, end_time, dropped_by, user_data)

  :param str res_id: 触发事件的资源 `ID`。
  :param error: 错误信息。如果出现错误失败，该参数记录错误信息。
  :param int begin_time: 开始时间（ :term:`CTI` 服务器的 :term:`Unix time` ）。
  :param int answer_time: 应答时间（ :term:`CTI` 服务器的 :term:`Unix time` ）。如果未应答，则该参数的值是 ``null``。
  :param int end_time: 结束时间（ :term:`CTI` 服务器的 :term:`Unix time` ）。

  :param str dropped_by: 结束呼叫的者。

    ============ ============
    值           说明
    ============ ============
    ``sys``      系统一侧挂断呼叫
    ``usr``      用户一侧挂断呼叫
    ============ ============

  :param str user_data: 用户数据，来源于 :func:`construct` 的 ``user_data`` 参数
