# A4 开发与验证报告

2026-10-19，在 `cn` 分支 HEAD `6fe2a1e` 上完成；按协调方授权先做 A4，不涉及 A3。未 commit/push，未增加 pubspec 依赖，未修改上游构建参数或签名配置。所有 Flutter 命令先 source scripts/env.sh；未请求真实 ERSP 或 DOI 服务，未使用学校账号。

设计见 [DESIGN-A4.md](DESIGN-A4.md)，真机清单见 [DEVICE.md](DEVICE.md) A4 小节。PLAN.md 已勾选开发子项；A4 整体及真机验收保留待验证。

## 实现

- 新增 `lib/cn/institution_access.dart`：可配置 host、路径前缀、协议标记和 DOI 策略；改写、还原、幂等、端口/解析失败提示、系统 VPN、单次 HEAD DOI 解析及失败回退。
- 新增 `lib/cn/institution_choices.dart`：两个离线国内选项及 DOI 策略开关；复用上游 institution_name/institution_url 持久化，旧 EZproxy 数据和 knownUrls 流程保留。
- 文章打开、主框架 GET 导航、新窗口、用户选择的 OA PDF、手动 PDF 下载统一经过国内入口；按还原后的出版商主机识别 Wiley/ScienceDirect。登录交互交给 WebView，不读登录表单。Cookie/完整请求与响应头不写日志；国内访问使用正常 TLS 验证。
- 分享/复制从文章字段还原；Zotero 增加原始 URL 字段，并在 HTTP 发送边界再次还原，防止误传 ERSP 地址。

## 改动的上游文件（均加 CN 注释）

1. `lib/screens/institutions_screen.dart`：选择页顶部接入国内选项，不依赖远程列表成功。
2. `lib/screens/institutional_settings_screen.dart`：机构设置入口名称兼容国内方式。
3. `lib/screens/article_website.dart`：浏览器及手动下载入口、出版商识别、避免认证 Cookie 进入日志。
4. `lib/screens/article_screen.dart`：详情页分享、复制与 Zotero 原始地址参数。
5. `lib/widgets/publication_card/publication_card.dart`：卡片分享、复制与 Zotero 原始地址参数。
6. `lib/services/zotero_api.dart`：Zotero URL 字段及发送边界；可注入 HTTP client 进行离线请求体测试。

引导页无需改动：本来就调用共用机构选择页并持久化返回的 name/url。

## 验证

- `flutter test test/cn/ test/services/`：56 项全部通过，其中 A4 新增 32 项（规则与 DOI/Zotero 30、机构选择 UI 1、实际卡片复制/分享 UI 1）。所有 HTTP 测试使用 MockClient；分享与剪贴板使用平台通道拦截。
- 覆盖两个用户样例、Wiley/UChicago/AEA、http、默认/非默认端口、查询/fragment/编码、重复改写、还原、非法地址、登录页不重复改写、自定义规则、系统 VPN、偏好重载、DOI 两策略/单次 HEAD/无效 Location/网络错误、Zotero 实际 HTTP body、复制及分享平台参数。
- `flutter test`：56 项通过，只有上游既有 `test/widget_test.dart` 的 `MyApp` 不存在导致加载失败（退出 1）；未修改无关上游测试。
- `flutter analyze`：177 项（1 error、5 warnings、171 infos），与 HEAD 基线按诊断级别、文件、消息、规则及次数比较完全一致，零新增、零移除。退出 1 来自既有问题。基线分析使用 HEAD 源文件，完成后完整恢复工作区修改。
- `git diff --check`：通过。
- `flutter build apk --release --split-per-abi`：成功，使用已有 key.properties，不读取或打印密钥内容。最终构建耗时 108.9 秒；三个 APK 均经 `apksigner verify` 验证通过（只记录通过/失败，不打印证书或签名材料）。APK 列表见下；实际可用性仍须真机验证。

| ABI | APK 路径 | 大小（字节） |
|---|---|---|
| arm64-v8a | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` | 37,986,187 |
| armeabi-v7a | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` | 34,084,563 |
| x86_64 | `build/app/outputs/flutter-apk/app-x86_64-release.apk` | 39,732,825 |

## 待真机确认

ERSP 的 http 标记、查询参数与编码、PDF 代理、doi.org 直接代理及一次 HEAD 解析回退；WebView 登录 POST/认证跳转、跨出版商共享会话与重启后登录态；五本期刊全文和逐篇手动 PDF；aTrust 是否覆盖 Papercart 流量。ERSP 与 aTrust 分开验收。非默认端口固定回退原址，不假设支持。CARSI 未实现。

建议提交信息：`A4: 实现 ERSP 规则型机构访问及原始链接外发保护`
