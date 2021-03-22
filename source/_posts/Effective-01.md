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

### 尽量不使用 #define

尽量以 const、enum、inline 来替换 #define 保证编译器能够记录所想定义的变量/数值

