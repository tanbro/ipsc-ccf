会议 API
###########

.. module:: sys.conf

构造
***********

.. function:: construct(max_seconds, bg_file, release_threshold)

  :param int max_seconds: 会议的最大允许时间，单位是秒。
  :param str bg_file: 会议创建后，自动播放这个声音文件作为背景音。
  :param int parts_threshold: 删除会议的人数阈值。
    会议在第二方加入后，任何一方推出后，如果剩余人数低于该阈值，就删除会议资源。
    `0` 表示不因与会方退出而删除会议。

方法
***********

删除会议
===============

.. function:: release(res_id)

  :param str res_id: 要删除的会议

开始播放声音文件
=================

.. function:: play_start(res_id, file, repeat=0)

  :param str res_id: 在该会议中开始放音

  :param str file: 要播放的文件名

    .. tip:: 使用 ``|`` 分隔的多文件名字符串，可以一次性的按顺序播放多个文件。

      如::

        play_start("your-conf-id", "1.wav|2.wav|3.wav")

  :param int repeat: 重复播放次数，默认为 `0` ，表示不重复播放。

停止播放声音文件
=================

.. function:: play_stop(res_id)

  :param str res_id: 停止该会议中的放音

开始录音
===============

.. function:: record_start(res_id, max_seconds, record_file, record_format)

  :param str res_id: 在该会议中开始录音。
  :param int max_seconds: 录音的最大时间长度，单位是秒。超过该事件，录音会出错，并结束。
  :param str record_file: 录音文件名。
  :param int record_format: 录音文件格式枚举值。见 :func:`sys.call.record_start` 的同名参数。

停止录音
===============

.. function:: record_stop(res_id)

  :param str res_id: 停止该会议中的录音。

改变与会者的声音收放模式
========================

.. function:: set_part_voice_mode(res_id, call_res_id, mode)

  :param str res_id: 要操作的会议资源的ID
  :param str call_res_id: 要改变模式的与会者的呼叫资源ID

  :param int mode: 录放音模式枚举值：

    ====== ========
    值     说明
    ====== ========
    ``1``  放音+收音
    ``2``  收音
    ``3``  放音
    ``4``  无
    ====== ========

事件
**************

会议被删除
============

.. function:: on_released(res_id， begin_time, end_time)

  :param str res_id: 触发事件的会议资源 `ID`。
  :param int begin_time: 该会议的开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
    如果会议没有被成功建立，该参数的值是 ``null``。
  :param int end_time: 该会议的结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。

文件放音结束
=============

.. function:: on_play_completed(res_id, begin_time, end_time)

  :param str res_id: 触发事件的会议资源 `ID`。
  :param int begin_time: 放音开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param int end_time: 放音结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。

录音结束
=============

.. function:: on_record_completed(res_id, begin_time, end_time)

  :param str res_id: 触发事件的会议资源 `ID`。
  :param int begin_time: 录音开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param int end_time: 录音束时间(:term:`CTI` 服务器的 :term:`Unix time`)。
