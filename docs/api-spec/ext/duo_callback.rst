双向回拨 API
#############

.. module:: ext.duo_callback

构造
==========

.. function::
  construct(from1_uri, to1_uri, from2_uri, to2_uri, max_answer_seconds, max_ring_seconds, ring_play_file, ring_play_mode, record_file, user_data)

  :param str form1_uri: 第一方主叫号码 :term:`SIP URI`
  :param str to1_uri: 第一方被叫号码 :term:`SIP URI`
  :param str form2_uri: 第二方主叫号码 :term:`SIP URI`
  :param str to2_uri: 第二方被叫号码 :term:`SIP URI`
  :param int max_answer_seconds:
  :param int max_ring_seconds:
  :param str ring_play_file:

  :param int ring_play_mode:



  :param str record_file:
  :param str user_data:
