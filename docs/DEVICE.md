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

## A4 国内机构访问（待用户验证）

开发及沙箱测试已完成；这里所有实测项仍待用户验证。安装 `build/app/outputs/flutter-apk/` 中适合手机 ABI 的 release APK（多数手机使用 `app-arm64-v8a-release.apk`）。设计与假设见 [DESIGN-A4.md](DESIGN-A4.md)。不要提供账号、密码、Cookie 或含认证参数的完整登录 URL；只反馈成功/失败及去除敏感信息的现象。

- [ ] 在“机构访问 / EZproxy”选择页顶部可看到“武汉大学（图书馆 ERSP）”和“系统 VPN（不改写，适用于 aTrust）”；远程 EZproxy 列表加载失败也能选择。引导页同样可选择。
- [ ] 选择 ERSP，关闭 aTrust/其他 VPN，在校外网络打开文章，进入武大 ERSP 登录页；由用户自行登录，之后可回到原文并看到全文。切换出版商后不重复要求登录。
- [ ] 完全关闭并重开 App：机构选项保留；记录是否仍需重新登录（WebView Cookie 会话持久化尚未实测）。
- [ ] 文章内点击链接、返回/前进、打开新窗口、点击 PDF：仍在正确的 ERSP 会话下，没有重复的 `/s/.../G.https` 前缀。认证 POST、跨域认证及跳转须实际确认；子资源依赖 ERSP 改写。
- [ ] 分别打开 JFE、JF、RFS、JPE、AER 各一篇属于武大订阅范围的文章，逐篇手动点击 PDF 下载，在 App 中打开文件；不可批量或自动下载。填写下表。

| 期刊 | 全文可读 | 手动 PDF 下载/打开 | 问题现象（不含身份凭据） |
|---|---|---|---|
| JFE / ScienceDirect | 待验证 | 待验证 | |
| JF / Wiley | 待验证 | 待验证 | |
| RFS / OUP | 待验证 | 待验证 | |
| JPE / UChicago | 待验证 | 待验证 | |
| AER / AEA | 待验证 | 待验证 | |

- [ ] ERSP 的 `G.http` 写法、查询参数/编码、fragment 和 PDF URL 是否按推导规则工作。非默认端口当前一律回退原网址并提示；不假设网关支持它。
- [ ] “ERSP 直接打开 DOI”默认开启：检查 doi.org 能否经 ERSP 到达正确全文；若失败，关闭开关再次打开 DOI，检查一次 HEAD 解析出版商地址的回退方式。记录是否遇到 HEAD 不支持、解析失败或多级 DOI 跳转（当前只读一次 Location，不跟随全文）。解析失败应提示并打开原 DOI。
- [ ] 在文章卡片及文章详情页分别测试分享、复制链接和发送到 Zotero（含默认集合直发及选择集合发送）：链接为出版商原址或原 DOI，不含 ERSP 网关；Zotero URL 字段应非空且为原始文章地址。浏览器跳转到 PDF/登录页不应改变外发文章链接。
- [ ] 分别切换 ERSP → 系统 VPN → 旧 EZproxy → 无机构，重启后选择仍正确；无机构不应出现 `Nonehttps://...` 拼接。
- [ ] aTrust 单独验收：先关闭 ERSP（选择“系统 VPN”），按学校指南在系统客户端连接，再在 Papercart 内打开同一文章；对照系统浏览器确认流量确实覆盖 Papercart，并测试全文和手动 PDF。**ERSP 与 aTrust 不要同时使用。** 若只在 aTrust 自带浏览器可用，反馈此现象；不将其视为已验证的系统 VPN 接入。

反馈记录手机型号、Android 版本、APK ABI、网络环境、选中的访问方式和上述结果即可。CARSI / WAYFless 本次未实现。
