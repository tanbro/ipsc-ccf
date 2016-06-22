呼叫 API
#############

.. module:: call

构造
***********

.. function:: construct(from_uri, to_uri, max_answer_seconds, max_ring_seconds, user_data)

  :param str from_uri: 主叫号码 :term:`SIP URI`。
  :param str to_uri: 被叫号码 :term:`SIP URI`。
  :param int max_answer_seconds: 呼叫的通话最大允许时间，单位是秒。
  :param int max_ring_seconds: 外呼时，收到对端振铃后，最大等待时间。振铃超过这个时间，则认为呼叫失败。
  :param str user_data: 应用服务自定义数据，通常用于 `CDR` 标识。

  .. important::
    仅适用于 **出方向** 呼叫。

方法
***********

应答
====

.. function:: answer(res_id, user_data)

  :param str res_id: 要操作的呼叫资源 `ID`。
  :param str user_data: 应用服务自定义数据，通常用于 `CDR` 标识。

  .. important::
    仅适用于 **入方向** 呼叫。
    只能在 :func:`on_incoming` 事件触发后调用。
    已经应答的呼叫不可再次应答。

挂断
====

.. function:: drop(res_id, cause)

  :param str res_id: 要操作的呼叫资源 `ID`。
  :param int cause: 挂机原因，详见 :term:`SIP` 协议 `status code` 规范

  .. important::
    调用后，呼叫资源被释放。

重定向
======

.. function:: redirect(res_id, redirect_uri)

  :param str res_id: 要操作的呼叫资源 `ID`。
  :param str redirect_uri: 重定向的目标 :term:`SIP URI`

  .. important::
    仅适用于 **入方向** 呼叫。
    只能在 :func:`on_incoming` 事件触发后调用。
    已经应答的呼叫不可被重定向。
    调用后，呼叫资源被释放。

开始播放声音文件
=================

.. function:: play_start(res_id, play_file: str)

  :param str res_id: 要操作的呼叫资源 `ID`。

停止播放声音文件
=================

.. function:: play_stop(res_id)

  :param str res_id: 要操作的呼叫资源 `ID`。

开始录音
===============

.. function:: record_start(res_id, record_file: str, finish_key: str)

  :param str res_id: 要操作的呼叫资源 `ID`。

停止录音
===============

.. function:: record_stop(res_id)

  :param str res_id: 要操作的呼叫资源 `ID`。

进入会议
==========

.. function:: conf_enter(res_id, conf_res_id)

  :param str res_id: 要操作的呼叫资源 `ID`。

退出会议
==========

.. function:: conf_exit(res_id, conf_res_id)

  :param str res_id: 要操作的呼叫资源 `ID`。

事件
***********

新呼入呼叫
==========

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
===========
在外呼拨号失败、超时或者被接听时发生

.. function:: on_dial_completed(res_id, begin_time, answer_time, end_time, error)


  :param str res_id: 触发事件的呼叫资源 `ID`。

  :param int begin_time: 本次拨号的开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。

  :param int answer_time: 本次拨号的被应答时间(:term:`CTI` 服务器的 :term:`Unix time`)。
    如果外呼拨号没有被应答，则该参数的值是 ``null``。

  :param int end_time: 本次拨号的结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。

    .. note:: 这个时间只是拨号的结束时间，不是整个呼叫的结束时间。

  :param error: 错误信息。如果拨号失败，该参数记录错误信息。如果拨号成功的被接听，该参数的值是 ``null``。

呼叫被应答
===========

.. function:: on_answered(res_id)

  :param str res_id: 触发事件的呼叫资源 `ID`。

  .. important::
    仅适用于 **出方向** 呼叫。

呼叫被释放
============

.. function:: on_released(res_id, call_dir, from_uri, to_uri, begin_time, answer_time, end_time, dropped_by, cause)

  :param str res_id: 触发事件的呼叫资源 `ID`。

  :param str call_dir: 呼叫方向

    ============ ============
    值           说明
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

文件放音结束
=============

.. function:: on_play_completed(res_id)

  :param str res_id: 触发事件的呼叫资源 `ID`。

录音结束
=============

.. function:: on_record_completed(res_id)

  :param str res_id: 触发事件的呼叫资源 `ID`。
