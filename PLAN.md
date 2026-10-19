# 安卓国内版：基于 Wispar 的 fork（路线 C）

> 目标：在 Wispar（Flutter，GPL-3.0）的基础上，做一个面向国内经济金融学生的安卓 App。
> - 保留 Wispar 已有的能力：关注期刊、信息流、摘要、发送到 Zotero、App 内置浏览器。
> - 补上国内需要的部分：机构访问（CARSI / WebVPN）、工作论文源（复用 PaperCart 的 feed）、修好 AI 翻译。
>
> 实施由 Codex 推进，约定见 [AGENTS.md](AGENTS.md)。iPhone 端继续使用 PaperCart PWA（仓库 t1mothychou86-eng/readmobile）。

---

## 0. 原则

1. **分支**：`main` 只跟随上游（`upstream` = Scriptbash/Wispar），不做任何修改。国内版的改动都在 `cn` 分支上，定期把 `main` 合并进 `cn`。
2. **通用修复优先提交上游**：例如 null 拼接 bug、关闭思考模式、默认模型名。这类改动先在 `upstream-fix/*` 分支上做成独立的 PR 提给原作者，被合并后，`cn` 分支就不用自己维护这部分。
3. **改动集中**：国内特有的功能尽量放在新增的文件或目录里（建议 `lib/cn/`），对上游文件的改动越少越好，方便以后合并上游更新。
4. **GPL-3.0 合规**：
   - 保留 LICENSE 和原有版权声明；
   - 在 README 和“关于”页注明“基于 Wispar（Scriptbash）修改”，并附上游链接；
   - 修改过的文件标注修改说明；
   - 发布 APK 时必须同时公开对应的源码。
5. **品牌**：必须改掉包名、App 名称和图标，不能使用 Wispar 的名称和图标冒充原版。

## 1. 里程碑（Codex 按顺序推进，每完成一项就勾选并写一行说明）

- [x] **A0 工具链与原样编译** — 2026-10-19：工具链就绪，原样 debug APK 构建成功；上游 analyze/test 失败已记入 `docs/A0-REPORT.md`，真机待用户验证。
  - 在 `~/android-dev/` 下安装 Flutter（版本与 `pubspec.yaml` 中 `environment.flutter` 一致）、JDK（版本参考上游 `.github/workflows/build.yml`）、Android SDK 命令行工具及构建所需组件，并接受许可协议。
  - 不使用 sudo。所有缓存都放在 `~/android-dev/` 下：通过 `PUB_CACHE`、`GRADLE_USER_HOME`、`ANDROID_HOME`、`ANDROID_USER_HOME` 等环境变量指定。
  - 写一个 `scripts/env.sh`，`source` 之后就能使用这套工具链。
  - 在**未修改的上游代码**上执行 `flutter pub get`、`flutter analyze`、`flutter test`，然后执行 `flutter build apk --debug`。
  - 记录：版本号、耗时、APK 路径和大小；`flutter test`、`flutter analyze` 中上游原本就失败的项（如实记录，不修改）。
  - 本机内存只有 7 GB，如果 Gradle 内存不够，只能通过本地参数调整，不能改动仓库里的 `gradle.properties`。
  - 编译验收：已生成 debug APK，路径、大小与耗时见 `docs/A0-REPORT.md`。
  - [ ] 真机安装与启动（待用户验证）：由用户在安卓真机上安装并能启动（无线 adb 或手动安装均可，步骤见 `docs/DEVICE.md`）。
- [x] **A1 改名与合规** — 2026-10-19：Papercart 品牌、Android 包名、原创图标、fork 致谢及 debug CI 已完成；analyze 与 A0 的 177 项一致，APK 身份已验证，详见 `docs/A1-REPORT.md`。签名 release 补充已完成，见 `docs/A1-RELEASE-REPORT.md`。
  - 新包名（`applicationId` / `namespace`）、App 名称和图标，等用户确定名称后执行。
  - 删除或停用上游专属的配置，例如 `CNAME`、官网和商店发布相关的 workflow。
  - 在 README 开头写明 fork 关系和许可证；“关于”页加上致谢。
  - 新增 GitHub Actions：push 到 `cn` 和 pull_request 时构建 debug APK 并上传 artifact。
  - [x] **release 签名发布补充** — 2026-10-19：本地三 ABI release 构建及证书验证通过；新增 v* tag 发布 workflow、SHA256SUMS、Secrets 缺失检查和清理步骤；发版与密钥恢复见 `docs/RELEASE.md`。签名材料不进仓库；GitHub 实际发版、真机验证待协调方执行。
- [x] **A2 上游可合并的修复** — 2026-10-19：三个独立 main 基线补丁与英文 PR 描述已就绪（`docs/upstream-prs/`），同时应用于 cn；20 项新增测试通过，analyze 177 项与基线一致，详见 `docs/A2-REPORT.md`。因 .git 只读，由协调方建立对应 upstream-fix/* 分支。
  1. DeepSeek 和 ChatGPT 的流式解析：`delta.content` 不是字符串时跳过（目前会拼接出 "null"）。
  2. DeepSeek 翻译请求加上 `"thinking": {"type": "disabled"}`；默认模型名从已停用的 `deepseek-chat` 改为官方当前名称（实现前查官方文档确认）。
  3. 每个修复都附带单元测试，并写好英文 PR 描述（`docs/upstream-prs/*.md`），由用户决定何时提交。
  - 修复同时应用于 `cn` 工作区；Gemini 同类文本转换问题一并修复。旧 DeepSeek 模型名仅在官方端点迁移，第三方端点保留；默认模型以官方当前 API 文档为准。
- [ ] **A3 接入 PaperCart 工作论文源**
  - 读取 `https://t1mothychou86-eng.github.io/readmobile/data/feed.json`（schema 1），把 NBER、FEDS、ECB、BIS 的工作论文作为可关注的“源”加入信息流。
  - 按 DOI 或 id 去重；离线时读缓存。
  - 先阅读 Wispar 的 feed 和数据库结构，选择改动最小的接入方式，写入 `docs/DESIGN.md`。
- [ ] **A4 国内机构访问**（2026-10-19 决策，调研见 `docs/A4-SPIKE.md`；开发已完成，真机验收待用户验证，设计见 `docs/DESIGN-A4.md`）

  武汉大学共有三条校外访问途径：

  | 途径 | 依据 | 做法 |
  |---|---|---|
  | **图书馆 ERSP 网址改写**（主方案） | 用户提供的两个真实网址样例 | 按规则改写网址，在内置浏览器中打开；登录状态记在 `ersp.lib.whu.edu.cn` 这一个域名下，一次登录对各出版商通用 |
  | **aTrust 系统级 VPN**（第二方案） | 图书馆指南原文：“首次使用需安装 aTrust 客户端” | App 不改写网址，依赖系统级 VPN，需真机验证 |
  | **CARSI / WAYFless**（暂缓） | 馆方说明 CARSI 只覆盖部分数据库；武大的 IdP entityID 未能从官方元数据核实 | 暂不实现 |

  - **ERSP 改写规则**（由样例推出）：`https://ersp.lib.whu.edu.cn/s/` + 主机名各段倒序、以 `/` 连接 + `/G.<协议>` + 原路径。样例：
    - `https://www.sciencedirect.com/journal/journal-of-financial-economics/issues` → `https://ersp.lib.whu.edu.cn/s/com/sciencedirect/www/G.https/journal/journal-of-financial-economics/issues`
    - `https://academic.oup.com/rfs` → `https://ersp.lib.whu.edu.cn/s/com/oup/academic/G.https/rfs`
  - **还未确认，需真机验证**：http 协议的写法、非默认端口、查询参数的处理、`doi.org` 能否直接经 ERSP 访问、PDF 链接是否也能被改写。
  - **实现要求**：
    - [x] 做成通用的“规则型机构访问配置”（参数包括 host、协议标记格式等），与 Wispar 原有的 EZproxy 前缀方式并存。机构选择列表顶部加入“武汉大学（图书馆 ERSP）”和“系统 VPN（不改写，适用于 aTrust）”两项。
    - [x] 改写只作用于打开文章、在内置浏览器中导航和下载 PDF 的场景。**发送到 Zotero、分享、复制的链接一律使用原始网址**；对已经是 ERSP 格式的网址要能还原。
    - [x] 已改写的网址不能重复改写。遇到非默认端口或无法解析的网址时，不改写，打开原网址并给出提示。
    - [x] DOI 链接开发：按协调方要求，沙箱不真实访问 ERSP；默认假设可以代理 `doi.org`，机构页提供开关。关闭后用一次不跟随跳转的 HEAD 解析出版商 Location，再改写；失败回退原 DOI 并提示。ERSP 能否处理 DOI 与回退的实际可用性待真机确认。
    - [x] 测试：两个样例、Wiley 等其他主机、http、带端口、带查询参数、重复改写、还原、发送 Zotero 时使用原始网址。
  - 红线：不保存、不处理学校账号或密码，不代为登录（ERSP 登录完全由用户在内置浏览器中完成）。
  - [x] 开发验证：新增单元/UI/HTTP 边界测试、analyze 基线比较和三 ABI release 构建；详细结果见 `docs/A4-REPORT.md`。未新增依赖，未提交代码。
  - [ ] 真机验收（待用户验证，清单见 `docs/DEVICE.md` A4 小节）：
    - [ ] 首次打开文章时跳转到武大登录页，登录后能看到全文；
    - [ ] 关闭 App 再打开，是否还需要重新登录；
    - [ ] JFE、JF、RFS、JPE、AER 各打开一篇，记录能否看到全文、能否下载 PDF；
    - [ ] aTrust 方案单独测试，**两种方式不要同时开**（馆方原文提醒）。
- [ ] **A5（可选）** 接入国内大模型翻译（如通义千问，兼容 OpenAI 接口）、实测国内网络访问各接口的情况、界面中文化查漏。

## 2. 需要用户提供或决定的事项

| 事项 | 何时需要 |
|---|---|
| ~~GitHub 仓库~~ | 已完成：t1mothychou86-eng/Papercart-android（fork 自 Wispar） |
| ~~推送权限~~ | 已完成：部署密钥 |
| ~~App 名称和包名~~ | 已定：名称 **Papercart**，包名 `io.github.t1mothychou86.papercart` |
| ~~学校与访问方式~~ | 已提供：武汉大学；图书馆 ERSP 样例；`vpn.whu.edu.cn`（aTrust） |
| 安卓真机测试：安装 APK、配合登录测试 | A0 起 |

## 3. 风险

- **上游变化快**：通过“改动集中”和“通用修复提交上游”降低合并冲突。
- **内存**：本机 7 GB，Gradle 构建可能偏慢甚至内存不足。必要时，改为在 GitHub Actions 上构建。
- **发布与合规**：GPL 要求每个发布的 APK 都附带对应源码，以 GitHub Releases 加 tag 的方式满足。
