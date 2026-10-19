# A4 国内机构访问设计

依据 PLAN.md 2026-10-19 新决策；A4-SPIKE.md 的“暂不实施”结论已被取代。本次只做 A4，顺序例外由协调方授权。

## 上游现状与接入

- `article_website.dart` 从 SharedPreferences 读取 `institution_url`，去掉 `$@` 后作为 EZproxy 前缀拼接文章网址；`knownUrls` 保存按出版商的成功/失败反馈。原来没有通用导航改写。
- `institutions_screen.dart` 从 libproxy-db 取得机构，返回 `{name,url}`。设置页和引导页分别把结果存入 `institution_name/institution_url`。国内配置使用 `cn:whu-ersp` / `cn:system-vpn` 标识，沿用保存路径，不把标识当作真实代理前缀；旧 EZproxy 数据无需迁移。
- `publication_card.dart` 和 `article_screen.dart` 的分享、复制使用 `widget.url`，不会读取浏览器当前网址。新增统一原址函数以处理文章字段本身已被改写的情况。Zotero 原先仅传 DOI 等元数据，URL 留空；增加可选文章 URL 参数，并在发送边界统一还原。

## 国内规则与浏览器

`lib/cn/institution_access.dart` 包含可配置网关 host、路径前缀、协议标记模板、DOI 策略；纯函数负责改写与还原。保留编码后的路径、查询和 fragment，默认端口可改写；非默认端口、非法主机、非 HTTP(S)、含用户信息或无法解析的网址原样返回并提示。网关域名的所有路径（含登录页）均不重复改写；只有合法资源路径才还原。支持系统 VPN：打开原址，不改写。

文章首次加载（含用户选择的 Unpaywall PDF）、WebView 主框架 GET 导航、新窗口、JS 返回 PDF 地址以及用户手动下载均接入同一入口。ERSP 不使用 EZproxy 的 knownUrls 成败反馈。POST 不重放，子资源依赖 ERSP 自身改写；不实现网页脚本/请求体改写。PDF 保留上游的用户逐篇手动流程，下载前改写，先还原到出版商地址执行原有 Wiley 路径修正，避免把 ERSP 的 host 拼到出版商路径上。国内下载只接受正常 TLS 证书，不继承上游放行代理证书逻辑；仅同源下载携带当前页面 Cookie，重定向沿用 Dart HttpClient（本地 SDK 源码确认跨 origin 会去掉 Cookie 等敏感头）。

## DOI 假设与解析回退

沙箱不访问 ERSP。默认假设可直接代理 doi.org（配置项 `cn_ersp_proxy_doi`，机构页开关）；关闭后仅对 doi.org / dx.doi.org 发送一次 HEAD，禁止自动跟随跳转，超时 8 秒。只接受 HTTP(S) 出版商 Location，不请求该 Location、不请求全文、不下载。失败时打开原 DOI 并提示，避免捏造出版商地址。解析器使用现有 http 依赖，可注入 MockClient 测试；没有新增依赖。

## 外发边界与验证

`originalArticleUrl` 独立于当前选择，能还原已知 ERSP 资源网址；`articleUrlForExport` 为 Zotero、分享、复制的共同边界。它们始终处理原文章字段，不使用浏览器会话网址。使用单元测试覆盖样例、其他主机、端口/查询/编码、重复改写、还原、可配置规则、DOI 两策略/失败及持久化；外发接入通过真实文章卡片的复制/分享 UI（拦截平台通道）及 Zotero HTTP 请求体断言验证。

登录仅在 WebView 内由用户自行操作；不读取表单或账户密码。移除上游下载处会打印 Cookie/全量请求头的日志，避免会话凭据进入日志。登录态仍由 WebView Cookie 存储管理，持久化、认证跳转及各出版商 PDF 必须真机验收，见 DEVICE.md。
