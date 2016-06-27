呼叫 API
#############

.. module:: call

呼叫资源的状态
***************
呼叫资源的产生有两个途径：

#. 应用服务调用资源构造方法，用于呼出。
#. 收到来自外界的呼入请求，资源被自动创建。

在呼叫资源产生后：

* 当呼入呼叫没有被应用服务同意接听，或者呼出呼叫没有被对端接听时，该呼叫处于初始状态(``Initiated``)。
* 当呼叫被接听，而应用服务还没有决定下一步做什么的时候，呼叫处于空闲状态(``Idle``)。
* 当应用程序控制呼叫进行 :term:`CTI` 动作时（如：录/放音、收/发 :term:`DTMF` 码），呼叫处于各个 :term:`CTI` 动作的执行状态。
* 当 :term:`CTI` 动作执行完毕或者被中止，呼叫的状态又回到了空闲。
* 当呼叫被挂断，如果呼叫资源处于 ``Idle``，它将直接变为终结状态——释放(``Released``)；
  如果处于动作执行状态，则会先转变为 ``Idle`` ，然后在短时间内（通常不超过5毫秒）变为 ``Released`` 状态。

.. graphviz::

  digraph CallResourceState {

    size="6,6";
    rankdir="LR";

    Start [shape=point, color=blue, fontcolor=blue];
    Initiated [color=blue, fontcolor=blue];
    Answer [color=olive, fontcolor=olive];
    Idle [color=green, fontcolor=green];
    Released [shape=doublecircle, color=red, fontcolor=red];

    Start -> Initiated[label="呼入/呼出", color=blue];
    Initiated -> Released [label="未接听", color=red];
    Initiated -> Answer[label="呼入接听", fontcolor=blue];
    Initiated -> Idle [label="呼出被接听", color=green];
    Answer -> Idle [label="接听成功", color=green];
    Answer -> Released [label="接听失败/挂断", color=red];
    Idle -> Released [label="挂断", color=red];

    Idle -> Play;
    Play -> Idle;

    Idle -> Record;
    Record -> Idle;

    Idle -> SendDtmf;
    SendDtmf -> Idle;

    Idle -> ReceiveDtmf;
    ReceiveDtmf -> Idle;

    Idle -> Bridge;
    Bridge -> Idle;

    Idle -> Conf;
    Conf -> Idle;
  }

.. attention::
  :term:`CTI` 动作的开始和停止指令都是异步的。

.. warning::
  呼叫资源只有当处于 ``Idel`` 状态时，才可以执行新的动作发起指令。
  应用服务需要等待上一个 :term:`CTI` 动作结束（不管是主动结束，抑或仅仅是被动等待其结束），方可发起下一个动作的开始指令。

呼叫资源的接口
***************

构造
==========

.. function::
  construct(from_uri, to_uri, max_answer_seconds, max_ring_seconds, parent_call_res_id, ring_play_file, user_data)

  :param str from_uri: 主叫号码 :term:`SIP URI`。
  :param str to_uri: 被叫号码 :term:`SIP URI`。
  :param int max_answer_seconds: 呼叫的通话最大允许时间，单位是秒。
  :param int max_ring_seconds: 外呼时，收到对端振铃后，最大等待时间。振铃超过这个时间，则认为呼叫失败。
  :param str parent_call_res_id: 父呼叫资源ID。
    如果该参数不为 `null` ，系统将在此参数指定父呼叫资源上进行拨号。
    拨号期间，父呼叫可以听到拨号提示音。
  :param str ring_play_file: 拨号时，在对方振铃期间向父呼叫播放的声音文件。
    仅在指定 ``parent_call_res_id`` 参数时有意义。
    如果指定了 ``parent_call_res_id`` 参数，且本参数为 ``null`` 或者空字符串，则在拨号时向父呼叫透传原始的线路拨号提示音。
  :param str user_data: 应用服务自定义数据，通常用于 `CDR` 标识。

  .. important::
    仅适用于 **出方向** 呼叫。

  .. warning::
    如果指定了 ``parent_call_res_id`` 参数，其对应的父呼叫状态 **必须** 为 ``Idle``。

方法
=========

应答
-------

.. function:: answer(max_answer_seconds, user_data)

  :param int max_answer_seconds: 呼叫的通话最大允许时间，单位是秒。
  :param str user_data: 应用服务自定义数据，通常用于 `CDR` 标识。

  .. important::

    * 仅适用于 **入方向** 呼叫。
    * 只能在 :func:`on_incoming` 事件触发后调用。
    * 已经应答的呼叫不可再次应答。

挂断
------

.. function:: drop( cause)

  :param int cause: 挂机原因，详见 :term:`SIP` 协议 `status code` 规范

  .. important::

    * 调用后，呼叫资源被释放。
    * 调用后，将触发 :func:`on_released` 事件。

重定向
---------

通常用于在收到与当前 `IPSC` 进程不匹配的呼入时，将呼入呼叫重指向到正确的 `IPSC` 进程。

.. function:: redirect(redirect_uri)

  :param str redirect_uri: 重定向的目标 :term:`SIP URI`

  .. important::

    * 仅适用于 **入方向** 呼叫。
    * 只能在 :func:`on_incoming` 事件触发后调用。
    * 已经应答的呼叫不可被重定向。
    * 调用后，呼叫资源被释放，将触发 :func:`on_released` 事件。

开始放音
------------

.. function:: play_start(content, finish_keys)

  :param content: 待播放内容

    * 当该参数为字符串时，播放字符串所对应的声音文件。
    * 当该参数为列表时，暂时不支持！TODO ....

      0	文件播放
      1	数字播放
      2	数值播放
      3	金额播放
      4	日期时间播放
      5	时长播放
      6	金额播放（元角分）
      7	多文件播放
      10 TTS
      <0 忽略（不播放）

  :type content: str, list
  :param str finish_keys: 播放打断按键码串。
    在播放过程中，如果接收到了一个等于该字符串中任何一个字符的 :term:`DTMF` 码，则停止播放。

停止放音
-------------

中断正在进行的放音，将放音停止，触发事件 :func:`on_play_completed`。

.. function:: play_stop()

开始录音
------------

.. function:: record_start(max_seconds, beep, record_file, record_format, finish_keys)

  :param int max_seconds: 录音的最大时间长度，单位是秒。超过该事件，录音会出错，并结束。
  :param bool beep: 是否在录音之前播放“嘀”的一声。

  :param int record_format: 录音文件格式

    ====== ===========
    值     说明
    ====== ===========
    ``1`` PCM liner 8k/8bit
    ``2`` CCITT a-law 8k/8bit
    ``3`` CCITT mu-law 8k/8bit
    ``4`` IMA ADPCM
    ``5`` GSM
    ``6`` MP3
    ====== ===========

  :param str finish_keys: 录音打断按键码串。
    在录音过程中，如果接收到了一个等于该字符串中任何一个字符的 :term:`DTMF` 码，则停止录音。

停止录音
-------------

中断正在进行的录音，将录音错误，触发事件 :func:`on_record_completed`。

.. function:: record_stop()

  :param str res_id: 要操作的呼叫资源 `ID`。

开始发送 :term:`DTMF` 码
-------------------------

.. function:: send_dtmf_start(keys)

  :param str keys: 要发送的 :term:`DTMF` 码串。

开始接收 :term:`DTMF` 码
-------------------------

.. function:: receive_dtmf_start(valid_keys, max_keys, finish_keys, first_key_timeout, continues_keys_timeout, play_content, play_repeat)

  :param str valid_keys: 有效 :term:`DTMF` 码范围字符串。
    只有存于这个字符串范围内的 :term:`DTMF` 码才会被接收，否则被忽略。

  :param int max_keys: 接收 :term:`DTMF` 码的最大长度。
    一旦达到最大长度，此次接收过程即宣告结束。

    .. note::
      只要收到的 :term:`DTMF` 码达到最大长度，即使没有收到结束码，接收过程也会结束。

  :param str finish_keys: 结束码串。
    在接收 :term:`DTMF` 码的过程中，如果接收到了一个等于该字符串中任何一个字符的 :term:`DTMF` 码，则此次接收过程即宣告结束。

    .. important::
      结束码串中的字符如果不属于有效 :term:`DTMF` 码范围字符串(``valid_keys``)，
      就会被接收过程忽略，无法结束接收过程。

    .. attention::
      结束码字符 **不会** 被包含在 :func:`on_receive_dtmf_completed` 的 ``keys`` 参数中。

  :param int first_key_timeout: 等待接收第一个 :term:`DTMF` 码的超时时间（秒）。
    如果在这段时间内，没有收到第一个 :term:`DTMF` 码，则进行超时处理。
  :param int continues_keys_timeout: 等待接收后续 :term:`DTMF` 码的超时时间（秒）。
    如果在这段时间内，没有收到后续 :term:`DTMF` 码，则进行超时处理。

  :param int play_content: 提示音。在接收过程开始时，要播放的声音内容。
    一旦接收到第一个 :term:`DTMF` 码，就停止放音。
    目前，该参数只能是声音文件名。
  :type play_content: str, list

  :param int play_repeat: 如果出现等待超时，按照该参数重复播放提示音。

结束接收 :term:`DTMF` 码
-----------------------------

.. function:: stop_receive_dtmf_start()

  该操作将导致接收 :term:`DTMF` 码的过程结束，并触发 :func:`on_receive_dtmf_completed` 事件。

桥接开始
----------

.. function::
  bridge_start(max_seconds, call_res_id, bridge_mode, record_file, record_format, local_volume, remote_volume, schedule_play_time, schedule_play_file, schedule_play_loop)

  :param int max_seconds: 最大桥接时间长度（秒）。
  :param str call_res_id: 要和当前呼叫资源桥接的呼叫资源ID。

  :param int bridge_mode: 桥接模式。

    ====== =====================
    值     说明
    ====== =====================
    ``1``  桥接双方均可互相听到
    ``2``  仅被桥接方可以听到发起方;发起方听不到被桥接方
    ``3``  仅发起方可以听到被桥接方;被桥接方听不到发起方
    ====== =====================

  :param str record_file: 录音文件。如果该参数不为 `null` 或空字符串，则连接期间双方的通话被保存在这个文件，否则不录音。
  :param int record_format: 见 :func:`record_start` 的 ``record_format`` 参数。
  :param int local_volume: 桥接建立后的发起方音量。`null` 表示默认音量。
  :param int remote_volume: 桥接建立后的发起方音量。`null` 表示默认音量。
  :param int schedule_play_time: 到达这个 :term:`Unix time` 时间点，触发播放声音。
  :param str schedule_play_file: 到达 ``schedule_play_time`` 时间点时播放此声音文件。
  :param int schedule_play_loop: 到达 ``schedule_play_time`` 时间点时，循环播放，0表示不循环，1表示循环。

桥接结束
----------

.. function:: bridge_stop()

  .. attention:: 只能对桥接的发起呼叫资源进行该操作。

进入会议
--------------

.. function:: conf_enter(conf_res_id, max_seconds, mode, volume, play_file)

  :param str conf_res_id: 要加入的会议资源 `ID`。

  :param int max_seconds: 该呼叫加入会议的最大允许时间

  :param int mode: 加入之后的放音模式

    ====== ========
    值     说明
    ====== ========
    ``1``  放音+收音
    ``2``  放音
    ``3``  收音
    ``4``  无
    ====== ========

  :param int volume: 加入会议后的初始音量

  :param str play_file: 该呼叫加入后，对会议播放的声音文件

退出会议
-------------

.. function:: conf_exit(conf_res_id)

  :param str conf_res_id: 要退出的会议资源 `ID`。

事件
============

新呼入呼叫
------------

.. function:: on_incoming(res_id, from_uri, to_uri, begin_time)

  :param str res_id: 触发事件的呼叫资源 `ID`。
  :param str from_uri: 该呼叫的主叫号码(:term:`SIP URI`)。
  :param str to_uri: 该呼叫的被叫号码(:term:`SIP URI`)。
  :param int begin_time: 本次入方向呼叫的开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。

  .. important::
    仅适用于 **入方向** 呼叫。
    应用服务可通过 :func:`answer` 应答，继续呼叫资源的生命周期；
    或者通过 :func:`drop` 挂断呼叫，释放呼叫资源。

拨号结束
-----------
在外呼拨号失败、超时或者被接听时发生

.. function:: on_dial_completed(res_id, error, begin_time, answer_time, end_time)


  :param str res_id: 触发事件的呼叫资源 `ID`。
  :param error: 错误信息。如果拨号失败，该参数记录错误信息。如果拨号成功的被接听，该参数的值是 ``null``。
  :param int begin_time: 本次拨号的开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param int answer_time: 本次拨号的被应答时间(:term:`CTI` 服务器的 :term:`Unix time`)。
    如果外呼拨号没有被应答，则该参数的值是 ``null``。

  :param int end_time: 本次拨号的结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。

    .. note:: 这个时间只是拨号的结束时间，不是整个呼叫的结束时间。

呼叫被释放
-------------

.. function:: on_released(res_id, call_dir, from_uri, to_uri, begin_time, answer_time, end_time, dropped_by, cause)

  :param str res_id: 触发事件的呼叫资源 `ID`。

  :param str call_dir: 呼叫方向

    ============ ============
    值            说明
    ============ ============
    ``inbound``  入方向呼叫
    ``outbound`` 出方向呼叫
    ============ ============

  :param str from_uri: 该呼叫的主叫号码(:term:`SIP URI`)。
  :param str to_uri: 该呼叫的被叫号码(:term:`SIP URI`)。
  :param int begin_time: 该呼叫的开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param int answer_time: 该呼叫的应答时间(:term:`CTI` 服务器的 :term:`Unix time`)。
    如果呼叫没有被接听，该参数的值是 ``null``。
  :param int end_time: 该呼叫的结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。

  :param str dropped_by: 结束呼叫的者。

    ============ ============
    值           说明
    ============ ============
    ``sys``      系统一侧挂断呼叫
    ``usr``      用户一侧挂断呼叫
    ============ ============

  :param int cause: 呼叫结束的原因码。详见 :term:`SIP` 状态码定义。

放音结束
-------------

.. function:: on_play_completed(res_id, error, begin_time, end_time, finish_key)

  :param str res_id: 触发事件的呼叫资源 `ID`。
  :param error: 错误信息。如果播放失败，该参数记录错误信息；否则该参数的值是 ``null``。
  :param int begin_time: 放音开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param int end_time: 放音结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param str finish_key: 中断此次放音的 :term:`DTMF` 按键码。如果此次放音没有被按键中断，则该参数的值是 ``null``。

录音结束
--------------

.. function:: on_record_completed(res_id, error, begin_time, end_time, finish_key)

  :param str res_id: 触发事件的呼叫资源 `ID`。
  :param error: 错误信息。如果录音失败，该参数记录错误信息；否则该参数的值是 ``null``。
  :param int begin_time: 录音开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param int end_time: 录音结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param str finish_key: 中断此次录音的 :term:`DTMF` 按键码。如果此次放音没有被按键中断，则该参数的值是 ``null``。

发送 :term:`DTMF` 码结束
--------------------------

.. function:: on_send_dtmf_completed(res_id, error, begin_time, end_time)

  :param str res_id: 触发事件的呼叫资源 `ID`。
  :param error: 错误信息。如果 :term:`DTMF` 码发送失败，该参数记录错误信息；否则该参数的值是 ``null``。
  :param int begin_time: :term:`DTMF` 码发送开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param int end_time: :term:`DTMF` 码发送结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。

接收 :term:`DTMF` 码结束
----------------------------

.. function:: on_receive_dtmf_completed(res_id, error, begin_time, end_time, keys)

  :param str res_id: 触发事件的呼叫资源 `ID`。
  :param error: 错误信息。如果 :term:`DTMF` 码接收失败，该参数记录错误信息；否则该参数的值是 ``null``。
  :param int begin_time: :term:`DTMF` 码接收开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param int end_time: :term:`DTMF` 码接收结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param str keys: 接收到的 :term:`DTMF` 码字符串。
