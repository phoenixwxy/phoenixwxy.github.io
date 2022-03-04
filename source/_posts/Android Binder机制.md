# Android Binder机制

## 概念

Binder是一种进程通信机制（IPC，Inter-Process Communication）。Google在Android上使用的Binder机制是基于[OpenBinder: Binder IPC Mechanism](http://www.angryredplanet.com/~hackbod/openbinder/docs/html/BinderIPCMechanism.html)来实现的。

在Android系统的Binder机制中，由一系列的系统组件构成：Client、Server、Service Manager和Binder驱动程序。其中Client、Server、Service Manager在用户空间，Binder驱动程序运行在内核空间。所以Binder通信就是Client-Server在Binder驱动和ServiceManager的基础上进行通信。

## Binder驱动


