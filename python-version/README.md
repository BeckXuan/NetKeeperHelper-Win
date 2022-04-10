# NetKeeperHelper-Win
## 闪讯拨号脚本 Win-Python3版

### 依赖安装

pip install pywin32

### 功能

与powershell版一致

### 配置

打开**NetKeeper.py**

配置如下几行即可

```python
# 闪讯的账号
default_username = '12345678900@XXXX.XY'
# PPPoE拨号连接的名称
default_entry = 'Netkeeper'
```

注：**PPPoE拨号连接的名称**为现有的PPPoE拨号连接名称，若无，请先手动创建PPPoE拨号连接

### 运行

双击运行**Connect.bat**即可

## 鸣谢

**get_PIN**函数修改自miao1007的[Openwrt-NetKeeper](https://github.com/miao1007/Openwrt-NetKeeper)

## 开源协议

[GPLv2](https://github.com/BeckXuan/NetKeeperHelper-Win/blob/main/LICENSE)

