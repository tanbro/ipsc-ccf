会议 API
###########

.. module:: conf

构造
***********

.. function:: construct(max_seconds, background_play_file, release_threshold)

  :param int max_seconds: 会议的最大允许时间，单位是秒。
  :param str background_play_file: 会议创建后，自动播放这个声音文件作为背景音。
  :param int release_threshold: 删除会议的人数阈值。
                                会议在第二方加入后，任何一方推出后，如果剩余人数低于该阈值，就删除会议资源。
                                `0` 表示不因与会方退出而删除会议。

方法
***********

删除会议
===============

.. function:: release(res_id)

  :param str res_id: 要操作的会议资源 `ID`。

开始播放声音文件
=================

.. function:: play_start(res_id, play_file: str)

  :param str res_id: 要操作的会议资源 `ID`。

停止播放声音文件
=================

.. function:: play_stop(res_id)

  :param str res_id: 要操作的会议资源 `ID`。

开始录音
===============

.. function:: record_start(res_id, record_file: str, finish_key: str)

  :param str res_id: 要操作的会议资源 `ID`。

停止录音
===============

.. function:: record_stop(res_id)

  :param str res_id: 要操作的会议资源 `ID`。

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

与会方加入
=============

.. function:: on_entered(res_id, call_res_id)

与会方退出
============

.. function:: on_exited(res_id, call_res_id)
