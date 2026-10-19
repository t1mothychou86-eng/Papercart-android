<!-- CN: A1 current Android identity; A0 results remain historical. -->
当前 A1 APK 名称为 Papercart，包名为 `io.github.t1mothychou86.papercart`。以下 A0 说明记录改名前的历史结果。

# A0 安卓真机安装与验证

A0 使用上游原样代码，安装后名称仍为 Wispar，包名为 `app.wispar.wispar`；改名属于 A1。此处仅用于本地验证。APK 是否已生成、实际大小和构建结果见 [A0-REPORT.md](A0-REPORT.md)。

## 从 Windows 手动安装

1. 在 WSL 仓库目录运行 `explorer.exe .`，在打开的 Windows 文件资源管理器中进入 `build/app/outputs/flutter-apk/`，找到 `app-debug.apk`。也可在资源管理器地址栏输入 `\\wsl.localhost\`，选择当前发行版，再进入 `/home/tidalflux/.whuproject/papercart-android/` 下的上述目录。
2. 将 APK 复制到 Windows，再通过 USB 文件传输等方式复制到手机的“下载”目录。
3. 在手机文件管理器中打开 APK，按系统提示允许该文件管理器“安装未知应用”，完成安装。
4. 从桌面启动 Wispar，按下面的清单验证。完成后可关闭该文件管理器的安装权限。

## 无线 adb（Android 11 及以上）

手机与电脑连接同一 Wi-Fi，手机打开“开发者选项 → 无线调试 → 使用配对码配对设备”。以下地址和端口都替换成手机显示的实际值；配对码只在本地交互输入，不写进文件或日志。

在 WSL 的仓库目录执行：

```bash
source scripts/env.sh
adb pair 手机IP:配对端口
# 按提示输入手机上的配对码。
adb connect 手机IP:连接端口
adb devices -l
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

配对端口与无线调试首页显示的连接端口可能不同。`adb devices -l` 中设备状态应为 `device`，随后从手机桌面启动应用。

若 WSL 无法访问手机地址，可先用手动安装完成 A0 验证；也可在 Windows 使用 Google 官方 [SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools) 执行相同 adb 命令，将安装路径换成复制到 Windows 的 APK 路径。Android 10 及以下优先使用手动安装。

本次 Codex 沙箱中的 adb 37.0.1 尝试创建 `/home/tidalflux/.android`，被只读权限拒绝；已设置的 `ANDROID_USER_HOME` 未能改变该行为。因此沙箱内设备发现尚不可用，推荐本次使用 Windows 手动安装。不要为了通过检查而在默认 `~/.android` 目录创建文件。

调试结束后执行 `adb disconnect 手机IP:连接端口`，并在手机关闭无线调试；需要解除配对时，在手机“已配对设备”中选择此电脑并忘记。

官方操作依据：[Android Debug Bridge 无线连接说明](https://developer.android.com/tools/adb#connect-to-a-device-over-wi-fi)。

## 用户验收（待验证）

- [ ] APK 安装成功。
- [ ] 从桌面启动后能进入主界面，没有闪退。
- [ ] 退出应用后重新打开，仍能进入主界面。

反馈时记录手机型号、Android 版本、安装方式及以上结果即可；如失败，记录系统提示。无需提供账号、密码或配对码。
