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
  :param int max_answer_seconds:
  :param int max_ring_seconds:
  :param str ring_play_file: 第二方拨号时，对第一方播放的提示应，如果该值为空字符串或者 `null` ，则透传播放回铃音

  :param int ring_play_mode: 回应提示应文件 ``ring_play_file`` 播放模式

    ====== ===========
    枚举值  说明
    ====== ===========
    ``0``  第二方振铃后开始播放
    ``1``  呼叫启动时开始播放
    ====== ===========

  :param str record_file:
  :param str user_data:

方法
***********

放弃
===========

.. function::
  cancel(res_id)

  .. warning:: 只能在呼叫第二方之前放弃！
