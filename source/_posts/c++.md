---
title: C++
time: 2022
tags: [learn,Program]
categories: [program]
---

# c++

[TOC]

<!-- more -->

## 关键字

alignas (since C++11)
alignof (since C++11)
and
and_eq
asm
atomic_cancel (TM TS)
atomic_commit (TM TS)
atomic_noexcept (TM TS)
auto (1)
bitand
bitor
bool
break
case
catch
char
char8_t (since C++20)
char16_t (since C++11)
char32_t (since C++11)
class (1)
compl
concept (since C++20)
const
consteval (since C++20)

### constexpr (since C++11)

指定变量或函数的值可以在[常量表达式](https://zh.cppreference.com/w/cpp/language/constant_expression "cpp/language/constant expression")中出现

constinit (since C++20)

### const_cast

**const_cast<type> (expr)**

用于修改类型的 const / volatile 属性。除了 const 或 volatile 属性之外，目标类型必须与源类型相同。这种类型的转换主要是用来操作所传对象的 const 属性，可以加上 const 属性，也可以去掉 const 属性。continue
co_await (since C++20)
co_return (since C++20)
co_yield (since C++20)

### decltype (since C++11)

检查实体的声明类型，或表达式的类型和值类别。

对于变量，指定要从其初始化器自动推导出其类型。

1. 如果实参是没有括号的标识表达式或没有括号的类成员访问表达式，decltype产生以表达式命名的实体的类型，如果没有这种实体或实参指明了一组重载函数，那么程序非良构（重载函数，编译报错）。

2. 如果实参是其他类型为T的任何表达式，且
   
   1. 如果表达式的值类别是**亡值**，将会 decltype 产生 T&& (右值)
   
   2. 如果表达式的值类别是**左值**，将会 decltype 产生 T& (左值)
   
   3. 如果表达式的值类别是**纯右值**，将会 decltype 产生 T 

```cpp
int i = 4;
decltype(i) a; // a is int

using size_t = decltype(sizeof(0))    // sizeof(a) return type is size_t

// auto return type
template <typename _Tx, typename _Ty>
auto multiply(_Tx x, _Ty y)->decltype(_Tx*_Ty)
{
    return x*y;
}
```

default (1)
delete (1)
do
double

### dynamic_cast

**dynamic_cast<type> (expr):**

可以安全的将父类转化为子类，子类转化为父类都是安全的。所以你可以用于安全的将基类转化为继承类，而且可以知道是否成功，如果强制转换的是指针类型，失败会返回NULL指针，如果强制转化的是引用类型，失败会抛出异常。dynamic_cast 转换符只能用于含有虚函数的类。

运行时执行转换，验证转换的有效性。如果转换未执行，则转换失败，表达式 expr 被判定为 null。dynamic_cast 执行动态转换时，type 必须是类的指针、类的引用或者 void*，如果 type 是类指针类型，那么 expr 也必须是一个指针，如果 type 是一个引用，那么 expr 也必须是一个引用。

else
enum

### explicit

1. 指定构造函数或转换函数 (C++11起)为显式, 即它不能用于[隐式转换](https://link.zhihu.com/?target=https%3A//zh.cppreference.com/w/cpp/language/implicit_conversion)和[复制初始化](https://link.zhihu.com/?target=https%3A//zh.cppreference.com/w/cpp/language/copy_initialization).
2. explicit 指定符可以与常量表达式一同使用. 函数若且唯若该常量表达式求值为 true 才为显式. (C++20起)

自己的理解就是，因为C++存在的隐式转换和复制初始化，导致声明对象时出现可预料的不正常操作。

使用场景是只有一个参数需要在构造函数中初始化的。

```cpp
#include<cstring>
#include<string>
#include<iostream>

class Explicit
{
    private:

    public:
        explicit Explicit(int size)
        {
            std::cout << " the size is " << size << std::endl;
        }
        explicit Explicit(const char* str)
        {
            std::string _str = str;
            std::cout << " the str is " << _str << std::endl;
        }

        Explicit(const Explicit& ins)
        {
            std::cout << " The Explicit is ins" << std::endl;
        }

        Explicit(int a,int b)
        {
            std::cout << " the a is " << a  << " the b is " << b << std::endl;
        }
};

int main()
{
    Explicit test0(15);
    Explicit test1 = 10;// 无法调用

    Explicit test2("RIGHTRIGHT");
    Explicit test3 = "BUGBUGBUG"; // 无法调用

    Explicit test4(1, 10);
    Explicit test5 = test0;
}
```

export (1) (3)
extern (1)
false

### final

c++11, 若一个类标记为final则不可继承。函数标记final则禁止子类重写该方法

float
for

### friend

友元声明出现在类体中，并向另一个函数或者类授予包含友元声明的类的私有(private)及受保护类成员(protected)的访问权。

优点：可以避免类对类成员变量和函数的频繁调用，节约开销，提高效率。

缺点：破坏类的封装性。

goto
if
inline (1)
int
long
mutable (1)
namespace
new

### noexcept (since C++11)

`noexcept` 运算符进行编译时检查，如果表达式不会抛出任何异常则返回 true。

not
not_eq
nullptr (since C++11)

### override

作用：在成员函数声明或定义中， override 确保该函数为虚函数并覆写来自基类的虚函数。

位置：函数调用运算符之后，函数体或纯虚函数标识 “= 0” 之前。

好处:

    1. 可以当注释用,方便阅读

    2. 告诉阅读你代码的人，这是方法的复写

    3. 编译器可以给你验证 override 对应的方法名是否是你父类中所有的，如果没有则报错

```cpp
class base
{
public:
    virtual void fun1(void)=0;
};

class derived : public base
{
public:
#if 1 //OK
    void fun1(void) override {
        cout << "a fun1" << std::endl; 
```

operator
or
or_eq
private
protected
public
reflexpr (reflection TS)
register (2)

### reinterpret_cast

**reinterpret_cast<type> (expr)**

重新解释（无理）转换。即要求编译器将两种无关联的类型作转换。

把某种指针改为其他类型的指针。它可以把一个指针转换为一个整数，也可以把一个整数转换为一个指针。requires (since C++20)
return
short
signed
sizeof (1)
static
static_assert (since C++11)

### static_cast

**static_cast<type> (expr)**

执行非动态转换，没有运行时类检查来保证转换的安全性。编译期转换

struct (1)
switch
synchronized (TM TS)
template
this
thread_local (since C++11)
throw
true
try
typedef

### typeid

获取一个表达式的类型，返回表达式的类型

表达式可以是类型名称、变量名、数字、字符串、指针、结构体等

```cpp
struct A {int b;};
A str;
cout << typeid(str).name() << " "
     << typeid(int).name() << endl;
```

typename
union
unsigned
using (1)
virtual
void
volatile
wchar_t
while
xor
xor_eq

## 中英文对照

```textile
abstract                                抽象的
abstraction                             抽象体
access                                  存取，取用
access function                         存取函数
address-of operator                     取地址运算符 &
algorithm                               算法
argument                                实参
array                                   数组
arrow operator arrow                    运算符 ->
assignment                              赋值
assignment operator                     赋值运算符
associated                              相应的，相关的
associative container                   关联式容器（对应于sequential container）
base class                              基类
best viable function                    最佳可行函数（从 viable functions 中挑出最佳温和者）
binding                                 绑定
bit                                     位
bitwise                                 “以bit为单元的。。。” bitwise copy
block                                   块
boolean                                 布尔值（真假值，true, false）
byte                                    字节（8bits 所组成的一个单元）
call operator   call                    运算符() (与function call operator 同)
chain                                   链(chain of function calls)
child class                             子类（或称 derived class, subtype）
class                                   类
class body                              类本身
class declaration                       类声明， 类声明式
class definition                        类定义， 类定义式子
class derivation list                   类派生列
class head                              类表头
class template                          类模板
class template partial specializations  类模板局部特殊化
class template specializaiton           类模板特殊化
cleanup                                 清理
candidate function                      候选函数(在暗示重载解析程序中出现的候选函数)
command line                            命令行
compiler                                编译器
component                               组件
concrete                                具体的
container                               容器（可存放数据的一种结果，例如list, map, set)
context                                 上下文， 背景关系，上下脉络
const                                   常量（constant 的缩写，相对于变数 variable）
constant                                不变的，相对于mutable（易变的）
constructor                             构造函数（与class同名的一种member function） ctor
data member                             数据成员，成员变量
declaration                             声明，声明式
deduction                               推导(例：template argument deduction)
definition                              定义
dereference                             提领（取出指标所指物体的内容）
dereference operator                    提领预算法 *
derived class                           派生类
destructor (dtor)                       析构函数
directive                               指令（例：using directive）
dot operator dot                        运算符
dynamic binding                         动态绑定
entity                                  实体
encapsulation                           封装
enclosing class                         外围类
enum(enumeration)                       枚举
enumerators                             枚举成员
equality operator                       等号运算符==
evaluate                                评估，求值，核定
exception                               异常，异常情况
exception declaration                   异常声明
exception handing                       异常处理，异常处理机制
exception specification                 异常规格
exit                                    退出
explicit                                显式，明显的，明白的
export                                  导出
expression                              表达式
facility                                机制
flush                                   清理，扫清
formal parameter                        形式参数
forward declaration                     前置声明
function                                函数
function call operator                  与operator 同
function object                         函数对象
function overloaded resolustion         函数重载决议程序
function signature                      函数签名
function template                       函数模板
generic                                 泛型，一般化的
generic algorithm                       泛型算法
global                                  全局的
global scope resolution operator        全局生存空间运算符::
handler                                 句柄
header file                             头文件（放置各种类型定义，数据结构，函数声明的文件）
hierarchy                               层次体系（base class 和derived class 派生类）
implement                               实现
implementation                          实现品，实现物，编译器
implicit                                隐式，暗自的(explicit 显式)
increment operator                      自增运算符++
inheritance                             继承，继承机制
inline                                  内敛
inline expansion                        内敛扩展
initialization                          初始化（操作）
initialization list                     初值列
initialize                              初始化
intance                                 实体（常指根据class而产生出来的object）
instantiated                            具体化（应用于template）
invoke                                  调用，唤起
iterate                                 迭代（回圈一个轮回一个轮回地进行）
iterator                                迭代器
iteration                               迭代（回圈中的每一次轮回称之为igeinteration）
lifetime                                生命期，生命周期
linker                                  连接器
literal constant                        文字常量
list                                    链表
local                                   局部的
lvalue                                  左值
manipulator                             操作器
mechanism                               机制
member                                  成员
member access operator                  成员取用运算符（dot, arrow）
member function                         成员函数
member initialization list              成员初始化列表
memberwise                              以 member 为单元的。。例 memberwise copy
mutable                                 可变的，易变的 相对于 constant 不变的
most derived class                      最末层的派生类
namespace                               命名空间
nested class                            嵌套类
operand                                 操作数
operation                               操作行为
operator                                运算符
option                                  选项
overflow                                上限溢位（相对于 underflow）
overhead                                额外负担
overload                                重载
overloaded function                     重载函数
overloaded operator                     重载运算符
overloaded set                          重载集合
override                                改写。意指在derived class 中重新定义virtual function
parameter list                          参数表
parent class                            父类
parse                                   解析
partial specialization                  局部特殊化定义
pass by address                         传址
pass by reference                       传址
pass by value                           传值


platform                                平台
pointer                                 指针
polymorphism                            多态
preprocessor                            预处理器
programming                             编程，程序设计，程序化
project                                 工程
qualified                               限定的
qualifier                               限定词
raise                                   发生(常同来表示发出一个 exception)
rank                                    等级，分类
raw                                     未经处理的
reference  C++                          之中类似 pointer 指针的东西，意义相当于“化身”
represent                               表述，表现
resolve                                 决议。为表达式中的符号名称寻找对应声明的过程。
resolution                              决议程序，决议过程
rvalue                                  右值
scope                                   生存空间
scope operator                          生存空间运算符
scope resolution operator               生存空间决议运算符（与scope operator 同）
sequential  container                   循环容器
signature                               见function signature
specialization                          特殊化，特殊化定义，特殊化声明
stack                                   堆栈
stack unwinding                         堆栈展开
statement                               语句
stream                                  流
string                                  字符串
subscript operator                      下标运算符
subtype                                 子型别
target                                  目标
template                                模板
template argument deduction             模板变量推导
template explicit specialization        范本明白特殊化
template parameter                      模板参数
text file                               程序代码文件
throw                                   抛出
token                                   词法单元
type                                    型别
underflow                               下溢
unqualified                             未经资格修饰（而直接取用）
unwinding                               见stack unwinding
variable                                变量
vector                                  向量
viable                                  可实行的
viable  function                        可行函数
volatile                                易变的
```

## 知识点

### virtual public的含义和作用

**虚基类**

含义为 ，虚基类是指：class SubClass : virtual public BaseClass 中以virtual声明的基类

因为C++支持多重继承。可能会出现派生类的多个父类的父类相同，导致构造时出现二义性。此时使用 虚基类 来基类生成一块内存区域，这样最终的派生类只含有一个基类。

## STL

### std::make_unique(C++14)

### std::make_shared(C++11)

通过make方法构造一个使用智能指针的对象

1.同直接使用new相比，make函数减小了代码重复，提高了异常安全，并且对于std::make_shared和std::allcoated_shared，生成的代码会更小更快。

2.不能使用make函数的情况包括我们需要定制删除器和期望直接传递大括号初始化器。

3.对于std::shared_ptr，额外的不建议使用make函数的情况包括：

  （1）定制内存管理的类，

  （2）关注内存的系统，非常大的对象，以及生存期比 std::shared_ptr长的std::weak_ptr。

### std::move

将一个左值强制转化为右值引用，继而可以通过右值引用使用该值，以用于移动语义。

从实现上讲，std::move基本等同于一个类型转换：`static_cast<T&&>(lvalue);`

```cpp
 template<typename _Tp>
    constexpr typename std::remove_reference<_Tp>::type&&
    move(_Tp&& __t) noexcept
    { return static_cast<typename std::remove_reference<_Tp>::type&&>(__t); }
```



### std::variant

表示一个类型安全的[联合体](https://zh.cppreference.com/w/cpp/language/union "cpp/language/union")。 `std::variant` 的一个实例在任意时刻要么保有其一个可选类型之一的值，要么在错误情况下无值

1. 通过可变的模板参数（variable template，variadic template）你可以指定一组可选类型，它们将是这个实例类型所支持的值类型表。例如 `std::variant<int, boo>` 允许你放入 int 或者 bool 的值并安全的抽出它。
2. 其实例在任意时刻要么包含一个其可选类型之一的值，要么处于病式状态。
3. 其实例的默认值为其首个可选类型的默认构造值。即 `std::variant<int, bool> a;` 语句中，`a` 具有 `(int)(0)` 值。如果首个可选类型没有默认的构造器，那么你需要显式地提供初始化表达式。
4. 不支持引用类型，数组，void 等作为其可选类型。

### std::memory_order_relaxed

std::memory_order 指定如何围绕原子操作对内存访问（包括常规的非原子内存访问）进行排序。在多核系统上没有任何限制，当多个线程同时读取和写入多个变量时，一个线程可以观察到值的变化顺序与另一个线程写入它们的顺序不同。事实上，变化的明显顺序在多个阅读器线程之间甚至可能不同。由于内存模型允许的编译器转换，即使在单处理器系统上也会出现一些类似的效果

属于C++的六种内存顺序。

```textile
std::memory_order_relaxed
std::memory_order_consume
std::memory_order_acquire
std::memory_order_release
std::memory_order_acq_rel
std::memory_order_seq_cst
```

### std::underlying_type

获取一个枚举类型的基本类型（即枚举成员的类型）

template< class T >  
struct underlying_type;

```cpp
    enum class A {white, blue, red};
    enum B {};
    enum class C {A, B, C};
    enum class D : short {};

    cout << "A is " << typeid(underlying_type<A>::type).name() << endl;
    cout << "B is " << typeid(underlying_type<B>::type).name() << endl;
    cout << "B is " << typeid(underlying_type<B>::type).name() << endl;
    cout << "D is " << typeid(underlying_type<D>::type).name() << endl;
    cout << "int is " << typeid(int).name() << endl;

    // output
    A is i
    B is j
    B is j
    D is s
    int is i
```

```cpp
类型对照表
bool                                   b
char                                   c
signed char                            a
unsigned char                          h
(signed) short (int)                   s
unsigned short (int)                   t
(signed) (int)                         i
unsigned (int)                         j
(signed) long (int)                    l
unsigned long (int)                    m
(signed) long long (int)               x
unsigned long long (int)               y
float                                  f
double                                 d
long double                            e
```

### std::funcion

头文件 `<functional>`

类模版std::function是一种通用、多态的函数封装。std::function的实例可以对任何可以调用的目标实体进行存储、复制、和调用操作，这些目标实体包括普通函数、Lambda表达式、函数指针、以及其它函数对象等。std::function对象是对C++中现有的可调用实体的一种类型安全的包裹（我们知道像函数指针这类可调用实体，是类型不安全的）。

最大用处就是实现函数回调，但是之恶能用来检查NULL或者nullptr的相等比较

**std::function是一个可调用对象包装器，是一个类模板，可以容纳除了类成员函数指针之外的所有可调用对象，它可以用统一的方式处理函数、函数对象、函数指针，并允许保存和延迟它们的执行**。

**作用**

1. std::function对C++中各种可调用实体(普通函数、Lambda表达式、函数指针、以及其它函数对象等)的封装，形成一个新的可调用的std::function对象，简化调用

2. std::function对象是对C++中现有的可调用实体的一种类型安全的包裹(如：函数指针这类可调用实体，是类型不安全的)。

```cpp
double f(int x, char y, double z) {
    return x + y + z;
}

int main()
{
    std::function<double(int, char, double)> func_display = f;
    std::cout << func_display(3, 'a', 1.7) << "\n";  
}
```

通用多态函数包装器。 `std::function` 的实例能存储、复制及调用任何[可复制构造 (CopyConstructible)](https://zh.cppreference.com/w/cpp/named_req/CopyConstructible "cpp/named req/CopyConstructible") 的[可调用 (Callable)](https://zh.cppreference.com/w/cpp/named_req/Callable "cpp/named req/Callable") *目标*——函数、 [lambda 表达式](https://zh.cppreference.com/w/cpp/language/lambda "cpp/language/lambda")、 [bind 表达式](https://zh.cppreference.com/w/cpp/utility/functional/bind "cpp/utility/functional/bind")或其他函数对象，还有指向成员函数指针和指向数据成员指针。

存储的可调用对象被称为 `std::function` 的*目标*。若 `std::function` 不含目标，则称它为*空*。调用*空* `std::function` 的*目标*导致抛出 [std::bad_function_call](https://zh.cppreference.com/w/cpp/utility/functional/bad_function_call "cpp/utility/functional/bad function call") 异常。



### std::bind

头文件`<fuctional>`

函数模版bind用于生成 f 的转发调用包装器，

**它接受一个可调用对象，生成一个新的可调用对象来适应原对象的参数列表**。



- **将可调用对象和其参数绑定成一个仿函数**；
- **只绑定部分参数，减少可调用对象传入的参数**。

```cpp
template <class F, class... Args>
bind(F&& f, Args&&... args);
```

**参数**

| f    | -   | [C++ 具名要求：可调用 (Callable) - cppreference.com](https://zh.cppreference.com/w/cpp/named_req/Callable) 对象（函数对象、指向函数指针、到函数引用、指向成员函数指针或指向数据成员指针） |
| ---- | --- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| args | -   | 要绑定的参数列表，未绑定参数为命名空间 `std::placeholders` 的占位符 `_1, _2, _3...` 所替换                                                                           |

**返回值**

未指定类型 `T` 的函数对象，满足 [std::is_bind_expression](http://zh.cppreference.com/w/cpp/utility/functional/is_bind_expression)::value == true 。它有下列属性：



### std::packaged_task

用于包装任何 可调用(Callable) 目标(函数，Lambda，bind表达式)，使得能异步调用，其返回值或所抛异常被存储于能通过 [std::future](https://zh.cppreference.com/w/cpp/thread/future "cpp/thread/future") 对象访问的共享状态中。

### std::feature

头文件`future`

类模板 `std::future` 提供访问异步操作结果的机制：

- （通过 [std::async](https://zh.cppreference.com/w/cpp/thread/async "cpp/thread/async") 、 [std::packaged_task](https://zh.cppreference.com/w/cpp/thread/packaged_task "cpp/thread/packaged task") 或 [std::promise](https://zh.cppreference.com/w/cpp/thread/promise "cpp/thread/promise") 创建的）异步操作能提供一个 `std::future` 对象给该异步操作的创建者。

- 然后，异步操作的创建者能用各种方法查询、等待或从 `std::future` 提取值。若异步操作仍未提供值，则这些方法可能阻塞。

- 异步操作准备好发送结果给创建者时，它能通过修改链接到创建者的 `std::future` 的*共享状态*（例如 [std::promise::set_value](https://zh.cppreference.com/w/cpp/thread/promise/set_value "cpp/thread/promise/set value") ）进行。

```cpp
template< class T > class future;
(1)    (C++11 起)
template< class T > class future<T&>;
(2)    (C++11 起)
template<>          class future<void>;
(3)    (C++11 起)
```

### std::forward

头文件`<utility>`

```cpp
template< class T >
T&& forward( typename std::remove_reference<T>::type& t ) noexcept;
(since C++11)
(until C++14)
template< class T >
constexpr T&& forward( std::remove_reference_t<T>& t ) noexcept;
(since C++14)
(2)	
template< class T >
T&& forward( typename std::remove_reference<T>::type&& t ) noexcept;
(since C++11)
(until C++14)
template< class T >
constexpr T&& forward( std::remove_reference_t<T>&& t ) noexcept;
(since C++14)
```

1) 转发左值为左值或右值，依赖于 T

当 `t` 是[转发引用](https://zh.cppreference.com/w/cpp/language/reference#.E8.BD.AC.E5.8F.91.E5.BC.95.E7.94.A8 "cpp/language/reference")（作为到无 cv 限定函数模板形参的右值引用的函数实参），此重载将参数以在传递给调用方函数时的[值类别](https://zh.cppreference.com/w/cpp/language/value_category "cpp/language/value category")转发给另一个函数。

2) 转发右值为右值并禁止右值的转发为左值

此重载令转发表达式（如函数调用）的结果可行，结果可以是右值或左值，同转发引用参数的原始值类别。
