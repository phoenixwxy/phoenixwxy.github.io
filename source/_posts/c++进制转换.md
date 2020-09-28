---
title:  c++进制转换
time:  2020-09-28
tags: [learn,Program]
categories: program
---



# 十进制和二进制相互转换

**（1）十进制转二进制**

```
int a = 10;
bitset<10> bit(a);
cout << bit << endl;

输出：0000001010
```

**（2）二进制转十进制**

   第一种方法：

```
bitset<10> bit("010101");
int a = bit.to_ullong(); //这里为unsigned long long
cout << a << endl;

输出：21
```

  第二种方法： 

```
string out = "0101";
int x = stoi(out, nullptr, 2);
cout << x <<endl;

输出：5
```

# 字符串和二进制相互转换

**（1）二进制转字符串**

```
bitset<10> bit("010101");
string str = bit.to_string();
cout << str << endl;

输出：0000010101
```

**（2）字符串转二进制**

```
string str = "010101";
bitset<10> bit(str);	
cout << bit << endl;

输出：0000010101
```

# 字符串和十进制相互转换

**（1）十进制转字符串**

```
int a = 345;
string str = to_string(a);
cout <<str << endl;

输出：345
```

**（2）字符串转十进制**

```
string str = "3456";
int a = stoi(str);
cout << a << endl;

输出：3456
```

# 十进制和十六进制相互转换

**（1）十六进制转十进制**

  第一种方法：

```
#include <sstream>
int x;
stringstream ss;
ss << std::hex << "1A";  //std::oct（八进制）、std::dec（十进制）
ss >> x;
cout << x<<endl;

输出：26
```

  第二种方法：

```
string out = "1A";
int x = stoi(out, nullptr, 16);
cout << x <<endl;

输出：26
```

 **（2）十进制转十六进制**

```
int x = 26 ;
string out;
stringstream ss;
ss << std::hex <<x;
ss >> out ;
transform(out.begin(), out.end(), out.begin(), ::toupper);
cout << out <<endl;

输出：1A
```

# **二进制和十六进制**

**（1）二进制转十六进制**

```
string binary = "11010101";
string hex;
stringstream ss;
ss << std::hex << stoi(binary, nullptr, 2);
ss >> hex;
transform(hex.begin(), hex.end(), hex.begin(), ::toupper);
cout << hex <<endl;

输出：D5
```

**（2）十六进制转二进制**

```
string binary = "D5";
bitset<8> bit(stoi(binary, nullptr, 16));
cout << bit << endl;

输出：11010101
```

 