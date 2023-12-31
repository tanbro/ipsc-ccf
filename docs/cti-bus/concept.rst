概念
#####

特点
*****
:term:`CTI` 总线(`CTI Bus`)是 `IPSC` 体系中的局域网数据总线。它的主要特点可被称作 ``MANS`` :

* Multiple Nodes: 多节点。每一台运行 :term:`CTI` 服务的物理机都是一个总线服务器，这台物理服务器上 `IPSC` 服务程序是它的客户端（节点）。
  应用服务进程作为结点加入到总线体系，同一个节点下的客户端可以连接不同的总线服务器。
  不同的总线服务器可以互相访问；不同总线服务器上的客户端只能通过它之间连接的服务器，方可访问到其它服务器和连接接到其它服务器的客户端。
* Asynchronous IO: 采用异步通信机制，无论服务器还是客户端。
* Native Client: 客户端通过 `BUS` 原生 `Library` 进行编程开发。(只有 `linux x86_64 gcc`)
* Star Topology: 星型连接。应用服务可连接到多个节点服务器，对多个 `IPSC` 服务进行控制。

三级地址机制
************
总线采用三级地址机制，这三级地址，从大到小分别是：

#. 节点ID：
   一个总线客户端进程就是一个节点，它在整个总线体系中的节点ID必须全局唯一。
#. 客户端ID：
   连接到某个总线服务器的客户端，在该总线服务器内的ID。一个节点可以拥有多个客户端。节点内的客户端ID不能重复，但是不同节点中的客户端ID可以重复。
#. 客户端类型ID。

.. attention::
  实际上，前两个地址部分已经可以确定精确的总线节点地址。客户端类型主要用于一次性向多个具有相同类型ID的节点发送数据。

流程
************
`IPSC` 是按照 `流程` 的定义执行的。流程是一系列 `XML` 文档，它规定了 `IPSC` 的程序逻辑。
应用服务开发者可将 `流程` 视作普通的函数。

流程通常是一个物理的 :term:`CTI` 对象的启动过程和生命周期，如：呼叫、电话会议。

应用服务通过 :doc:`c-api` 启动流程，以及从流程得到数据。

多进程
**********
一个运行 `IPSC` 服务的物理服务器上，运行有一个 :doc:`/cti-bus/index` 服务（一个节点）。
每个 `IPSC` 进程分别是该节点下的一个总线客户端。
在 `API` 中，我们用 `IPSC` 进程在该节点中的序号来访问不同的进程。

.. warning::
  呼叫、会议资源（包括其它任何资源）在不同的 `IPSC` 进程中是隔离的！
  例如，只有同一个进程中的呼叫，才可以加入到同一个会议，这个会议也必须是属于同一个进程的！
