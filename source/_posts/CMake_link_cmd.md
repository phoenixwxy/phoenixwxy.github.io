---
title: CMake link_directories, LINK_LIBRARIES, target_link_libraries使用总结
time:  2020-12-15
tags: [learn,Program,CMake]
categories: [program,CMake]
---

# link_directories, LINK_LIBRARIES, target_link_libraries使用总结

总结一下include_directories，link_directories，link_libraries和target_link_libraries的作用。尤其是后面三个参数，比较相似，容易弄混。

<!-- more -->

***\*INCLUDE_DIRECTORIES（添加头文件目录）\****
它相当于g++选项中的-I参数的作用，也相当于环境变量中增加路径到CPLUS_INCLUDE_PATH变量的作用（这里特指c++。c和Java中用法类似）。

比如：
include_directories("/opt/MATLAB/R2012a/extern/include")

export CPLUS_INCLUDE_PATH=CPLUS_INCLUDE_PATH:$MATLAB/extern/include


**LINK_DIRECTORIES（添加需要链接的库文件目录）**
语法：
link_directories(directory1 directory2 ...)

它相当于g++命令的-L选项的作用，也相当于环境变量中增加LD_LIBRARY_PATH的路径的作用。

比如：
LINK_DIRECTORIES("/opt/MATLAB/R2012a/bin/glnxa64")

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MATLAB/bin/glnxa64

**
LINK_LIBRARIES　（添加需要链接的库文件路径，注意这里是全路径）**
List of direct link dependencies.

比如：
LINK_LIBRARIES("/opt/MATLAB/R2012a/bin/glnxa64/libeng.so")
LINK_LIBRARIES("/opt/MATLAB/R2012a/bin/glnxa64/libmx.so")

也可以写成：
LINK_LIBRARIES("/opt/MATLAB/R2012a/bin/glnxa64/libeng.so"　"/opt/MATLAB/R2012a/bin/glnxa64/libmx.so")


**TARGET_LINK_LIBRARIES （设置要链接的库文件的名称）**
语法：TARGET_LINK_LIBRARIES(targetlibrary1 <debug | optimized> library2 ..)

比如（以下写法（包括备注中的）都可以）：
TARGET_LINK_LIBRARIES(myProject hello)，连接libhello.so库
TARGET_LINK_LIBRARIES(myProject libhello.a)
TARGET_LINK_LIBRARIES(myProject libhello.so)

再如：
TARGET_LINK_LIBRARIES(myProject libeng.so)　　#这些库名写法都可以。
TARGET_LINK_LIBRARIES(myProject eng)
TARGET_LINK_LIBRARIES(myProject -leng)


**一个简单的示例（\**以下CMakeLists.txt效果相当，在ubuntu 12.04 + g++4.6下测试编译通过\**）：**

方式一：

```html
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

include_directories("/opt/MATLAB/R2012a/extern/include")

#directly link to the libraries.

LINK_LIBRARIES("/opt/MATLAB/R2012a/bin/glnxa64/libeng.so")

LINK_LIBRARIES("/opt/MATLAB/R2012a/bin/glnxa64/libmx.so")

#equals to below

#LINK_LIBRARIES("/opt/MATLAB/R2012a/bin/glnxa64/libeng.so" "/opt/MATLAB/R2012a/bin/glnxa64/libmx.so")

add_executable(myProject main.cpp) 
```


方式二：

```html
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

include_directories("/opt/MATLAB/R2012a/extern/include")

LINK_DIRECTORIES("/opt/MATLAB/R2012a/bin/glnxa64")

add_executable(myProject main.cpp)

target_link_libraries(myProject eng mx)

#equals to below

#target_link_libraries(myProject -leng -lmx)

#target_link_libraries(myProject libeng.so libmx.so)
```