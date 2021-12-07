---
title:  常用命令备份
time:  2020-08-05 10:00
tags: backup
categories: 查询
---

**记录一下常用的命令和设置**

<!-- more -->

# Linux 命令

- For search and replace

grep "/\*\*\*/" -rl ./* | xargs sed -i 's//mm-camerasdk///mm-camerasdk-xxx//g'

- 查看共享库.so 依赖的其他库

`readelf -a out/target/product/umi/vendor/lib64/hw/com.qti.chi.override.so | grep NEEDED`

- 查看共享库 .so 的信息

`string xxx.so`

- git 自动提示

```shell
source /etc/bash_completion.d/git
# or
source /usr/share/bash-completion/completions/git
```

- udev设置

```
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0666"
```





# Shell 脚本

- 杀死camera相关进程

```shell
alias killcam='killcameraserver'
killcameraserver(){ 
    adb shell killall cameraserver
    adb shell killall android.hardware.camera.provider@2.4-service }
添加到~/.bashrc中，减少复杂操作
```



# Git 命令

- 出现git log丢失问题

`git fetch <origen> <branch-name> --unshallow`

# Camera 命令



# MarkDown 命令

- 添加目录

使用 `[toc]`来显示目录

`npm i doctoc -g` 安装doctoc 命令，在对应目录下使用 `doctoc filename.md`

# Log 关键位置

|                                      |                            |      |
| :----------------------------------- | :------------------------- | :--- |
| log                                  | 含义                       | 备注 |
| CAM_FragmentBottomActio: onSnapClick | 点击拍照按钮               |      |
| mCaptureStartTime                    | 记录底层返回YUV/JPEG数据点 |      |
| ImageLoader                          | 记录image相关log           |      |
| Start display image                  | 开始执行对应图片处理       |      |
| watermark                            | 水印                       |      |
| Subsample                            | 采样                       |      |
| Subsample original                   | 对原图采样                 |      |
| Display image in ImageAware          | 在图库显示                 |      |
| update exif                          | 更新exif信息               |      |
| isRemosaic                           | 是否走的是remosaic模式     |      |
| imagesaver][ end                     | 图像处理完成               |      |

# Docker

`docker commit -m="update some" -a="Phoenix" 4cfd1849b2fe phoenix`

`docker run -t -v /home/mi:/phoenix -u phoenix -i phoenix /bin/bash`
`docker run -t -v /home/mi:/phoenix -u phoenix -i phoenixwxy1/phoenix_ubuntu /bin/bash`

`docker save -o rocketmq.tar rocketmq    ##-o：指定保存的镜像的名字；rocketmq.tar：保存到本地的镜像名称；rocketmq：镜像名字，通过"docker images"查看`

# Android

```shel
systrace gfx input view wm am sm video camera hal bionic aidl sched irq i2c freq idle sync workq pagecache -b 50960 -o test1304.html
```

2.  筛选trace信息

```shel
HAL3ProcessCaptureResult :|HAL3ProcessCaptureRequest :|ProcessFenceCallback RequestId |ProcessRequest 
```

```shell
CAMX_TRACE_ASYNC_END_F(CamxLogGroupDRQ, id, "Deferred Node %s RequestId: %d SequenceId %d %s",
                         pDependency->pNode->Name(), pDependency->requestId, 
                         pDependency->processSequenceId, pDependency->pNode->NodeIdentifierString());
```

`debuggerd` 可以打印backtrace

# ffmpeg 使用

ffprobe -show_frames -select_streams V -i '.\J11(12.0.1.0.QJKCNXM).mp4' -print_format xml > 10.xml

ffpmeg -i

# Qcom 相关

- 固定 AF

```shel
adb shell setprop vendor.debug.camera.af.manual 2
adb shell setprop vendor.debug.camera.af.ctrl.lenspos 222
```

第一个指令将手机设置为手动对焦模式
        第二个指令把lens推到想要的位置，222可以随意替换成0-899之间的整数

- 添加调用栈

.mk中添加添加LOCAL_SHARED_LIBRARIES += libutilscallstack

```C++

diff --git a/build/infrastructure/android/common.mk b/build/infrastructure/android/common.mk
index 731cae4..4444b0e 100755
--- a/build/infrastructure/android/common.mk
+++ b/build/infrastructure/android/common.mk
@@ -160,6 +160,8 @@ LOCAL_SHARED_LIBRARIES += libhardware
 
 LOCAL_STATIC_LIBRARIES += libcamxgenerated
 
+LOCAL_SHARED_LIBRARIES += libutilscallstack
+
 LOCAL_WHINER_RULESET := camx
 CAMX_CHECK_WHINER := $(CAMX_BUILD_PATH)/check-whiner.mk
2、在需要打调用栈的函数中添加接口
#include <utils/CallStack.h>


 android::CallStack cs("zoom-smooth-m_pState");
```

- SimplPerf 使用

    1、记录数据（提前把`system/extras/simpleperf/scripts/bin/android/arm64`下文件push到手机里）
    执行
    `simpleperf record -p pid --duration 5 -o sdcard/perf.data -g --call-graph fp `
    2、导出sdcard/perf.data，在sdcard/perf.data下执行
    `python report_html.py -i perf.data -o test.html`

    ```shell
    adb shell "/system/bin/simpleperf record -p <pid of cameraprovider> -g -o /data/misc/perf.data"
    adb shell "/system/bin/simpleperf report -i /data/misc/perf.data > /data/misc/report.txt"
    adb shell "/system/bin/simpleperf report -i /data/misc/perf.data -g --full-callgraph > /data/misc/report_callgraph.txt"
    ```

    

- 打印 FPS

```shell
adb root
adb shell setprop persist.vendor.camera.logPerfInfoMask 0x10000
adb shell setprop persist.vendor.camera.enableFPSLog 1
camxoverridesettings.txt 里enableFPSLog=TRUE
```

`adb logcat |grep -Ei "CalculateResultFPS"` 每10秒打印一次log~

```
offlinelog的抓取方法
方法1：
需要查看kenerl中的log时，通过以下方法打开log开关：
终端执行：
adb shell setprop persist.sys.offlinelog.kernel ture
adb shell setprop persist.sys.offlinelog.logcat ture
log存储在手机系统的路径为：data/local/log
终端执行：
adb pull /data/local/log
将log文件拉取到本地进行查看。
开关关闭，则是将ture更改为false即可。
方法2：
手机拨号界面输入：*#*#6335463#*#*
分别将"kernel log"和"Logcat log"勾选即可，关闭时则将勾掉即可。
注：
确定offlinelog是否已经关闭，用过以下方法进行查询：
终端执行：
adb shell
getprop | grep offlinelog
显示：
[persist.sys.offlinelog.kernel]: [false]
[persist.sys.offlinelog.logcat]: [false]
```





# Plantuml

java -DPLANTUML_LIMIT_SIZE=8192 -jar E:\Soft\plantuml.jar -charset UTF-8 .\init.puml