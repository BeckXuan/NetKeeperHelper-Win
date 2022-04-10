# NetKeeperHelper-Win
## 闪讯拨号脚本 Win-Powershell版

### 功能

要求用户输入密码，结合配置的账号自动连接闪讯

脚本会在运行目录下生成配置文件，保存密码和当前的时间

若离上次输入密码的时间不超过28小时，则自动尝试使用上次的密码登录

若自动登录失败，则下次会直接要求用户再次输入密码

### 配置

打开**NetKeeper.ps1**

配置如下几行即可

```powershell
## PPPOE Entry
$pppname = "Netkeeper"
## Netkeeper Accounts
$username = "12345678900@XXXX.XY"
```

注：**pppname**为现有的PPPoE拨号连接名称，若无，请先手动创建PPPoE拨号连接

### 小技巧

把脚本放到某个目录下

在桌面创建快捷方式

```
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File path\to\NetKeeper.ps1
```

双击即可便捷运行

## 说明

**NetKeeper.ps1**中的**## Encoding Username**部分来源网络

但后续未找到出处，感谢代码作者，侵删

## 开源协议

[GPLv2](https://github.com/BeckXuan/NetKeeperHelper-Win/blob/main/LICENSE)

