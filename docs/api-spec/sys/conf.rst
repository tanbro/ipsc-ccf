会议 API
###########

.. module:: sys.conf

构造
***********

.. function:: construct(max_seconds, record_file, bg_file, parts_threshold)

  :param int max_seconds: 会议的最大允许时间，单位是秒。

  :param str record_file: 录音文件路径。会议创建后，自动将会议的录音存放到这个文件。

    :default: ``None`` 表示不录音

  :param str bg_file: 会议创建后，自动播放这个声音文件作为背景音。

    :default: ``None`` 表示无背景音

  :param int parts_threshold: 删除会议的人数阈值。
    会议在第二方加入后，任何一方推出后，如果剩余人数低于该阈值，就删除会议资源。

    .. warning::
      该参数必须大于等于0。如果传入参数小于0，会被转为绝对值。
      如果要修改这个值，应在会议资源创建后，调用 :func:`set_parts_threshold`

    eg:

      * ``1`` 表示：在成员退出后，如果还剩余最后一个成员，则解散会议。
      * ``0`` 表示：在成员退出后，如果没有剩余的成员了，则解散会议。

    :default: ``1``

  :return: 资源ID和IPSC相关信息。

    其格式结果(``result``)部分形如:

    .. code-block:: json

      {
        "res_id": "0.0.0-sys.conf-23479873432234",
        "user_data": "your user data",
        "ipsc_info": {
          "process_id": "23479873432234"
        }
      }

    .. important::
      在后续的资源操作 :term:`RPC` 中，应用服务需要使用 ``res_id`` 参数确定要操作的资源。

方法
***********

是否存在
===============
判断会议资源是否存在

.. function:: exists(res_id)

  :param str res_id: 判断ID为该值的会议资源是否存在
  :rtype: bool

.. tip::
  应用服务可以使用该函数，判断会议是否还在。
  在错过会议释放事件的情况下，该方法能用于消除“残留物”

获取与会方列表
================
返回会议当前与会方（处于会议中的呼叫）列表

.. function:: get_parts(res_id)

  :param str res_id: 会议资源ID

  :rtype: list
  :return: 会议资源ID为 ``res_id`` 的当前所属呼叫列表信息。

    该列表的数组元素是 :term:`JSON` `Object`，形如：

    .. code-block:: json

      [
        {
          "res_id": "0.0.0-sys.call-23479873432234",
          "voice_mode": 1,
          "user_data": "your user data"
        },
        {
          "res_id": "0.0.0-sys.call-67416434654464",
          "voice_mode": 1,
          "user_data": "your user data"
        }
      ]

    数组元素的的属性有：

    ================= ==========================================================
    属性               说明
    ================= ==========================================================
    ``res_id``        与会方（呼叫）的资源ID
    ``voice_mode``    成员的听说模式，见 :func:`set_part_voice_mode`
    ``user_data``     与会方（呼叫）的用户数据，来源于呼叫的构造函数
    ================= ==========================================================

删除会议
===============

.. function:: release(res_id)

  :param str res_id: 要删除的会议

开始播放
========

在会议中播放声音，会议中所有具有“听”模式的呼叫都可以听到。

.. function:: play_start(res_id, content, file="", is_loop=False)

  :param str res_id: 在该会议中开始放音

  :param content: 待播放内容

    .. versionadded:: 1.2.1b3

      用这个参数取代 ``file`` 参数。

    参数格式定义见 :func:`sys.call.play_start` 的同名参数

  :param str file: 要播放的文件名

    .. deprecated:: 1.3

      使用 ``content`` 参数，不要继续使用这个参数！

    .. tip:: 使用 ``|`` 分隔的多文件名字符串，可以一次性的按顺序播放多个文件。

      如::

        play_start("your-conf-id", "1.wav|2.wav|3.wav")

  :param bool is_loop: 是否循环播放。

    :default: `False` 不循环播放

停止播放
========

.. function:: play_stop(res_id)

  :param str res_id: 停止该会议中的放音

开始录音
===============

.. function:: record_start(res_id, max_seconds, record_file, record_format)

  :param str res_id: 在该会议中开始录音。

  :param int max_seconds: 录音的最大时间长度，单位是秒。超过该事件，录音会出错，并结束。

  :param str record_file: 录音文件名。

  :param int record_format: 录音文件格式枚举值。见 :func:`sys.call.record_start` 的同名参数。

    :default: `3`

  :rtype: str
  :return: 完整的录音文件路径。见 http://cf.liushuixingyun.com/pages/viewpage.action?pageId=1803077

停止录音
===============

.. function:: record_stop(res_id)

  :param str res_id: 停止该会议中的录音。

改变与会者的成员删除阈值
========================
.. function:: set_parts_threshold(res_id, value)

  :param int value: 见 :func:`construct` 的 ``parts_threadhold`` 参数

    .. note::
      此时，可以设置该值小于0。
      当阈值小于零时，即使会议中的呼叫全部退出，会议也不会解散，除非调用API解散，或者180秒之内没有新的呼叫加入。

  .. note:: 调用后，会议不会因阈值的改变而自动释放。只有当某个成员退出时，才会重新按照新的设置计算是否自动释放。

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

    :default: `1`

事件
**************

会议被删除
============

.. function:: on_released(res_id， begin_time, end_time, user_data)

  :param str res_id: 触发事件的会议资源 `ID`。
  :param int begin_time: 该会议的开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
    如果会议没有被成功建立，该参数的值是 ``null``。
  :param int end_time: 该会议的结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param str user_data: 用户数据，来源于 :func:`construct` 的 ``user_data`` 参数

文件放音结束
=============

.. function:: on_play_completed(res_id, begin_time, end_time, user_data)

  :param str res_id: 触发事件的会议资源 `ID`。
  :param int begin_time: 该录音的开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param int end_time: 该录音的结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param str user_data: 用户数据，来源于 :func:`construct` 的 ``user_data`` 参数

录音结束
=============

.. function:: on_record_completed(res_id, begin_time, end_time, record_file, user_data)

  :param str res_id: 触发事件的会议资源 `ID`。
  :param int begin_time: 该录音的开始时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param int end_time: 该录音的结束时间(:term:`CTI` 服务器的 :term:`Unix time`)。
  :param str record_file: 录音文件路径，与 :func:`record_start` 的 ``record_file`` 参数相同。
  :param str user_data: 用户数据，来源于 :func:`construct` 的 ``user_data`` 参数。
