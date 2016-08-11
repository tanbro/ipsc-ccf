双向回拨 API
#############

.. module:: ext.duo_callback

状态
**********

当 :term:`CTI` 服务器收到 :doc:`/api-spec/ext/duo_callback` 指令后，就会尝试新建一个 `双向回拨` 资源，并返回资源 ID，其状态变化描述如下：

* 当资源被创建后，第一方尚未被呼通，处于初始状态(``Initiated``)。

* 等待第一方呼叫的结果

  * 如果第一方呼叫成功，状态变为 ``Answer1``。
  * 如果第一方呼叫失败，资源将被释放，状态变为 ``Released``。

* 在第一方呼叫成功之后，继续呼叫第二方

  * 如果第二方呼叫成功，状态变为 ``Answer2``。
  * 如果呼叫第二方失败，或呼叫期间第一方挂断，或者呼叫被取消，资源将被释放，状态变为 ``Released``。
* 当应用程序控制呼叫进行 :term:`CTI` 动作时（如：录/放音、收/发 :term:`DTMF` 码），呼叫处于各个 :term:`CTI` 动作的执行状态。

* 双方都呼叫成功后，就对两个呼叫进行双通道连接，让双方通话，此状态为 ``Connected``。

* ``Connect`` 正常结束，或者期间任何一方挂断，资源将被释放，状态变为 ``Released``。

.. graphviz::

  digraph CallResourceState {

    Start [shape=point, color=blue, fontcolor=blue];
    Initiated [color=blue, fontcolor=blue];
    Released [shape=doublecircle, color=red, fontcolor=red];

    Start -> Initiated [label="启动"];
    Initiated -> Answer1 [label="呼叫第一方成功"]
    Initiated -> Released [color=red];

    Answer1 -> Answer2 ["label"="呼叫第二方成功"];
    Answer1 -> Released [color=red];

    Answer2 -> Connected ["label"="双向连接", color=green];
    Answer2 -> Released [color=red];

    Connected -> Released [label="双向回拨结束", color=red];
  }

构造
**********

.. function::
  construct(from1_uri, to1_uri, from2_uri, to2_uri, max_answer_seconds, max_ring_seconds, ring_play_file, ring_play_mode, record_file, user_data)

  :param str form1_uri: 第一方主叫号码 :term:`SIP URI`
  :param str to1_uri: 第一方被叫号码 :term:`SIP URI`
  :param str form2_uri: 第二方主叫号码 :term:`SIP URI`
  :param str to2_uri: 第二方被叫号码 :term:`SIP URI`
  :param int max_connect_seconds: 最大双通道连接时间（秒）
  :param int max_ring_seconds: 呼叫时的最大振铃等待时间（秒），两次呼叫都用这个时间
  :param str ring_play_file: 第二方拨号时，对第一方播放的提示应，如果该值为空字符串或者 `null` ，则透传播放回铃音

  :param int ring_play_mode: 回铃音文件 ``ring_play_file`` 播放模式

    ========= ============
    枚举值     说明
    ========= ============
    ``0``     收到对端回铃后开始播放
    ``1``     拨号时即开始播放，收到对端回铃后停止播放
    ``2``     拨号时即开始播放，对端接听或者挂机后停止播放
    ========= ============

  :param str record_file: 录音文件

  :param int record_mode: 录音模式枚举值

    ========= ============
    枚举值     说明
    ========= ============
    ``0``     双向接通后录音
    ``1``     开始呼叫第一方时启动录音
    ``2``     开始呼叫第二方时启动录音
    ========= ============

  :param str user_data:

  :return: 资源ID和IPSC相关信息。

    其格式结果(``result``)部分形如:

    .. code-block:: json

      {
        "res_id": "0.0.0-ext.duo_callback-23479873432234",
        "ipsc_info": {
          "process_id": 23479873432234
        }
      }

    .. important::
      在后续的资源操作 :term:`RPC` 中，应用服务需要使用 ``res_id`` 参数确定要操作的资源。

方法
***********

放弃
===========

.. function::
  cancel(res_id)

  .. warning:: 只能在第二方被接通之前放弃！
