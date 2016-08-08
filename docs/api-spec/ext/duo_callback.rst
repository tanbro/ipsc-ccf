双向回拨 API
#############

.. module:: ext.duo_callback

状态
**********

.. graphviz::

  digraph CallResourceState {

    Start [shape=point, color=blue, fontcolor=blue];
    Initiated [color=blue, fontcolor=blue];
    Released [shape=doublecircle, color=red, fontcolor=red];

    Start -> Initiated [label="启动"];
    Initiated -> Dialing1 [label="呼叫第一方"]
    Dialing1 -> Released [label="呼叫失败", color=red];

    Dialing1 -> Dialing2 ["label"="第一方接通后，\n呼叫第二方"];
    Dialing2 -> Released [label="呼叫失败", color=red];
    Dialing2 -> Connected ["label"="通话", color=green];

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
