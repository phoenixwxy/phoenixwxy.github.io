---
title:  zlog
time:  2020-08-10 14:47
tags: C
categories: 编程
---

# zlog

## 简介

[zlog详细页面](http://hardysimpson.github.io/zlog/UsersGuide-CN.html)

zlog是一个高可靠性、高性能、线程安全、灵活、概念清晰的纯C日志函数库。

<!-- more -->

zlog有这些特性：

- syslog分类模型，比log4j模型更加直接了当
- 日志格式定制，类似于log4j的pattern layout
- 多种输出，包括动态文件、静态文件、stdout、stderr、syslog、用户自定义输出函数
- 运行时手动、自动刷新配置文件（同时保证安全）
- 高性能，在我的笔记本上达到25万条日志每秒, 大概是syslog(3)配合rsyslogd的1000倍速度
- 用户自定义等级
- 多线程和多进程环境下保证安全转档
- 精确到微秒
- 简单调用包装dzlog（一个程序默认只用一个分类）
- MDC，线程键-值对的表，可以扩展用户自定义的字段
- 自诊断，可以在运行时输出zlog自己的日志和配置状态
- 不依赖其他库，只要是个POSIX系统就成(当然还要一个C99兼容的vsnprintf)

## 下载安装

[Github地址](https://github.com/HardySimpson/zlog)

将源码下载下来后，进入对应目录

```shell
make && make install
```

从MakeFile中可看到，默认是安装到 `/usr/local`，可以修改 makefile里面的 `PREFIX?=xxxx` 来改变安装路径

## 使用

在自己的需要调用的源码文件中调用

```c
#include "zlog.h"
```

链接zlog库是需要使用pthread库，简要命令如下：

```shell
cc -c -o app.o app.c -I/usr/local/include
cc -o app app.o -L/usr/local/lib -lzlog -lpthread
```

## 配置文件

zlog在使用过程中最需要，也是最急切需要知道就是配置文件，但是网上存在教程都是zlog文档中自带的，并不是100%是使用者需要的。

zlog里面有三个重要的概念,category,format，rule

分类(Category)用于区分不同的输入，代码中的分类变量的名字是一个字符串，在一个程序里面可以通过获取不同的分类名的category用来后面输出不同分类的日志，用于不同的目的。

格式(Format)是用来描述输出日志的格式，比如是否有带有时间戳， 是否包含文件位置信息等，上面的例子里面的格式simple就配置成简单的用户输入的信息+换行符。

规则(Rule)则是把分类、级别、输出文件、格式组合起来，决定一条代码中的日志是否输出，输出到哪里，以什么格式输出。简单而言，规则里面的分类字符串和代码里面的分类变量的名字一样就匹配，当然还有更高级的纲目分类匹配。规则彻底解耦了各个元素之间的强绑定，例如log4j就必须为每个分类指定一个级别（或者从父分类那里继承），这在多层系统需要每一层都有自己的级别要求的时候非常不方便

```shell
# []代表一个节的开始，四个小节的顺序不能变，依次为global-levels-formats-rules
[global]				# 全局参数
# 如果"strict init"是true，zlog_init()将会严格检查所有的格式和规则，
# 任何错误都会导致zlog_init() 失败并且返回-1。当"strict init"是false的时候，
# zlog_init()会忽略错误的格式和规则。 这个参数默认为true。
strict init = true
# 这个选项让zlog能在一段时间间隔后自动重载配置文件。重载的间隔以每进程写日志的次数来定义。
# 当写日志次数到了一定值后，内部将会调用zlog_reload()进行重载。
# 每次zlog_reload()或者zlog_init()之后重新计数累加。
# 因为zlog_reload()是原子性的，重载失败继续用当前的配置信息，所以自动重载是安全的。
# 默认值是0，自动重载是关闭的。
# reload conf period
# zlog在堆上为每个线程申请缓存。"buffer min"是单个缓存的最小值，zlog_init()的时候申请这个长度的内存。
# 写日志的时候，如果单条日志长度大于缓存，缓存会自动扩充，直到到"buffer max"。 
# 单条日志再长超过"buffer max"就会被截断。
# 如果 "buffer max" 是 0，意味着不限制缓存，每次扩充为原先的2倍，直到这个进程用完所有内存为止。
# 缓存大小可以加上 KB, MB 或 GB这些单位。默认来说"buffer min"是 1K ， "buffer max" 是2MB。
buffer min = 1024
buffer max = 2MB
# 这个选项指定了一个锁文件，用来保证多进程情况下日志安全转档。
# zlog会在zlog_init()时候以读写权限打开这个文件。确认你执行程序的用户有权限创建和读写这个文件。
rotate lock file = /tmp/zlog.lock
# 这个参数是缺省的日志格式，默认值为："%d %V [%p:%F:%L] %m%n"
default format = "%d.%us %-6V (%c:%F:%L) - %m%n"

file perms = 600

 

[levels]

TRACE = 10

CRIT = 130, LOG_CRIT

 

[formats]

simple = "%m%n"

normal = "%d %m%n"

 

[rules]

default.*               >stdout; simple

*.*                     "%12.2E(HOME)/log/%c.log", 1MB*12; simple

my_.INFO                >stderr;

my_cat.!ERROR           "/var/log/aa.log"

my_dog.=DEBUG           >syslog, LOG_LOCAL0; simple

my_mice.*               $user_define;
```

```shell
1k => 1000 bytes 
1kb => 1024 bytes 
1m => 1000000 bytes 
1mb => 1024*1024 bytes
1g => 1000000000 bytes 
1gb => 1024*1024*1024 byte
```

