会议 API
###########

.. module:: conf

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

.. function:: release()

开始播放声音文件
=================

.. function:: play_start(file: str)

停止播放声音文件
=================

.. function:: play_stop()

开始录音
===============

.. function:: record_start(record_file: str, finish_key: str)

停止录音
===============

.. function:: record_stop()

改变与会者的声音收放模式
========================

.. function:: set_part_voice_mode(call_res_id, mode)

  :param str call_res_id: 要改变模式的与会者的呼叫资源ID

  :param int mode: 要改变模式的与会者的呼叫资源ID

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

.. function:: on_released(res_id)

  :param str res_id: 触发事件的会议资源 `ID`。

文件放音结束
=============

.. function:: on_play_completed(res_id)

  :param str res_id: 触发事件的会议资源 `ID`。

录音结束
=============

.. function:: on_record_completed(res_id)

  :param str res_id: 触发事件的会议资源 `ID`。
