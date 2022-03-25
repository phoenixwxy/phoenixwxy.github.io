---
title : MessageQueue
tags: [learn,Program,Android]
categories: [program,Android]
---

# Android MessageQueue



## 简介

Android的消息队列，用来存放Message对象的数据结构，采用“先进先出”的原则存放消息。



## CodeFollow

```cpp
// MessageQueue 继承自 MessageQueueBase
// MessageQueue 只实现了构造函数，具体逻辑实现在 MessageQueueBase里面
// 三个构造
// 传入需要操作的类型和 读/写, 第二个参数
MessageQueue(const Descriptor& Desc, bool resetPointers = true)
        : MessageQueueBase<MQDescriptor, T, flavor>(Desc, resetPointers) {}

// 使用共享内存实现
// numElementsInQueue是Queue的容量
// configureEventFlagWord表示是否未EventFlag分配和映射
MessageQueue(size_t numElementsInQueue, bool configureEventFlagWord,
                 android::base::unique_fd bufferFd, size_t bufferSize)
        : MessageQueueBase<MQDescriptor, T, flavor>(numElementsInQueue, configureEventFlagWord,
                                                    std::move(bufferFd), bufferSize) {}

MessageQueue(size_t numElementsInQueue, bool configureEventFlagWord = false)
        : MessageQueueBase<MQDescriptor, T, flavor>(numElementsInQueue, configureEventFlagWord,
                                                    android::base::unique_fd(), 0) {}
```


