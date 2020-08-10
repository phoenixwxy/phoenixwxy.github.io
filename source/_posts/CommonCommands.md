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

# Android

```shel
systrace gfx input view wm am sm video camera hal bionic aidl sched irq i2c freq idle sync workq pagecache -b 50960 -o test1304.html
```

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
`simpleperf record -p pid --duration 5 -o sdcard/perf.data --call-graph fp `
2、导出sdcard/perf.data，在sdcard/perf.data下执行
`python report_html.py -i perf.data -o test.html`

- 打印 FPS

```shell
adb root
adb shell setprop persist.vendor.camera.logPerfInfoMask 0x10000
adb shell setprop persist.vendor.camera.enableFPSLog 1
camxoverridesettings.txt 里enableFPSLog=TRUE
```

`adb logcat |grep -Ei "CalculateResultFPS"` 每10秒打印一次log~