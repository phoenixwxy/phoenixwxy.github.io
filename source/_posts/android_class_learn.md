# Android Class

## RefBase

RefBase是一个实现类，Google用RefBase来支持强指针(sp)和弱指针(wp)以及一些binder需要的magic feature（啥神奇功能）。

```c++
class RefBase {
public:
    void incStrong(const void* id) const
    void incStrongRequireStrong(const void* id) const
    void decStrong(const void* id) const
    void forceIncStrong(const void* id) const
    class weakref_type {}
protected:
    RefBase()
    virual ~RefBase()
}
```

从目前代码看就是主要实现sp和wp。后续继承类基本都是使用了改功能。
