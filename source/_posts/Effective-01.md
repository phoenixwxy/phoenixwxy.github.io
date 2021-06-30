---
title:  Effective
time:  
tags: [learn,Program,Effective]
categories: program
---

# 让自己习惯C++

### 视C++为一个语言联邦

C++现在是一种多重泛型编程语言(multiparadigm programing language)，目前C++更像是多种语言的组合体

- 过程形式（procedural）
- 面向对象形式（object-oriented）
- 函数形式（functional）
- 泛型形式（generic）
- 元编程模式（metaprogramming）

所以在进行编写程序时可以使用不行的次语言守则：

1. C  使用C语言的高效编程，没有模板、异常、重载
2. Object-oriented C++ 面向对象设计
3. Template C++ 泛型编程
4. STL 使用标准库形式

<!-- more -->

### 尽量不使用 #define

单纯变量尽量以 const、enum、inline 来替换 #define 保证编译器能够记录所想定义的变量/数值

### 尽量使用const

const出现在 * 左边，表示被指物是常量；出现在 * 右边，表示指针本身是产量；如果出现在 * 两边，被指物和指针都是产量

##### const成员函数

##### 总结

- const可以帮助编译器检测错误用法

- 编译器实施强制 bitwise constness，但是编写程序时需要使用 “概念上的常量”

- 当const和non-const成员函数有着实质等价实现时，令non-const调用const版本可以避免代码重复



