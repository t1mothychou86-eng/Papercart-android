# A1 release 签名验证

2026-10-19，在 cn（A1 d30fbff 基础，最终产物包含 A2 修复的工作区）执行；未 commit / push / 发布。
先加载 scripts/env.sh，沿用 A0 的本地 GRADLE_OPTS 内存和 worker 限制，未修改上游构建参数。
`flutter build apk --release --split-per-abi` 在 A1 补充及 A2 修复后分别执行，均退出 0；下表和校验和对应最终含 A2 的 APK。

本地 key.properties 权限 0600，已被 gitignore 忽略；密钥库保留在用户指定的仓库外目录。
密码、base64 和密钥库内容均未进入仓库、报告或终端输出。

使用 SDK apksigner 对三个 APK 分别执行 `verify --print-certs`，全部验证通过，证书 SHA-256 均与预期一致：
`E8:3E:78:C8:51:92:E1:18:F7:5F:9A:BE:B1:62:4A:47:70:D4:46:7C:D5:3E:5B:EA:9E:87:F4:64:F3:6B:5A:49`。

产物位于 `build/app/outputs/flutter-apk/`（已忽略）：

| APK | 字节 | MiB | MB（十进制） |
| --- | ---: | ---: | ---: |
| app-arm64-v8a-release.apk | 37,986,187 | 36.23 | 37.99 |
| app-armeabi-v7a-release.apk | 34,068,179 | 32.49 | 34.07 |
| app-x86_64-release.apk | 39,732,825 | 37.89 | 39.73 |

APK SHA-256（同时生成本地 SHA256SUMS）：

- `app-arm64-v8a-release.apk`：`3095d550c4cdbd9d0375e03a92e656a0638ca51351bc540d1520c81f1813e17c`
- `app-armeabi-v7a-release.apk`：`4a0877ce9e4fca3c36f82d42dbf5e62d3ab59da52f1cbbabea9e0cad2feb77cc`
- `app-x86_64-release.apk`：`b95f7d0d19689f26018fcc163cd51b11eaf405770afcd9f86cfb78f0bd13dbd8`

## 为什么 debug 大、release 大小是否合理

A0 实际为 205,843,783 bytes = 196.31 MiB = 205.84 MB；A1 为
242,017,972 bytes = 230.81 MiB = 242.02 MB。因此“196 到 242 MB”混用了单位，
同口径增加约 34.50 MiB（36.17 MB），不是 release 体积，也不是图标本身导致数十 MB 增长。

检查现存 A1 debug APK 的 ZIP 目录：三种 ABI 的 libflutter.so 合计约 106.9 MiB，
kernel_blob.bin 原始 107.3 MiB、压缩后约 35.0 MiB；另有约 14.5 MiB 的 Vulkan 验证层、
多个 ABI 的 PDFium / SQLite 等原生插件、多份 DEX 和调试快照。debug 包包含 JIT 调试代码和
调试引擎，且本次是三 ABI 通用包。A0 原 APK 未保留，不能对这 36.17 MB 增量作逐项可靠归因。

release 经过 AOT 编译、资源/图标裁剪及代码优化，每个 APK 只含一个 ABI；实测每份约 32–38 MiB。
以 arm64 为例，主要是 libapp.so 约 11.8 MiB、Flutter 引擎约 11.2 MiB、PDFium 约 6.1 MiB，
其余是 SQLite、Java 代码与资源。对包含 Flutter、PDF 阅读器和 WebView 插件的应用，此体积合理。
本次验证的是构建、包结构与签名；尚未进行安卓真机安装、启动和覆盖升级测试。

## 自动发布检查

新增 cn-release.yml，push v* tag 触发；权限仅 contents: write。
缺少任何签名 Secret 都以名称给出明确错误；签名文件置于临时目录和已忽略的 key.properties，
always() 步骤清理，APK 与 SHA256SUMS 由 softprops/action-gh-release@v3 上传。
Release 说明包含 GPL-3.0、Wispar 来源及精确 tag 的源码树/归档链接。

本地 PyYAML BaseLoader 解析、结构断言、所有 run 步骤 bash -n、内嵌 Python compile 通过；
使用模拟材料验证缺失 Secret 失败、还原文件权限和清理成功。
没有运行 GitHub Actions；需要协调方配置 Secrets 并推送正式 tag 后验证。
发版和备份/恢复步骤见 [RELEASE.md](RELEASE.md)。
