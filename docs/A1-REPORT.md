# A1 改名与合规报告

执行日期：2026-10-19；分支：`cn`；起点：A0 `64b5e8f`。
仅执行 A1，未 commit / push；`PLAN.md` 已勾选。按本次用户指派，签名 release 和 tag 发布暂缓。

## 改动清单

- Android `applicationId`、`namespace`、MainActivity 包声明和路径统一为
  `io.github.t1mothychou86.papercart`；Manifest label 为 `Papercart`；Fastlane 包名同步更新。
- Flutter 标题、关于页、全部 18 个 ARB 的应用品牌文案、通知通道名称、Zotero 标签、
  导出日志和备份文件名更新。上游没有 `appName` 键，保留 `welcomeWispar` 等内部键和 Dart 包名
  `wispar`，避免无关的全仓导入改写。`wispar.db` 及备份内部文件名保留，维持导入兼容。
- 数据库 MethodChannel 在 Android 使用新包名，iOS 保留原生通道；未改变 iOS 平台标识。
  源 Manifest 没有旧包名深链接；插件 provider authority 随 applicationId 正确展开，见验证结果。
- 原创纸张与小车图标：`assets/cn/papercart.svg`、512×512 PNG、透明前景和单色前景。
  `scripts/generate_cn_icon.py` 仅用 Python 标准库，几何数据同时生成 SVG / PNG。
  使用已有 `flutter_launcher_icons`（锁定版本 0.14.4）和独立的
  `flutter_launcher_icons_cn.yaml` 生成 Android 五种密度 mipmap、自适应前景、背景及 monochrome。
  旧的备用 `launcher_icon.png` 也已替换；启动器、欢迎页、主页和关于页使用新图标。
  保留上游图标源文件供其他平台使用，最终 Android Flutter asset 包不包含旧 `assets/icon/icon.png`。
- README 开头注明 fork、Scriptbash、上游链接、GPL-3.0 和对应源码公开要求。
  `lib/cn/fork_credits.dart` 提供关于页致谢及上游链接；原有 Francis Lapointe 署名保留。
  关于页源码和问题链接指向本 fork；`LICENSE` 和原有版权声明未修改。
- 根目录和 `website/static/` 下的 CNAME 改名为 `CNAME.upstream-disabled`，保留原内容；
  README 说明停用原因。上游 `build.yml`、`docusaurus.yml`、`publish.yml` 保留为
  `.yml.disabled` 并在文件开头说明原因，GitHub 不会将其识别为 workflow。
  同时停用旧多平台 build，避免 PR 重复运行上游构建。上游商店文案仍作为历史素材保留，不用于本 fork 发布。
- 新增 `.github/workflows/cn-build.yml`：push 到 `cn`、任意 pull_request 时运行；
  JDK Temurin `25.0.4.1+1`、Flutter stable `3.47.5` 与本地一致；缓存 Gradle、Flutter 和 Pub；
  运行 A1 测试并构建 debug APK，以 `papercart-debug-apk` 上传，保存 14 天。
  仅有 `contents: read` 权限，不读取签名 Secrets，也不发布 release。
- 更新 `docs/DEVICE.md`，注明当前 A1 身份，保留 A0 历史说明。

图标重建命令（在仓库根目录执行）：

```bash
source scripts/env.sh
python3 scripts/generate_cn_icon.py
dart run flutter_launcher_icons -f flutter_launcher_icons_cn.yaml
```

没有新增依赖；`pubspec.lock` 未变。上游 `pubspec.yaml` 的跨平台图标配置保留，
Android 应使用上述独立配置，避免生成其他平台图标。

## 验证结果

所有 Flutter / Android 命令均先加载 `scripts/env.sh`，工具和缓存继续位于 `~/android-dev/`。
未改动上游 Gradle 构建参数；本机构建沿用 A0 的环境变量：

```bash
export GRADLE_OPTS='-Dorg.gradle.jvmargs=-Xmx3g -Dorg.gradle.workers.max=2 -Dorg.gradle.parallel=false -Dorg.gradle.daemon=false'
```

| 验证 | 结果 |
| --- | --- |
| `flutter analyze` | 退出 1，177 项 = 1 error + 5 warnings + 171 infos；按文件、级别、规则和次数比较 A0 日志，零新增、零移除（行号随修改移动） |
| `flutter test test/cn/` | 退出 0，4 项通过：全部 locale 欢迎与分享品牌、Android 身份、PNG 解码和图标差异、关于页致谢及链接 |
| `flutter test` | 退出 1，新增 4 项通过；仍只有上游 `test/widget_test.dart:16:35` 的 `MyApp` 缺失导致加载失败，与 A0 一致 |
| `flutter build apk --debug` | 退出 0；最终构建 32.57 秒 |
| `aapt dump badging` | 包名 `io.github.t1mothychou86.papercart`；application-label `Papercart`；启动 Activity 为新包下 MainActivity；图标引用自适应资源 |
| `apkanalyzer manifest print` | label 正确；打包 Manifest 无 `app.wispar.wispar` |
| APK ZIP 检查 | 包含新 Flutter PNG，未包含旧 Flutter 应用图标 |
| workflow 校验 | 本地无 `actionlint`；用 PyYAML BaseLoader 解析全部保留/启用 YAML，并断言新 workflow 的触发条件、只读权限、构建步骤与 artifact 上传；通过。此校验不等同于 actionlint 表达式检查 |
| `git diff --check` | 通过 |

APK 中 provider authority：

```text
io.github.t1mothychou86.papercart.fileProvider.com.crazecoder.openfile
io.github.t1mothychou86.papercart.flutter.share_provider
io.github.t1mothychou86.papercart.androidx-startup
```

APK：`build/app/outputs/flutter-apk/app-debug.apk`，242,017,972 bytes（约 230.8 MiB），
版本保留上游 `0.10.5+41`。

SHA-256：`6aef973e8f09a96d44a07db3a5828d0dbd0112144902a63c003e6722c5c34428`。

日志位于 `~/android-dev/logs/a1-*.log`、`a1-build-result.json` 和 `a1-apk-manifest.xml`，不进仓库。
CI 尚未在 GitHub 运行；需协调方审查并提交、推送后验证。真机安装、启动、图标遮罩及通知显示仍待验证。

## 本次保留的其他平台标识

| 平台 | 保留内容 |
| --- | --- |
| iOS | `app.wispar.wispar`，测试 target `com.example.wispar.RunnerTests`；嵌套旧工程另有 `com.example.wispar`；Info.plist 名称 Wispar / wispar、entitlement、原生 MethodChannel 与图标保留 |
| macOS | `app.wispar.wispar`、`app.wispar.wispar.RunnerTests`；product `wispar` / `wispar.app`、Info.plist 名称、版权及图标保留 |
| Windows | CMake project / binary `wispar`；runner 资源的 CompanyName `app.wispar`、产品信息和版权、`wispar.exe`、安装器设置及图标保留 |
| Linux | `app.wispar.wispar`、binary / 原生窗口名 `wispar` 保留 |

以上平台目录没有修改。共享 Flutter UI 品牌随本次改名显示 Papercart。
`Wispar Sync`、上游服务 URL、隐私政策和上游捐赠文案保留其真实服务/受益项目名称，
不替换成 Papercart 自有服务；这部分能力未在 A1 改造。

## 待用户决定 / 验证

1. release 签名密钥由谁生成、由谁保管；离线主副本和备份放在哪里、恢复责任归谁。
2. 后续 CI 签名材料如何放入 GitHub Secrets（密钥库、alias、口令），以及谁有维护权限；不进入仓库和日志。
3. 确定以上事项后，另行实现 tag / release 的签名和发布流程；每次 APK 发布须提供对应版本源码。
4. 真机安装当前 debug APK，验证启动、名称、图标和通知；协调方提交推送后核验 GitHub CI artifact。

建议提交信息：`A1: 完成 Papercart 安卓改名、原创图标、合规致谢与 debug CI`

CI 配置参照 [flutter-action 官方说明](https://github.com/subosito/flutter-action)、
[setup-java 官方说明](https://github.com/actions/setup-java) 和
[upload-artifact 官方说明](https://github.com/actions/upload-artifact)；版本同时以本地 A0 工具链和上游配置核对。
