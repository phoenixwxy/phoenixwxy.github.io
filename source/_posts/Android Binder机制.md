---
title: Android Binder机制
time: 2022
tags: [learn,Program]
categories: [program]
---

# Android Binder机制

## 概念

<!-- more -->

Binder是一种进程通信机制（IPC，Inter-Process Communication）。Google在Android上使用的Binder机制是基于[OpenBinder: Binder IPC Mechanism](http://www.angryredplanet.com/~hackbod/openbinder/docs/html/BinderIPCMechanism.html)来实现的。

在Android系统的Binder机制中，由一系列的系统组件构成：Client、Server、Service Manager和Binder驱动程序。其中Client、Server、Service Manager在用户空间，Binder驱动程序运行在内核空间。所以Binder通信就是Client-Server在Binder驱动和ServiceManager的基础上进行通信。该结构使用了设计模式中的代理模式[代理模式](https://www.runoob.com/design-pattern/proxy-pattern.html)

![](Z:\workspace\code\Blog\phoenixwxy.github.io\source\_posts\android_pic.assets\binder_01.gif)

1. Client、Server和Service Manager实现在用户空间中，Binder驱动程序实现在内核空间中
2. Binder驱动程序和Service Manager在Android平台中已经实现，开发者只需要在用户空间实现自己的Client和Server
3. Binder驱动程序提供设备文件/dev/binder与用户空间交互，Client、Server和Service Manager通过open和ioctl文件操作函数与Binder驱动程序进行通信
4. Client和Server之间的进程间通信通过Binder驱动程序间接实现
5. Service Manager是一个守护进程，用来管理Server，并向Client提供查询Server接口的能力

## ServiceManager

ServiceManager用来管理Client和Server的通信，且三者属于不同进程；所以三者之间的通信都是Binder通信。所以ServiceManager在充当Binder的守护进程的时候，也在充当Server。

## Binder驱动

## 名词解释

```textile
BnBinder                        Binder Native
BpBInder                        Binder Proxy
```

# CodeFollow

```cpp

```
