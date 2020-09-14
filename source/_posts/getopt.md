---
title:  getopt
time:  2020-08-31
tags: C
categories: 编程
---



# 如何优雅地处理命令行参数？

原文地址： [https://www.yanbinghu.com/2019/08/17/57486.html](https://link.zhihu.com/?target=https%3A//www.yanbinghu.com/2019/08/17/57486.html)

## **前言**

我们在Linux用到的命令常常支持很多参数，那么如何写一个程序，也像Linux命令一样支持很多参数呢？有什么什么优雅的处理方法？

## **命令行参数**

在介绍如何处理命令行参数之前，简单介绍一下命令行参数，已经了解的朋友可以跳过此小节。
我们用一段代码，打印传给程序的每一个参数

```c
//main.c
#include<stdio.h>
int main(int argc,char *argv[])
{
    int i = 0;
    for(i = 0;i < argc;i++)
    {
        printf("the %d para is %s\n",i,argv[i]);
    }
    return 0;
}
```

其中argc代表输入的参数个数，而argv中保存着参数具体的值，我们编译运行：

```text
$ gcc -o main main.c
$ ./main 编程珠玑 C C++ Java 博客
the 0 para is ./main
the 1 para is 编程珠玑
the 2 para is C
the 3 para is C++
the 4 para is Java
the 5 para is 博客
```

我们依次打印了程序的输入参数，其中特别注意的是，第一个（下标为0）的参数是程序本身。

## **如何优雅地处理命令行参数**

实际上我们通过getopt函数很容易实现。

### **函数声明**

getopt就可以非常方便地处理简单参数了，其声明如下：

```c
#include<unistd.h>
extern int optind,opterr,optopt;
extern char *optarg;
int getopt(int argc,char *const argv[],const char *optstring);
```

### **参数介绍**

几个参数说明如下：

- argc 参数个数，可从main函数入口传入
- argv 参数字符串数组，可从main函数入口传入
- optstring 支持的选项字符串

第一个和第二个参数我们很熟悉，它和main函数的参数是一样的：

```c
int main(int argc,char *argv[]);
```

第三个参数是什么意思呢？指的是你支持的选项，假设你的程序支持-h,-a,-n选项，并且-n选项后面要跟具体参数，那么optstring可以是：

```text
“han:”
```

选项后面有一个冒号表示这个选项需要带参数。

它的返回值是int类型，如果出错，则返回-1，如果命令参数不识别，则返回’?‘。

### **外部变量**

它有四个外部变量，含义分别如下：

- optind 存放下一个要处理的字符串在argv数组中的下标，从1开始
- opterr 如果选项发生错误，getopt会打印出错消息，如果设置为0，则不打印。
- optopt 如果选项处理发生错误，它会指向导致出错的选项字符串
- optarg 如果一个选项需要参数，如前面提到的n参数，由于后面有:，所以它需要参数，处理到它时，optarg会指向这个参数。

### **程序示例**

我们仍然通过一个示例程序来看：

```c
//来源：公众号【编程珠玑】
//博客：https://www.yanbinghu.com
//main1.c
#include<stdio.h>
#include<unistd.h>
extern int optind,opterr,optopt;
extern char *optarg;
int main(int argc,char *argv[])
{
    int c = 0; //用于接收选项
    /*循环处理参数*/
    while(EOF != (c = getopt(argc,argv,"han:")))
    {
        //打印处理的参数
        printf("start to process %d para\n",optind);
        switch(c)
        {
            case 'h':
                printf("we get option -h\n");
                break;
            case 'a':
                printf("we get option -a\n");
                break;
            //-n选项必须要参数
            case 'n':
                printf("we get option -n,para is %s\n",optarg);
                break;
            //表示选项不支持
            case '?':
                printf("unknow option:%c\n",optopt);
                break;
            default:
                break;
        }    
    }
    return 0;
}
```

编译运行：

```text
$ gcc -o main1 main1.c
```

输入正常选项时，我们可以看到能正确获取到选项，获取到之后自然就可以做对应的动作了。

```text
$ ./main1 -h -a
start to process 2 para
we get option -h
start to process 3 para
we get option -a
```

如果输入的选项不支持，就会提示未知选项：

```text
$ ./main1 -u
./main1: invalid option -- 'u'
start to process 2 para
unknow option:u
```

对于-n选项，我们需要参数，如果没有参数会怎样？

```text
$ ./main1 -n
./main1: option requires an argument -- 'n'
start to process 2 para
unknow option:n
```

它会提示我们n选项需要参数，于是带上参数：

```text
$ ./main1 -n
start to process 3 para
we get option -n,para is 2
```

怎么样？是不是很简单？

### **问题**

但是不知道你有没有发现，上面的处理有个问题，那就是不支持长选项。

什么意思呢？

```text
$ ./main1 -ha
start to process 1 para
we get option -h
start to process 2 para
we get option -a
```

这种情况下，-ha被当成了两个选项，而不是一个选项，选项名为ha。

那么这种情况应该如何处理呢？就需要用到后面的函数啦。

## **长选项处理**

为了应对前面说的这种情况，需要用到下面两个函数中的一个：

```c
#include<getopt.h>
int getopt_long(int argc, char * const argv[],
                  const char *optstring,
                  const struct option *longopts, int *longindex);

int getopt_long_only(int argc, char * const argv[],
                  const char *optstring,
                  const struct option *longopts, int *longindex);
```

它们的第一个第二个参数和getopt一样，第三个参数是一个struct option指针：

```c
           struct option {
               const char *name;
               int         has_arg;
               int        *flag;
               int         val;
           };
```

其成员含义分别如下：

- name 长选项名称
- has_arg 参数可选项，no_argument表示该选项后不带参，required_argument表示该选项后面带参数
- *flag 匹配到选项后，如果flag是NULL，则返回val；如果不是NULL，则返回0，并且将val的值赋给flag指向的内存
- val 匹配到选项后的返回值

longindex表示**长选项**在longopts中的索引值。

那getopt_long和getopt_long_only有什么区别呢？
实际上主要功能是差不多的，只是前者一个-时被解析成短选项，--被解析成长选项，而后者都被解析为长选项，举个例子，-help在前者被解析为h,e,l,p四个选项，而在后者是和--help一样的效果，即被认为是长选项。在getopt_long_only中，optstring可以为“”。

我们来看一个示例程序：

```c
//来源：公众号【编程珠玑】
//博客：https://www.yanbinghu.com
//main2.c
#include<stdio.h>
#include<getopt.h>
extern int optind,opterr,optopt;
extern char *optargi;
//定义长选项
static struct option long_options[] = 
{
    {"help",no_argument,NULL,'h'},
    {"verbose",no_argument,NULL,'v'},
    {"number",required_argument,NULL,'n'}
};
int main(int argc,char *argv[])
{
    int index = 0;
    int c = 0; //用于接收选项
    /*循环处理参数*/
    while(EOF != (c = getopt_long(argc,argv,"hvn:",long_options,&index)))
    {
        switch(c)
        {
            case 'h':
                printf("we get option -h，index %d\n",index);
                break;
            case 'v':
                printf("we get option -v，index %d\n",index);
                break;
            //-n选项必须要参数
            case 'n':
                printf("we get option -n,para is %s\n",optarg);
                break;
            //表示选项不支持
            case '?':
                printf("unknow option:%c\n",optopt);
                break;
            default:
                break;
        }   
    }
    return 0;
}
```

编译运行：

```text
$ gcc -o main2 main2.c
$ ./main2 --verbose --help 
we get option -v，index 1
we get option -h，index 0
```

注意，为什么-v参数的index是0？因为只有长选项才会对应index。

可以看到，使用--跟长选项，单个-后面跟短选项，但是如果是下面这样呢？

```text
$ ./main2 -help 
we get option -h，index 0
./main2: invalid option -- 'e'
unknow option:e
./main2: invalid option -- 'l'
unknow option:l
./main2: invalid option -- 'p'
unknow option:p
```

在这里，由于使用的getopt_long，它对于单个-的字符串，里面每个字符都当成了一个选项，因此help对它来说，其实是四个选项，但是后三个不被识别。如果想要-help也被当成长选项，那么就需要用到getopt_long_only函数了。

最后，再完整的用一遍：

```text
$ ./main2 --help --verbose --number 10
we get option -h，index 0
we get option -v，index 1
we get option -n,para is 10
```

## **扩展说明**

其实在处理选项的时候，如果参数前面有-，比如：

```text
rm -bar
```

这里的-bar会被当成一个选项，而不是文件名，因此想要把它当成文件名，而不是选项，需要采用下面这种方式：

```text
rm -- -bar
```

具体可以参考《[linux中删除特殊名称文件的多种方式](https://link.zhihu.com/?target=https%3A//www.yanbinghu.com/2019/01/19/8873.html)》。

## **总结**

想要优雅地处理命令行参数，今天介绍的几个函数是有必要掌握了，那么是不是很想自己尝试一下呢？更多细节等你去发现。