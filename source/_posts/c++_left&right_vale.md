---
title: c++ 左值右值
time:  
tags: [learn,Program，c++]
categories: program
---

# c++左值右值

<!-- more -->

## 定义

**左值**：一个值在表达式的位置位于左侧 或理解为”可以取地址、有名字的值“

**右值**：一个值在表达式的位置位于右侧 或理解为”**不**可以取地址、**没有**名字的值“

1. xvalue

    Expiring Value 即将死亡的值 ----------  右值应用

2. prvalue

    Rure Right Value 纯粹的右值

    比如函数返回的临时变量值、字面量值以及 Lambda 表达式等等

**右值引用**：对右值的一个引用， 使用 "&&"

下面这个 int_number代表一个 *整形***临时**值的**右值引用类型**

```c++
int &&int_number = 10;
```

- 使用场景

    使用基于右值引用的语义转移，可以使我们在复制具有大块内存空间的对象时可以直接使用原对象已经分配好的内存空间进而省去重新分配内存空间的过程，因此某种程度上来讲，可以在一定条件下提升应用的运行效率。







[网址](https://www.jianshu.com/p/b90d1091a4ff)

下文先从C++11引入的几个规则，如引用折叠、右值引用的特殊类型推断规则、static_cast的扩展功能说起，然后通过例子解析std::move和std::forward的推导解析过程，说明std::move和std::forward本质就是一个转换函数，std::move执行到右值的无条件转换，std::forward执行到右值的有条件转换，在参数都是右值时，二者就是等价的。其实std::move和std::forward就是在C++11基本规则之上封装的语法糖。

## 1 引入的新规则

规则1（引用折叠规则）：如果间接的创建一个引用的引用，则这些引用就会“折叠”。在所有情况下（除了一个例外），引用折叠成一个普通的左值引用类型。一种特殊情况下，引用会折叠成右值引用，即右值引用的右值引用， T&& &&。即

- X& &、X& &&、X&& &都折叠成X&
- X&& &&折叠为X&&

规则2（右值引用的特殊类型推断规则）：当将一个左值传递给一个参数是右值引用的函数，且此右值引用指向模板类型参数(T&&)时，编译器推断模板参数类型为实参的左值引用，如



```cpp
template<typename T> 
void f(T&&);

int i = 42;
f(i)
```

上述的模板参数类型T将推断为int&类型，而非int。

> 若将规则1和规则2结合起来，则意味着可以传递一个左值`int i`给f，编译器将推断出T的类型为int&。再根据引用折叠规则 void f(int& &&)将推断为void f(int&)，因此，f将被实例化为: void f<int&>(int&)。

> 从上述两个规则可以得出结论：**如果一个函数形参是一个指向模板类型的右值引用，则该参数可以被绑定到一个左值上**，即类似下面的定义：



```cpp
template<typename T> 
void f(T&&);
```

规则3：虽然不能隐式的将一个左值转换为右值引用，但是可以通过static_cast显示地将一个左值转换为一个右值。【C++11中为static_cast新增的转换功能】。

## 2 std::move

### 2.1 std::move的使用



```cpp
class Foo
{
public:
    std::string member;

    // Copy member.
    Foo(const std::string& m): member(m) {}

    // Move member.
    Foo(std::string&& m): member(std::move(m)) {}
};
```

上述`Foo(std::string&& member)`中的member是rvalue reference，但是member却是一个左值lvalue，因此在初始化列表中需要使用std::move将其转换成rvalue。

### 2.2 std::move()解析

标准库中move的定义如下：



```cpp
template<typename T>
typename remove_reference<T>::type && move(T&& t)
{
    return static_cast<typename remove_reference<T>::type &&>(t);
}
```

- move函数的参数T&&是一个指向模板类型参数的右值引用【规则2】，通过引用折叠，此参数可以和任何类型的实参匹配，因此move既可以传递一个左值，也可以传递一个右值；
- std::move(string("hello"))调用解析：
    - 首先，根据模板推断规则，确地T的类型为string;
    - typename remove_reference<T>::type && 的结果为 string &&;
    - move函数的参数类型为string&&;
    - static_cast<string &&>(t)，t已经是string&&，于是类型转换什么都不做，返回string &&;
- string s1("hello"); std::move(s1); 调用解析：
    - 首先，根据模板推断规则，确定T的类型为string&;
    - typename remove_reference<T>::type && 的结果为 string&
    - move函数的参数类型为string& &&，引用折叠之后为string&;
    - static_cast<string &&>(t)，t是string&，经过static_cast之后转换为string&&, 返回string &&;

> 从move的定义可以看出，move自身除了做一些参数的推断之外，返回右值引用本质上还是靠static_cast<T&&>完成的。

因此下面两个调用是等价的，std::move就是个语法糖。



```cpp
void func(int&& a)
{
    cout << a << endl;
}

int a = 6;
func(std::move(a));

int b = 10;
func(static_cast<int&&>(b)); 
```

std::move执行到右值的无条件转换。就其本身而言，它没有move任何东西。

## 3 std::forward()

### 3.1 完美转发

> 完美转发实现了参数在传递过程中保持其值属性的功能，即若是左值，则传递之后仍然是左值，若是右值，则传递之后仍然是右值。

> C++11 lets us perform perfect forwarding, which means that we can forward the parameters passed to a function template to another function call inside it without losing their own qualifiers (const-ref, ref, value, rvalue, etc.).

### 3.2 std::forward()解析

std::forward只有在它的参数绑定到一个右值上的时候，它才转换它的参数到一个右值。



```cpp
class Foo
{
public:
    std::string member;

    template<typename T>
    Foo(T&& member): member{std::forward<T>(member)} {}
};
```

传递一个lvalue或者传递一个const lvaue

- 传递一个lvalue，模板推导之后 `T = std::string&`
- 传递一个const lvaue, 模板推导之后`T = const std::string&`
- `T& &&`将折叠为T&，即`std::string& && 折叠为 std::string&`
- 最终函数为: `Foo(string& member): member{std::forward<string&>(member)} {}`
- std::forward<string&>(member)将返回一个左值，最终调用拷贝构造函数

传递一个rvalue

- 传递一个rvalue，模板推导之后 `T = std::string`
- 最终函数为: `Foo(string&& member): member{std::forward<string>(member)} {}`
- std::forward<string>(member) 将返回一个右值，最终调用移动构造函数；

std::move和std::forward本质都是转换。std::move执行到右值的无条件转换。std::forward只有在它的参数绑定到一个右值上的时候，才转换它的参数到一个右值。

std::move没有move任何东西，std::forward没有转发任何东西。在运行期，它们没有做任何事情。它们没有产生需要执行的代码，一byte都没有。

## 4 std::move()和std::forward()对比

- std::move执行到右值的无条件转换。就其本身而言，它没有move任何东西。
- std::forward只有在它的参数绑定到一个右值上的时候，它才转换它的参数到一个右值。
- std::move和std::forward只不过就是执行类型转换的两个函数；std::move没有move任何东西，std::forward没有转发任何东西。在运行期，它们没有做任何事情。它们没有产生需要执行的代码，一byte都没有。
- std::forward<T>()不仅可以保持左值或者右值不变，同时还可以保持const、Lreference、Rreference、validate等属性不变；

## 5 一个完整的例子



```cpp
#include <iostream>
#include <type_traits>
#include <typeinfo>
#include <memory>
using namespace std;

struct A
{
    A(int&& n)
    {
        cout << "rvalue overload, n=" << n << endl;
    }
    A(int& n)
    {
        cout << "lvalue overload, n=" << n << endl;
    }
};

class B
{
public:
    template<class T1, class T2, class T3>
    B(T1 && t1, T2 && t2, T3 && t3) :
        a1_(std::forward<T1>(t1)),
        a2_(std::forward<T2>(t2)),
        a3_(std::forward<T3>(t3))
    {

    }
private:
    A a1_, a2_, a3_;
};

template <class T, class U>
std::unique_ptr<T> make_unique1(U&& u)
{
    //return std::unique_ptr<T>(new T(std::forward<U>(u)));
    return std::unique_ptr<T>(new T(std::move(u)));
}

template <class T, class... U>
std::unique_ptr<T> make_unique(U&&... u)
{
    //return std::unique_ptr<T>(new T(std::forward<U>(u)...));
    return std::unique_ptr<T>(new T(std::move(u)...));
}

int main()
{
    auto p1 = make_unique1<A>(2);

    int i = 10;
    auto p2 = make_unique1<A>(i);

    int j = 100;
    auto p3 = make_unique<B>(i, 2, j);
    return 0;
}
```