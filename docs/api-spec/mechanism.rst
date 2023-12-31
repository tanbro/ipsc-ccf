实现原理
#########

资源与流程
**********
我们用 **资源**  的概念来描述 `API` 所操作的对象。 **流程** 是资源的执行过程。

在本系统中，目前总结出的资源有：

* 基础资源，包括:

  * 呼叫
  * 会议

* 扩展资源，包括：

  * 双向回拨
  * 通知外呼
  * 语音验证码

资源的生命周期如下图所示：

应用服务通过 :doc:`/cti-bus/index` 的客户端 `C API` 控制资源：

#. 应用服务创建资源是通过启动流程（调用函数 :c:func:`SmartBusNetCli_RemoteInvokeFlow` ）实现的。
#. 应用服务操作资源，包括普通操作和释放资源，是通过向流程发送订阅消息（调用函数 :c:func:`SmartBusNetCli_SendNotify` ）实现的。
#. 应用服务通过接收 :doc:`/cti-bus/index` 消息（使用回调函数 :c:func:`smartbus_cli_recvdata_cb` ）接收资源的创建、操作调用的结果和资源状态变化事件通知。

:term:`RPC` 形态
*******************
我们采用 **远程方法** (:term:`RPC`)的形式实现 :term:`CTI` 部分的 API：
资源的创建、操作、释放、变化都被抽象为 :term:`RPC`。

在本系统中，这些 :term:`RPC` 基本上采用 :term:`JSON` 格式

本文的 `API` 定义部分采用函数定义的格式，描述这些 :term:`RPC`

以下说明如何在 `IPSC` :doc:`/cti-bus/index` 体系中，利用其 `API` 实现 :term:`RPC` ，对资源进行访问和控制。

:term:`RPC` 实现
*******************

创建资源
=========

创建资源的 :term:`RPC` 请求
----------------------------
应用服务通过 :doc:`/cti-bus/index` 客户端库函数 :c:func:`SmartBusNetCli_RemoteInvokeFlow` 启动要创建的资源所对应的特定流程，该流程将管理对象的整个生命周期。

启动流程的过程相当于一次 :term:`RPC` 请求。此时，该函数的相关参数含义是：

=============== ================================================================
参数             说明
=============== ================================================================
local_clientid  应用服务使用其服务进程中 :doc:`/cti-bus/index` 客户端 ID 是该参数值的客户端发送命令。
server_unitid   `IPSC` 所在物理服务器的 :doc:`/cti-bus/index` 节点 ID。
ipscindex       `IPSC` 服务进程在该 :doc:`/cti-bus/index` 节点下的序号。
projectid       `IPSC` 流程项目 ID 。在 `CCF` 中，统一使用 ID 为 ``sys`` 的流程项目 。

flowid          使用不同的流程建立不同的资源。目前，流程 `ID` 和资源的对应关系是：

                ========== ===========
                流程 ID     资源
                ========== ===========
                ``call``    呼叫
                ``conf``    会议
                ========== ===========

mode            不需要流程返回执行结果，故该参数填写 ``1`` 。
timeout         不需要流程返回执行结果，故该参数无意义，填写 ``0`` 即可 。

in_valuelist    该参数格式是 :term:`JSON` `Array` ，字符串内容最大长度不超过32K字节。

                在创建资源时，将流程的启动视为一次相当于调用构造函数的 :term:`RPC` ，
                使用这个数组的前两个元素作为 :term:`RPC` 的标识(`id`)和参数(`params`)：

                ==== ====================================================
                序号 说明
                ==== ====================================================
                0.   :term:`RPC` 调用者的 :doc:`/cti-bus/index` 地址(``[Integer, Integer]``)。IPSC向这个地址回复执行结果。
                1.   :term:`RPC` 的 `id`: 应用服务应使用 :term:`UUID` 。
                2.   :term:`RPC` 的 `params`: 参数名=>参数值 键值对， :term:`JSON` `object` 格式。不同的资源创建方法具有不同的参数。具体情况请参考下文。
                ==== ====================================================

=============== ================================================================

创建资源的 :term:`RPC` 回复
---------------------------
当 `IPSC` 的资源创建流程被应用服务启动后，流程将资源创建的结果，无论成功还是失败，通过 :doc:`/cti-bus/index` 发送给应用服务。
这个过程被视作 :term:`RPC` 回复。

.. attention::
  应用服务等待 :term:`RPC` 回复时，应考虑以下异常情况的处理：

  #. 等待回复超时
  #. 回复的消息 ID 配对失败
  #. 回复的消息格式错误
  #. 回复的消息包含错误信息

应用服务通过 :doc:`/cti-bus/index` API 的回调函数 :c:type:`smartbus_cli_recvdata_cb` 接收该 :term:`RPC` 回复。

.. attention:: :doc:`/cti-bus/index` 服务会把该回复消息发送给发起此次“创建资源”请求的 :doc:`/cti-bus/index` 节点。

此时，该回调函数相关参数的含义是：

=============== =================================================================================================================
参数              说明
=============== =================================================================================================================
local_clientid  收到数据的客户端的ID。
head            数据包头，它包含消息的发送者的 :doc:`/cti-bus/index` 地址。
data            数据包体。我们使用这个参数，以 :term:`JSON` `object` 字符串格式，记录 :term:`RPC` 回复。
                当回复 **正常** 结果时，该参数的 :term:`JSON` `object` 属性有：

                ========== =========== ===============================================================================
                属性         数据类型        说明
                ========== =========== ===============================================================================
                ``id``     String      该回复所对应的请求的 `id` ，可用于消息的配对。
                ``result`` Object      资源创建 :term:`RPC` 返回结果，是一个 :term:`JSON` Object，
                                       其属性有：

                                       ============== =========== ====================================================
                                       属性            数据类型        说明
                                       ============== =========== ====================================================
                                       ``res_id``     String      属性对应于创建请求的 ``id`` ,
                                                                  在后续的资源操作 :term:`RPC` 中，
                                                                  应用服务需要使用该 `id` 指定要操作的资源。
                                       ``ipsc_info``  Object      IPSC(CTI 服务器)的资源相关信息，
                                                                  其中 `process_id` 是一个重要信息，
                                                                  它是一个长整形数据，应用服务 **必须** 把它记录到数据库。
                                       ============== =========== ====================================================

                ========== =========== ===============================================================================

                当回复 **错误** 结果时，该参数的 :term:`JSON` `object` 属性有：

                ========== =========== =====================================================
                属性         数据类型        说明
                ========== =========== =====================================================
                ``id``     String      该回复所对应的请求的 `id` ，可用于消息的配对。
                ``error``  Object      :term:`RPC` 错误信息。是一个 :term:`JSON` Object，
                                       其属性包括：

                                       ============ =========== ====================
                                       属性           数据类型        说明
                                       ============ =========== ====================
                                       ``code``     Integer     错误编码。必备属性。
                                       ``message``  String      错误描述。
                                       ``data``     Object      错误数据。它包括 ``ipsc_info`` 数据。
                                       ============ =========== ====================

                ========== =========== =====================================================

size            包体字节长度
=============== =================================================================================================================

创建资源的 :doc:`/cti-bus/index` API 实现举例
----------------------------------------------
在本例子中，通过调用 `call` 流程，进行一次对外呼叫，并接收呼叫资源的创建结果。

假设发出呼叫命令的应用服务其在 :doc:`/cti-bus/index` 节点中的客户端 `ID` 是 `1`，
执行实际的呼叫动作的 `IPSC` 进程所属 :doc:`/cti-bus/index` 节点 `ID` 是 `0`，
该 `IPSC` 进程的客户端序号是 `0` 。

1. 发出创建请求

  .. code-block:: c

    char in_valuelist[] = "[ \
        [5, 0], \
        \"b07ee20a378111e6a2c768f7288d9a79\", \
        { \
          \"from_uri\": \"123\", \
          \"to_uri\": \"456\", \
        } \
    ]";

    int err = SmartBusNetCli_RemoteInvokeFlow(
      1,      // 进行调用的本地BUS客户端id
      0,      // 目标IPSC服务器节点ID
      0,      // IPSC进程编号
      "sys",  // 流程项目ID
      "call", // 流程ID
      1,      // 调用模式, 1 表示不需要流程返回执行结果
      0,      // 流程返回执行结果时，此处无用
      &(in_valuelist[0])
    );

    if (err != 0) {
      printf("Error! Code=%d\n", err);
    }

2. 接收结果

  应用服务通过 :c:type:`smartbus_cli_recvdata_cb` 回调函数接收执行结果。
  如果长时间收不到结果，应认为执行超时，进行相应的错误处理。

  如果执行 **成功**，该回调函数的 ``data`` 参数值是 :term:`JSON` `object` 字符串，形如:

    .. code-block:: json

      {
        "id": "b07ee20a378111e6a2c768f7288d9a79",
        "result": {
          "res_id": "0.0.0-sys.call-23479873432234",
          "ipsc_info": {
              "process_id": "23479873432234"
          }
        }
      }


  应用服务通过资源 `ID` 进行对该资源的后续操作，以及接收该资源的状态变化事件。

  如果执行 **失败**，该回调函数的 ``data`` 参数值是 :term:`JSON` `object` 字符串，形如:

  .. code-block:: json

    {
      "id": "b07ee20a378111e6a2c768f7288d9a79",
      "error": {
        "code": 500,
        "message": "invalid number.",
        "data": {
          "ipsc_info": {
              "process_id": "23479873432234"
          }
        }
      }
    }

操作资源
==========
当资源被成功创建后，应用服务获得了资源 `ID` ，通过向 `IPSC` 的流程项目发送资源控制命令，操作资源。

.. note:: 资源的释放命令，如挂断呼叫，也是一种资源操作命令。

操作资源的 :term:`RPC` 请求
----------------------------

应用服务通过 :doc:`/cti-bus/index` 客户端库函数 :c:func:`SmartBusNetCli_SendNotify` 操作资源。

通过该 `API` 发送该消息的过程相当于一次 :term:`RPC` 请求。此时，该函数的相关参数含义是：

=============== ================================================================
参数             说明
=============== ================================================================
local_clientid  应用服务使用其服务进程中 :doc:`/cti-bus/index` 客户端 ID 是该参数值的客户端发送命令。
server_unitid   `IPSC` 所在物理服务器的 :doc:`/cti-bus/index` 节点 ID。
ipscindex       `IPSC` 服务进程在该 :doc:`/cti-bus/index` 节点下的序号。
projectid       `IPSC` 流程项目 ID 。在 `CCF` 中，统一使用 ID 为 ``sys`` 的流程项目 。
title           `IPSC` 的资源流程在其整个生命周期内，持续监听向该资源 `ID` 发送的通知消息。
                **该参数填写要操作的资源的 ID** ，即可将控制命令发送给资源所对应的流程实例。
mode            该参数无意义，填写 ``0`` 即可 。
expires         消息有效时间长度，单位是毫秒。由于流程在异步事件队列中运行，它在处理IO和监听消息时，有一定延时。
                必须提供一个足够长的时间，等待流程处理。建议的值是 `5` 秒。

param           该参数格式是 :term:`JSON` `Array` ，字符串内容最大长度不超过32K字节。

                在操作资源时，将这个通知消息视为 :term:`RPC` 的调用数据，
                使用这个数组的第2~4个元素作为 :term:`RPC` 的标识(`id`)，方法名(`method`)和参数(`params`)：

                ==== ====================================================
                序号 说明
                ==== ====================================================
                0.   :term:`RPC` 调用者的 :doc:`/cti-bus/index` 地址(``[Integer, Integer]``)。IPSC向这个地址回复执行结果。
                1.   :term:`RPC` 的 `id`: 应用服务应使用 :term:`UUID` 。
                2.   :term:`RPC` 的 `method`：方法名。
                3.   :term:`RPC` 的 `params`: 参数名=>参数值 键值对， :term:`JSON` `object` 格式。不同的资源创建方法具有不同的参数。具体情况请参考下文。
                ==== ====================================================

=============== ================================================================

操作资源的 :term:`RPC` 回复
----------------------------
当 `IPSC` 的流程收到资源操作命令后，应尽可能快的返回 :term:`RPC` 回复数据。

.. attention::
  应用服务等待 :term:`RPC` 回复时，应考虑以下异常情况的处理：

  #. 等待回复超时
  #. 回复的消息 ID 配对失败
  #. 回复的消息格式错误
  #. 回复的消息包含错误信息

应用服务通过 :doc:`/cti-bus/index` API 的回调函数 :c:type:`smartbus_cli_recvdata_cb` 接收该 :term:`RPC` 回复。

.. attention:: :doc:`/cti-bus/index` 服务会把该回复消息发送给发起此次“操作资源”请求的 :doc:`/cti-bus/index` 节点。

此时，该回调函数相关参数的含义是：

=============== ===========================================================================================
参数              说明
=============== ===========================================================================================
local_clientid  收到数据的客户端的ID。
head            数据包头，它包含消息的发送者的 :doc:`/cti-bus/index` 地址。
data            数据包体。我们使用这个参数，以 :term:`JSON` `object` 字符串格式，记录 :term:`RPC` 回复。

                当回复 **正常** 结果时，该参数的 :term:`JSON` `object` 属性有：

                ========== =========== ============================================
                属性         数据类型        说明
                ========== =========== ============================================
                ``id``     String      该回复所对应的请求的 `id` ，可用于消息的配对。
                ``result`` Any         :term:`RPC` 返回值。不同的资源操作方法具有不同的返回值。具体情况请参考下文。
                ========== =========== ============================================

                当回复 **错误** 结果时，该参数的 :term:`JSON` `object` 属性有：

                ========== =========== =====================================================
                属性         数据类型        说明
                ========== =========== =====================================================
                ``id``     String      该回复所对应的请求的 `id` ，可用于消息的配对。
                ``error``  Object      :term:`RPC` 错误信息。是一个 :term:`JSON` `object` ，
                                       其属性包括：

                                       ============ =========== ====================
                                       属性           数据类型        说明
                                       ============ =========== ====================
                                       ``code``     Integer     错误编码。必备属性。
                                       ``message``  String      错误描述。可选属性。
                                       ``data``     Any         错误数据。可选属性。
                                       ============ =========== ====================

                ========== =========== =====================================================

=============== ===========================================================================================

操作资源的 :doc:`/cti-bus/index` API 实现举例
---------------------------------------------
在本例子中，通过向已知ID的呼叫资源发送通知消息，挂断正在进行的呼叫，并接收呼叫资源的创建结果。

假设发出呼叫命令的应用服务其在 CTI 总线 节点中的客户端 ID 是 1，
执行实际的呼叫动作的 IPSC 进程所属 CTI 总线 节点 ID 是 0，
该 IPSC 进程的客户端序号是 0 ,
要操作的呼叫的资源ID是 ``0-0-call-23479873432234``。

1. 发出请求

  .. code-block:: c

    char params[] = "[ \
        [5, 0], \
        \"52008e82378211e6ba3668f7288d9a79\", \
        \"ivr.call.drop\" \
        { \
          \"cause\": 200 \
        } \
    ]";

    int err = SmartBusNetCli_SendNotify(
      1,      // 进行调用的本地BUS客户端id
      0,      // 目标IPSC服务器节点ID
      0,      // IPSC进程编号
      "sys",  // 流程项目ID
      "0-0-call-23479873432234", // 资源 ID
      0,      // 调用模式, 无用
      5000,   // 该消息保留5秒，等待流程接收
      &(params[0])
    );

    if (err != 0) {
      printf("Error! Code=%d\n", err);
    }

2. 接收结果

   与创建资源时完全一致，不再累述。

资源事件
==============
资源事件的通知与创建资源以及操作资源的控制方向相反：它是由 `IPSC` 发起，应用服务接收的。
在本系统中，目前的设计不需要应用服务对 `IPSC` 抛出的资源事件进行回复，所以，资源事件是不需要回复的（单程票） :term:`RPC` 。

应用服务通过 CTI 总线 API 的回调函数 :c:type:`smartbus_cli_recvdata_cb` 接收该资源事件。

.. note::
  除了“新的呼入呼叫”事件，有关于某个资源的所有事件通知，都将被发送到“创建”这资源的 :doc:`/cti-bus/index` 节点。

此时，该回调函数相关参数的含义是：

=============== ===========================================================================================
参数              说明
=============== ===========================================================================================
local_clientid  收到数据的客户端的ID。
head            数据包头，它包含消息的发送者的 :doc:`/cti-bus/index` 地址。
data            数据包体。我们使用这个参数，以 :term:`JSON` `object` 字符串格式，记录 :term:`RPC` 回复。

                当回复 **正常** 结果时，该参数的 :term:`JSON` `object` 属性有：

                ========== =========== =========================================================
                属性         数据类型        说明
                ========== =========== =========================================================
                ``method`` String      事件的方法名。
                ``params`` Object      事件参数，采用 :term:`JSON` `object` 的 参数名=>参数值 键值对
                ========== =========== =========================================================

size            包体字节长度
=============== ===========================================================================================

举例：

如果 ``data`` 参数是：

.. code-block:: json

  {
    "method": "ivr.call.on_answered",
    "params": {
      "res_id": "0.0.0-sys.call-23479873432234"
    }
  }

该事件表明资源 `ID` 为 ``0-0-call-23479873432234`` 的呼叫被接听。

:term:`RPC` 文档书写格式说明
******************************
为了更简便的书写此种 :term:`RPC` 的定义文档，我们采用类似函数定义的方式进行描述，
而不是具体描述如何使用 :doc:`/cti-bus/c-api` 。

本文的 :term:`CTI` `API` 定义采用 ``<名称空间>.<资源名>.<函数名>`` 的格式。
其中，函数名对应于资源操作命令。
作为特殊的操作，创建命令的函数名一律被描述为 ``construct``

资源创建 :term:`RPC`
====================
资源创建 :term:`RPC` 被书写成以下形式::

  <namespace>.<resource>.construct([params])

如::

  sys.call.construct(to_uri: str, from_uri: str) -> str

或::

  sys.call.construct(to_uri, from_uri)

他们都表示表示新建一个 ``call`` 资源的接口。
该接口的实现方法是：调用 :c:func:`SmartBusNetCli_RemoteInvokeFlow` ，启动 `ID` 为 ``call`` 的流程。

资源操作 :term:`RPC`
====================
资源操作 :term:`RPC` 被书写成以下形式::

  <namespace>.<resource>.<method>([params])

如::

  sys.call.drop(res_id: str, reason: int)

或::

  sys.call.drop(res_id, reason)

他们都表示对指定的 ``call`` 资源进行挂断的接口。
该接口的实现方法是：调用 :c:func:`SmartBusNetCli_SendNotify` ，向指定的流程发送命令。

.. attention::
  所有的资源操作 :term:`RPC` 在调用 :c:func:`SmartBusNetCli_SendNotify` 时，
  **必须** 使用 ``title`` 参数传入要操作的资源的 `ID` 。
  在 `CTI API` 定义文档中，该参数是资源操作方法的 ``res_id`` 参数。

资源事件 :term:`RPC`
====================
资源操作 :term:`RPC` 被书写成以下形式::

  <namespace>.<resource>.<event>([params])

如::

  sys.call.on_answered(res_id: str)

或::

  sys.call.on_answered(res_id)

.. note::
  事件 :term:`RPC` 通常将资源 `ID` 写在第一个参数 ``res_id`` 中，

.. warning::
  事件 :term:`RPC` 的方向与其它 :term:`RPC` 相反，它是 `IPSC` 发起的！
