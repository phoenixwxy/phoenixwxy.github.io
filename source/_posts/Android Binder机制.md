---
title: Android Binder机制
time: 2022
tags: [learn,Program]
categories: [program]
---

# Android Binder机制

## 概念

<!-- more -->

Binder是一种进程通信机制（IPC，Inter-Process Communication）。Google在Android上使用的Binder机制是基于[OpenBinder: Binder IPC Mechanism](http://www.angryredplanet.com/~hackbod/openbinder/docs/html/BinderIPCMechanism.html)来实现的。

在Android系统的Binder机制中，由一系列的系统组件构成：Client、Server、Service Manager和Binder驱动程序。其中Client、Server、Service Manager在用户空间，Binder驱动程序运行在内核空间。所以Binder通信就是Client-Server在Binder驱动和ServiceManager的基础上进行通信。该结构使用了设计模式中的代理模式[代理模式](https://www.runoob.com/design-pattern/proxy-pattern.html)

![](Z:\workspace\code\Blog\phoenixwxy.github.io\source\_posts\android_pic.assets\binder_01.gif)

1. Client、Server和Service Manager实现在用户空间中，Binder驱动程序实现在内核空间中
2. Binder驱动程序和Service Manager在Android平台中已经实现，开发者只需要在用户空间实现自己的Client和Server
3. Binder驱动程序提供设备文件/dev/binder与用户空间交互，Client、Server和Service Manager通过open和ioctl文件操作函数与Binder驱动程序进行通信
4. Client和Server之间的进程间通信通过Binder驱动程序间接实现
5. Service Manager是一个守护进程，用来管理Server，并向Client提供查询Server接口的能力

## ServiceManager

ServiceManager用来管理Client和Server的通信，且三者属于不同进程；所以三者之间的通信都是Binder通信。所以ServiceManager在充当Binder的守护进程的时候，也在充当Server。

## Binder驱动

## 名词解释

```textile
BnBinder                        Binder Native
BpBInder                        Binder Proxy
```

# CodeFollow

```cpp
frameworks/native/cmds/servicemanager/main.cpp
    main()
        // driver的具体名字
        const char* driver = argc == 2 ? argv[1] : "/dev/binder";
        // !!!!!----------------!!!!!!!!!!!!!!!!!--------------!!!!!!!!!!!!!!-------------------------!!!!!!!!!!! 相同逻辑
        sp<ProcessState> ps = ProcessState::initWithDriver(driver);
            init(driver, true /*requireDefault*/)
                // 全局对象声明
                static sp<ProcessState> gProcess;
                // 全局构造一个 ProcessState 对象
                // 此时会触发构造函数
                std::call_once(gProcessOnce, [&](){gProcess = sp<ProcessState>::make(driver);}
                    mDriverName(String8(driver))
                    // binder
                    mDriverFD(open_driver(driver))
                        int fd = open(driver, O_RDWR | O_CLOEXEC);
                        // 判断Binder版本!!!!!!!!!!!!!!!!!!!!!!
                        status_t result = ioctl(fd, BINDER_VERSION, &vers);
                        // 设置最大线程数,default 15
                        result = ioctl(fd, BINDER_SET_MAX_THREADS, &maxThreads);
                        // 垃圾检测功能？？？？？
                        result = ioctl(fd, BINDER_ENABLE_ONEWAY_SPAM_DETECTION, &enable);
                    // 申请binder使用的虚拟内存
                    mVMStart = mmap(nullptr, BINDER_VM_SIZE, PROT_READ, MAP_PRIVATE | MAP_NORESERVE, mDriverFD, 0);
                return gProcess;
        ps->setThreadPoolMaxThreadCount(0);
        // 设置出错时的处理逻辑,FATAL_IF_NOT_ONEWAY表示出错直接abort
        ps->setCallRestriction(ProcessState::CallRestriction::FATAL_IF_NOT_ONEWAY);
        // 构造一个 ServiceManager 对象!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // 这里ServiceManager继承自 BnServicemanager 和 IBinder::DeathRecipient, 后面这个使用在ServiceManager死亡时使用
        // 
        sp<ServiceManager> manager = sp<ServiceManager>::make(std::make_unique<Access>());
        // 将构造出来的manager放到manager中的mAccess中
        if (!manager->addService("manager", manager, false /*allowIsolated*/, IServiceManager::DUMP_FLAG_PRIORITY_DEFAULT).isOk())
            auto ctx = mAccess->getCallingContext();
            // uid鉴权
            if (multiuser_get_app_id(ctx.uid) >= AID_APP) {
                return Status::fromExceptionCode(Status::EX_SECURITY);
            }
            //selinux鉴权
            if (!mAccess->canAdd(ctx, name)) {
                return Status::fromExceptionCode(Status::EX_SECURITY);
            }
            //检查name命名
            if (!isValidServiceName(name)) {
                LOG(ERROR) << "Invalid service name: " << name;
                return Status::fromExceptionCode(Status::EX_ILLEGAL_ARGUMENT);
            }
            //如果vndservicemanager则检查VINTF manifest
        #ifndef VENDORSERVICEMANAGER
            if (!meetsDeclarationRequirements(binder, name)) {
                // already logged
                return Status::fromExceptionCode(Status::EX_ILLEGAL_ARGUMENT);
            }
        #endif  // !VENDORSERVICEMANAGER
            //和rpc有关，死亡监听
            // implicitly unlinked when the binder is removed
            if (binder->remoteBinder() != nullptr &&
                binder->linkToDeath(sp<ServiceManager>::fromExisting(this)) != OK) {
                LOG(ERROR) << "Could not linkToDeath when adding " << name;
                return Status::fromExceptionCode(Status::EX_ILLEGAL_STATE);
            }
            //新增一个结构体到map中
            // Overwrite the old service if it exists
            mNameToService[name] = Service {
                .binder = binder,
                .allowIsolated = allowIsolated,
                .dumpPriority = dumpPriority,
                .debugPid = ctx.debugPid,
            };
            //架构中提到的waiteForService的跨进程
            auto it = mNameToRegistrationCallback.find(name);
            if (it != mNameToRegistrationCallback.end()) {
                for (const sp<IServiceCallback>& cb : it->second) {
                    mNameToService[name].guaranteeClient = true;
                    // permission checked in registerForNotifications
                    cb->onRegistration(name, binder);
                }
            }
        // self() 返回一个单例,用于创建一个线程(thread)私有的全局变量,用来存储IPCThreadState对象
        // 将manager设置为localBinder
        IPCThreadState::self()->setTheContextObject(manager);
        // 将声明并构造的ProcessState对象ps
        ps->becomeContextManager();
            // flat_binder_object 用来表示 Binder将有效数据从一个进程传递给另一个进程
            // FLAT_BINDER_FLAG_TXN_SECURITY_CTX 表示
            flat_binder_object obj {
                .flags = FLAT_BINDER_FLAG_TXN_SECURITY_CTX,
            };
            // ioctl kernel 将当前进程注册为ServiceManager 只要当前的SMgr没有调用close()关闭Binder驱动就不能有别的进程可以成为SMgr
            int result = ioctl(mDriverFD, BINDER_SET_CONTEXT_MGR_EXT, &obj);
        sp<Looper> looper = Looper::prepare(false /*allowNonCallbacks*/);
        // 设置当前looper的callback,
        BinderCallback::setupTo(looper);
            sp<BinderCallback> cb = sp<BinderCallback>::make();
            // 获取前面打开的binder fd
            IPCThreadState::self()->setupPolling(&binder_fd);
        // 注册IClient的CallBack,使用定时？5s？？ handleEvent是从fd读取？
        ClientCallbackCallback::setupTo(looper, manager);
            //callBack,执行serviceManager的callback
            mManager->handleClientCallbacks();
            
ServiceManager 远程接口的实现
// 创建一个单例
[[clang::no_destroy]] static sp<IServiceManager> gDefaultServiceManager;
    sp<IServiceManager> defaultServiceManager()
        sp<AidlServiceManager> sm = nullptr;
        // 只会调用一次,下面这句话里面有大文章
        // !!!!!----------------!!!!!!!!!!!!!!!!!--------------!!!!!!!!!!!!!!-------------------------!!!!!!!!!!! 相同逻辑
        // 首先, ProcessState::self()->getContextObject(nullptr) 等价于 new BpBinder(0)
        // 首先是调用ProcessState::self函数,self函数是ProcessState的静态成员函数,它的作用是返回一个全局唯一的ProcessState实例变量,就是单例模式了,
        // 这个变量名为gProcess。如果gProcess尚未创建,就会执行创建操作,在ProcessState的构造函数中,
        // 会通过open文件操作函数打开设备文件/dev/binder,并且返回来的设备文件描述符保存在成员变量mDriverFD中。

        // 接着调用gProcess->getContextObject函数来获得一个句柄值为0的Binder引用,即BpBinder了,于是创建Service Manager远程接口的语句可以简化为：
        sm = interface_cast<AidlServiceManager>(ProcessState::self()->getContextObject(nullptr));
            interface_cast<AidlServiceManager>(new BpBinder(0))
                ProcessState::self()->getContextObject(nullptr)
                    // 通过访问IBinder 0既获取 BpServiceManager,remote为BpBinder
                    sp<IBinder> context = getStrongProxyForHandle(0);
                        // 通过和已经保存的Handle对象的数量对比,第一次进到这个逻辑, N肯定为0,所以创建一个空的 handle_entry e,并添加到数组里面并返回
                        handle_entry* e = lookupHandleLocked(handle);
                        mHandleToObject
                        // 表示需要创建一个新的BpBinder,并且传入handle为0,且引用(wp)？？？
                        // 此时表明我们需要一个特殊的Binder用来支持 ServiceManager的contextManager, BpBinder是SMgr的 Proxy,既remoteBinder(远程binder)
                        // 以供Client链接,此处的client指代的是XX Service(MediaService/CameraServer)
                        if b is null && e->refs(wp) is include && handle is 0
                            // 理解为用于跨进程时,用于保存各种数据的对象,并且改对象提供很多方法用于存取数据
                            Parcel data;
                            
                            status_t status = ipc->transact(0, IBinder::PING_TRANSACTION, data, nullptr, 0);
                                err = writeTransactionData(BC_TRANSACTION, flags, handle, code, data, nullptr);
                                    // 通过ioctl向binder驱动发送了个啥消息,不明白,从上面注释看起来意思是在Binder驱动(kernel)搞了一个context(上下文) manager
                                    err = waitForResponse(&fakeReply);
                                        // 创建了一个 Parcel 将配的参数突突突就通过 talkWithDriver 
                                        if ((err=talkWithDriver()) < NO_ERROR) break;
                                            if (ioctl(mProcess->mDriverFD, BINDER_WRITE_READ, &bwr) >= 0)
                                        // 然后mIn(Parcel)怎么就有一个cmd去switch,一顿乱读就返回了
                            // 呕吼！！！创建了BpBinder, handle 是 0 ！！！！！！！！
                            sp<BpBinder> b = BpBinder::create(handle);
                                // 一坨逻辑,看起来向记录下了调用者的Uid然后放到了一个List,然后看是不是有太多的代理正在连接？
                                return sp<BpBinder>::make(BinderHandle{handle}, trackedUid);
                                    mHandle == BinderHandle{handle}
                                    // BpBinder和handle的引用加入到Parcel mOut,
                                    IPCThreadState::self()->incWeakHandle(this->binderHandle(), this);
                // 创建了一个BpBinder对象,handle是 0 ,ProcessState和IPCThreadState都有了,也记录相关信息
            // frameworks/native/libs/binder/IServiceManager.cpp
            // interface_cast 这是一个模板函数, 所以这里返回的应该是 AidlServiceManager::asInterface(obj)
            template<typename INTERFACE> inline sp<INTERFACE> interface_cast(const sp<IBinder>& obj)
                return INTERFACE::asInterface(obj);
            // 因为这里,所以,调用还是 android::os::IServiceManager 的 asInterface, 但是 android::os::IServiceManager是编译中自动生成的
            using AidlServiceManager = android::os::IServiceManager;
            // DECLARE_META_INTERFACE(INTERFACE)  定义在 frameworks/native/include/binder/IInterface.h 用来声明方法
            // 从代码看就是生成了一个 I##INTERFACE的类构造,一些方法,翻译过来就是: android::os::IServiceManager的构造函数等
            // IMPLEMENT_META_INTERFACE(INTERFACE, NAME) 定义在 frameworks/native/include/binder/IInterface.h 用来实现方法？？？？
            // 通过宏生成 asInterface 函数,就是将生成的 INTERFACE 的类,
            //  android::sp<IServiceManager> IServiceManager::asInterface(const android::sp<android::IBinder>& obj)
            //  {
            //      android::sp<IServiceManager> intr;
            //      if (obj != NULL) {                                             
            //          intr = static_cast<IServiceManager *>(  
                           // 这里的 obj指的是 BpBinder,所以调用queryLocalInterface实现在BpBinder, IServiceManager::descriptor)是通过宏定义生成的另外一个方法
                           // const android::String16 IServiceManager::descriptor("android.os.IServiceManager");
            //             obj->queryLocalInterface(IServiceManager::descriptor).get());              
            //          if (intr == NULL) {            
                            // 创建一个 BpServiceManager,将 BpBinder对象传进去了。。。
                            // 由于,BpServiceManager继承自 BnInterface
                            // 所以,BpInterface(const sp<IBinder>& remote); remote就是BpBinder
                            // BpInterface 继承自 BpRefBase,所以 IBinder* const mRemote; mRemote就是 remote就是BpBinder
                            // 所以 inline IBinder* remote() const { return mRemote; }返回的是BpBinder
            //              intr = new BpServiceManager(obj);                         
            //          }                                                          
            //      }                                                               
            //      return intr;                                                   
            //  } 
        // 从上面逻辑叙述,我们知道了, sm这个对象实际是根据Binder中handle 0为ServiceManager使用binder定义,
        // 使用hanlde创建一个BpBinder对象后用于远程代理,并最终生成的一个BpServicemanager。
        // 可以将上面 sm = interface_cast<AidlServiceManager>(ProcessState::self()->getContextObject(nullptr)); 简化为：
        // sm = new BpServiceManager(new BpBinder(0))
        // 使用sm(BpServiceManager)构建一个gDefaultServiceManager,是对ServiceManagerShim的实现。
        gDefaultServiceManager = sp<ServiceManagerShim>::make(sm);
    // 此时, ServiceManager就拿到了他的远程接口,本质上是一个BpServiceManager,包含了一个Hanlde为0的Binder应用
    // 对于Server来说,就是调用IServiceManager::addService这个接口来和Binder驱动程序交互了,即调用BpServiceManager::addService。
    // 而BpServiceManager::addService又会调用通过其基类BpRefBase的成员函数remote获得原先创建的BpBinder实例,
    // 接着调用BpBinder::transact成员函数。在BpBinder::transact函数中,又会调用IPCThreadState::transact成员函数,
    // 这里就是最终与Binder驱动程序交互的地方了
    // 对Client来说,就是调用IServiceManager::getService这个接口来和Binder驱动程序交互了。具体过程上述Server使用Service Manager的方法是一样的



Server启动过程
// 使用的是MediaPlayerService进行举例
class IBinder : public virtual RefBase
class IInterface : public virtual RefBase
class BBinder : public IBinder
class IMediaPlayerService: public IInterface
template<typename INTERFACE>
class BnInterface : public INTERFACE, public BBinder
class BnMediaPlayerService: public BnInterface<IMediaPlayerService>
class MediaPlayerService : public BnMediaPlayerService

// frameworks/av/media/mediaserver/main_mediaserver.cpp
    main
        // 调用ProcessState,是单例,在构造的时候就已经打开了Binder设备并初始化了线程数量以及版本检测,申请了Binder使用的mmap的内存
        sp<ProcessState> proc(ProcessState::self());
        // sm这个对象实际是根据Binder中handle 0为ServiceManager使用binder定义,
        // 使用hanlde创建一个BpBinder对象后用于远程代理,并最终生成的一个BpServicemanager。
        // 可以将上面 sm = interface_cast<AidlServiceManager>(ProcessState::self()->getContextObject(nullptr)); 简化为：
        // sm = new BpServiceManager(new BpBinder(0))
        // 对于Server来说,就是调用IServiceManager::addService这个接口来和Binder驱动程序交互了,即调用BpServiceManager::addService。
        // 而BpServiceManager::addService又会调用通过其基类BpRefBase的成员函数remote获得原先创建的BpBinder实例,
        // 接着调用BpBinder::transact成员函数。在BpBinder::transact函数中,又会调用IPCThreadState::transact成员函数,
        // 这里就是最终与Binder驱动程序交互的地方了
        sp<IServiceManager> sm(defaultServiceManager());
        MediaPlayerService::instantiate();
            // 将MediaPlayerService添加到Service Manger中
            defaultServiceManager()->addService(String16("media.player"), new MediaPlayerService());
                ServiceManagerShim->addService()
                    IServiceManager->addService()
                        BpServiceManager->addService()
                            // 通过AIDL IServiceManager.aidl 在out/soong下面会有 IServiceManager.cpp
                            // 这部分是通过 libbinder.so + AIDL + Soong生成
                            // 下面这部分自动生成的逻辑，Parcel用来序列化进程间通信数据
                            ::android::Parcel _aidl_data;                                                                                 
                            _aidl_data.markForBinder(remoteStrong());                                                                     
                            ::android::Parcel _aidl_reply;                                                                                
                            ::android::status_t _aidl_ret_status = ::android::OK;                                                         
                            ::android::binder::Status _aidl_status;                    
                            // getInterfaceDescriptor 是从 IMPLEMENT_META_INTERFACE(INTERFACE, NAME)宏里面生成,保存的是"android.os.IServiceManager"                             
                            _aidl_ret_status = _aidl_data.writeInterfaceToken(getInterfaceDescriptor());                                                                                                
                            _aidl_ret_status = _aidl_data.writeUtf8AsUtf16(name);     
                            // service此时指的是MediaService                                                    
                            _aidl_ret_status = _aidl_data.writeStrongBinder(service);                                                     
                            _aidl_ret_status = _aidl_data.writeBool(allowIsolated);                                                       
                            _aidl_ret_status = _aidl_data.writeInt32(dumpPriority);
                            // 这里的调用逻辑是: 因为 BpServiceManager继承自 BpInterface 和 IServiceManager,
                            // BpInterface 继承自 BpRefBase,而 BpRefBase提供remote()用来获取ServiceManager的BpBider,                                           
                            _aidl_ret_status = remote()->transact(BnServiceManager::TRANSACTION_addService, _aidl_data, &_aidl_reply, 0);
                                BpBinder->transact(BnServiceManager::TRANSACTION_addService, _aidl_data, &_aidl_reply, 0);
                                    status = IPCThreadState::self()->transact(binderHandle(), code, data, reply, flags);
                                        IPCThreadState->int32_t handle,uint32_t code, const Parcel& data,Parcel* reply, uint32_t flags)
                                            // 里面写的东西其实就是上面写的service,name之类的
                                            err = writeTransactionData(BC_TRANSACTION, flags, handle, code, data, nullptr);
                                            if (flags & TF_ONE_WAY == 0)
                                                // 这个函数会有很多Binder操作, 具体的后面看Binder驱动再说
                                                err = waitForResponse(reply);
                                                    if ((err=talkWithDriver()) < NO_ERROR) break;
                                                        if (ioctl(mProcess->mDriverFD, BINDER_WRITE_READ, &bwr) >= 0)
                            if (UNLIKELY(_aidl_ret_status == ::android::UNKNOWN_TRANSACTION && IServiceManager::getDefaultImpl())) {      
                            return IServiceManager::getDefaultImpl()->addService(name, service, allowIsolated, dumpPriority);          
                            }                                                                                                             
                            _aidl_ret_status = _aidl_status.readFromParcel(_aidl_reply);                                                  
                            _aidl_status.setFromStatusT(_aidl_ret_status);                                                                
                            return _aidl_status;  
// 注意这里同时将服务端会有相应的处理逻辑,  
    class BinderCallback : public LooperCallback {
        int handleEvent()
            IPCThreadState::self()->handlePolledCommands(); 
                do {
                    result = getAndExecuteCommand();
                        result = talkWithDriver();
                            result = executeCommand(cmd);
                                ...
                                error = reinterpret_cast<BBinder*>(tr.cookie)->transact(tr.code, buffer, &reply, tr.flags);
                                    // 这个也是自动生成的文件
                                    BnServiceManager->onTransact();
                                        case BnServiceManager::TRANSACTION_addService:
                                            ::android::binder::Status _aidl_status(addService(in_name, in_service, in_allowIsolated, in_dumpPriority));
                                                ServiceManager->addService();
                                ...
                } while (mIn.dataPosition() < mIn.dataSize());

                processPendingDerefs();

        
        ::android::hardware::configureRpcThreadpool(16, false);
        ProcessState::self()->startThreadPool();
            ProcessState->spawnPooledThread(true);
                sp<Thread> t = sp<PoolThread>::make(isMain);
                t->run
                    threadLoop()
                        // 和main函数一样都是这个函数, mIsMain是 true
                        IPCThreadState::self()->joinThreadPool(mIsMain);
                            mOut.writeInt32(isMain ? BC_ENTER_LOOPER : BC_REGISTER_LOOPER);
                            do {
                                processPendingDerefs();
                                result = getAndExecuteCommand();
                                    result = talkWithDriver();
                                        // 函数里面会有真正的BBinder处理Client的请求
                                        result = executeCommand(cmd);
                                            ...
                                            error = reinterpret_cast<BBinder*>(tr.cookie)->transact(tr.code, buffer, &reply, tr.flags);
                                                BnMediaPlayerService->onTransact()
                                                // 具体业务流程
                                            ...
                            } while (result != -ECONNREFUSED && result != -EBADF);

                            talkWithDriver(false);
        IPCThreadState::self()->joinThreadPool();
        ::android::hardware::joinRpcThreadpool();
                            
                    
Client和Server通信
使用MediaPlayer和MediaService进行分析
    IMediaDeathNotifier::getMediaPlayerService()
        sp<IServiceManager> sm = defaultServiceManager();
        sp<IBinder> binder;
        do {
            binder = sm->getService(String16("media.player"));
                ServiceManagerShim->getService(()
                    while (uptimeMillis() - startTime < timeout) {
                        sp<IBinder> svc = checkService(name);
                            sp<IBinder> ret;
                            if (!mTheRealServiceManager->checkService(String8(name).c_str(), &ret).isOk())
                                BpServiceManager->checkService()
                                    _aidl_ret_status = remote()->transact(BnServiceManager::TRANSACTION_checkService, _aidl_data, &_aidl_reply, 0);
                                    BpBinder->transact(BnServiceManager::TRANSACTION_checkService, _aidl_data, &_aidl_reply, 0);
                                    status = IPCThreadState::self()->transact(binderHandle(), code, data, reply, flags);
                                        IPCThreadState->int32_t handle,uint32_t code, const Parcel& data,Parcel* reply, uint32_t flags)
                                            // 里面写的东西其实就是上面写的service,name之类的
                                            err = writeTransactionData(BC_TRANSACTION, flags, handle, code, data, nullptr);
                                            if (flags & TF_ONE_WAY == 0)
                                                // 这个函数会有很多Binder操作, 具体的后面看Binder驱动再说
                                                err = waitForResponse(reply);
                                                    if ((err=talkWithDriver()) < NO_ERROR) break;
                                                        if (ioctl(mProcess->mDriverFD, BINDER_WRITE_READ, &bwr) >= 0)
                    }
                    
            if (binder != 0) {                
                break;
            }
            ALOGW("Media player service not published, waiting...");
            usleep(500000); // 0.5 s
        } while (true);


Java层如果使用Binder, 并使用ServiceManager来管理Server和Client
frameworks/base/core/java/android/os/ServiceManager.java
    public final class ServiceManager
        private static IServiceManager sServiceManager;
        IServiceManager getIServiceManager()
            sServiceManager = ServiceManagerNative.asInterface(Binder.allowBlocking(BinderInternal.getContextObject()));
                Binder.allowBlocking(BinderInternal.getContextObject())
                    BinderInternal.getContextObject()
                        // native 可以看出来这个是一个JNI的方法
                        public static final native IBinder getContextObject();
                            // frameworks/base/core/jni/android_util_Binder.cpp
                            { "getContextObject", "()Landroid/os/IBinder;", (void*)android_os_BinderInternal_getContextObject }
                                android_os_BinderInternal_getContextObject()
                                    // 获取的就是全局的ServiceManager,
                                    // 实际就是一个 BpBinder
                                    sp<IBinder> b = ProcessState::self()->getContextObject(NULL);
                                        // static struct bindernative_offsets_t
                                        // {
                                        //     // Class state.
                                        //     jclass mClass;
                                        //     jmethodID mExecTransact;
                                        //     jmethodID mGetInterfaceDescriptor;
                                        
                                        //     // Object state.
                                        //     jfieldID mObject;
                                        
                                        // } gBinderOffsets;
                                        // gBinderOffsets用来记录 Binder信息的，在int_register_android_os_Binder初始化
                                        // static struct binderproxy_offsets_t
                                        // {
                                            Class state.
                                            // jclass mClass;
                                            // jmethodID mGetInstance;
                                            // jmethodID mSendDeathNotice;
                                                // Object state.
                                            // jfieldID mNativeData;  // Field holds native pointer to BinderProxyNativeData.
                                        // } gBinderProxyOffsets;
                                        // gBinderProxyOffsets用来记录 BinderProxy 在int_register_android_os_BinderProxy
                                    return javaObjectForIBinder(env, b)
                                        if (val->checkSubclass(&gBinderOffsets)) { // false
                                            jobject object = static_cast<JavaBBinder*>(val.get())->object();
                                            return  object
                                        }
                                        // 用来保存传进来的 BpBinder对象和 DeathRecipientList
                                        BinderProxyNativeData* nativeData = new BinderProxyNativeData();
                // 相当于 sServiceManager = ServiceManagerNative.asInterface(new BinderProxy());
                // 相当于 sServiceManager = new ServiceManagerProxy(new BinderProxy());

                static IServiceManager asInterface(IBinder obj)
                    return new ServiceManagerProxy(obj);
                        class ServiceManagerProxy implements IServiceManager
```

<>
