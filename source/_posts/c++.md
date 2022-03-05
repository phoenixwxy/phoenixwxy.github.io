# c++

[toc]

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
constexpr (since C++11)
constinit (since C++20)
const_cast
continue
co_await (since C++20)
co_return (since C++20)
co_yield (since C++20)
decltype (since C++11)
default (1)
delete (1)
do
double
dynamic_cast
else
enum
explicit
export (1) (3)
extern (1)
false
float
for

### friend

友元声明出现在类体中，并向另一个函数或者类授予包含友元声明的类的私有(private)及受保护类成员(protected)的访问权。

优点：可以避免类对类成员变量和函数的频繁调用，节约开销，提高效率。

缺点：破坏类的封装性。

- goto
  if
  inline (1)
  int
  long
  mutable (1)
  namespace
  new
  noexcept (since C++11)
  not
  not_eq
  nullptr (since C++11)
  operator
  or
  or_eq
  private
  protected
  public
  reflexpr (reflection TS)
  register (2)
  reinterpret_cast
  requires (since C++20)
  return
  short
  signed
  sizeof (1)
  static
  static_assert (since C++11)
  static_cast
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
  typeid
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


