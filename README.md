# HyperOS FCM Keepalive for Stellar

面向小米 HyperOS 4 的非 Root FCM 保活实验脚本。通过 Stellar 的 ADB Shell 权限配置 Android 原生后台白名单及小米 MILLET/Greezer 豁免，无需原版 Shizuku。

## 文件
- scripts/setup.sh：一次性初始化 Doze、AppOps、待机及流量节省白名单，并尝试 MILLET/Greezer 豁免。
- scripts/keepalive.sh：默认每 60 秒检查并恢复 OEM 设置，记录心跳。
- scripts/control.sh：启动、停止、查看守护进程状态。

## 使用方法
将三个脚本放到手机 /data/local/tmp/fcm-stellar/ 目录，在 Stellar Shell 中执行（无需 adb shell 前缀）：

```sh
id
sh /data/local/tmp/fcm-stellar/setup.sh
sh /data/local/tmp/fcm-stellar/control.sh start
sh /data/local/tmp/fcm-stellar/control.sh status
```

预期 UID 为 2000。修改间隔（最低 30 秒）：

```sh
sh /data/local/tmp/fcm-stellar/control.sh stop
# 等待 status 显示 STOPPED 后再启动
sh /data/local/tmp/fcm-stellar/control.sh start 120
```

日志和心跳位于 /data/local/tmp/fcm-stellar/keepalive.log 和 heartbeat。息屏 30 分钟后检查心跳是否更新；心跳仅代表脚本执行，不代表 FCM 已连接或豁免生效。

## 注意事项
- OEM 接口未公开，可能因 ROM 更新失效或返回权限错误。
- nohup 无法防止系统强制杀进程；深度休眠可能推迟执行，重启后需重新启动。
- 停止脚本不会撤销已修改的白名单。
- 不关闭全局 Doze，不禁用 PowerKeeper，不反复广播 FCM 重连。
- 用户反馈此前命令似乎可用，但本仓库版本尚未独立真机验证。
- PID 检查依赖 /proc 可读；如无法读取，请勿反复启动，先检查进程。

## 参考
[hyperos-fcm-fix](https://github.com/dingwen07/hyperos-fcm-fix) 提供社区研究线索，本项目并非其官方实现。
