语音验证码
#############

.. module:: ext.captcha_call

状态
**********

当 :term:`CTI` 服务器收到 :doc:`/api-spec/ext/captcha_call` 指令后，就会尝试新建一个 `语音验证码` 资源，并返回资源 ID，其状态变化描述如下：

* 当资源被创建后，被叫尚未被呼通，处于初始状态(``Initiated``)。

* 等待外呼的结果

  * 如果呼叫成功，状态变为 ``Answered``，开始播放提示音，并接收按键码。
  * 如果呼叫失败，资源将被释放，状态变为 ``Released``。

.. graphviz::

  digraph CallResourceState {

    Start [shape=point, color=blue, fontcolor=blue];
    Initiated [color=blue, fontcolor=blue];
    Released [shape=doublecircle, color=red, fontcolor=red];

    Start -> Initiated [label="启动"];
    Initiated -> Answered [label="呼叫成功"]
    Initiated -> Released [color=red];

    Answered -> Released [color=red];
  }

构造
************

.. function::
  construct(from_uri, to_uri, max_ring_seconds, valid_keys="0123456789*#ABCD", max_keys=11, finish_keys="#", first_key_timeout=45, continues_keys_timeout=30, play_content=null, play_repeat=0, breaking_on_key=True, including_finish_key=False, user_data=None)

  :param str from_uri: 主叫号码 :term:`SIP URI`。

    主叫号码隐藏功能可通过该参数的不同赋值实现。

    .. attention:: 不是每个主叫号码都能被 VoIP 网关的外呼线路接受！

  :param str to_uri: 被叫号码 :term:`SIP URI`。

    应用服务需要通过该参数的 `user` 部分指定被叫号码，该参数 `address` 部分指定目标 `VoIP` 网关

  :param int max_ring_seconds: 外呼时，收到对端振铃后，最大等待时间。振铃超过这个时间，则认为呼叫失败。

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
      * 如果 ``including_finish_key`` 参数值是 `False` (默认情况)，该结束码字符 **不会** 被包含在 :func:`on_released` 的 ``keys`` 参数中。
      * 如果 ``including_finish_key`` 参数值是 `True` ，该结束码将被包含在 :func:`on_released` 的 ``keys`` 参数中。

  :param int first_key_timeout: 等待接收第一个 :term:`DTMF` 码的超时时间（秒）。
    如果在这段时间内，没有收到第一个 :term:`DTMF` 码，则进行超时处理。
  :param int continues_keys_timeout: 等待接收后续 :term:`DTMF` 码的超时时间（秒）。
    如果在这段时间内，没有收到后续 :term:`DTMF` 码，则进行超时处理。

  :param play_content: 提示音。在接收过程开始时，要播放的声音内容。

    该参数格式定义见 :func:`sys.call.play_start` 的 `content` 参数

  :type play_content: str, list

  :param int play_repeat: 如果出现等待超时，按照该参数重复播放提示音。
  :param bool breaking_on_key: 是否在接收到第一个有效 :term:`DTMF` 码时停止放音。
  :param bool including_finish_key: 是否将结束码包含在接收码串中。

  :param str user_data: 应用服务自定义数据，可用于 `CDR` 标识。

  :return: 资源ID和IPSC相关信息。

    其格式结果(``result``)部分形如:

    .. code-block:: json

      {
        "res_id": "0.0.0-ext.captcha_call-23479873432234",
        "ipsc_info": {
          "process_id": 23479873432234
        }
      }

    .. important::
      在后续的资源操作 :term:`RPC` 中，应用服务需要使用 ``res_id`` 参数确定要操作的资源。

事件
*********

结束
===========

.. function:: on_released(res_id, error, begin_time, answer_time, end_time, dropped_by, keys, user_data)
