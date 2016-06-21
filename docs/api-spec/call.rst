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

.. function:: on_incoming(res_id, from_uri, to_uri)

  :param str res_id: 触发事件的呼叫资源 `ID`。
  :param str from_uri: 主叫号码 :term:`SIP URI`。
  :param str to_uri: 被叫号码 :term:`SIP URI`。

  .. important::
    仅适用于 **入方向** 呼叫。
    应用服务可通过 :func:`answer` 应答，继续呼叫资源的生命周期；
    或者通过 :func:`drop` 挂断呼叫，释放呼叫资源。

呼叫被应答
===========

.. function:: on_answered(res_id)

  :param str res_id: 触发事件的呼叫资源 `ID`。

  .. important::
    仅适用于 **出方向** 呼叫。

呼叫被释放
============

.. function:: on_released(res_id)

  :param str res_id: 触发事件的呼叫资源 `ID`。

文件放音结束
=============

.. function:: on_play_completed(res_id)

  :param str res_id: 触发事件的呼叫资源 `ID`。

录音结束
=============

.. function:: on_record_completed(res_id)

  :param str res_id: 触发事件的呼叫资源 `ID`。
