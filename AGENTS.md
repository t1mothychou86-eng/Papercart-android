# AGENTS.md（Codex 工作约定：安卓国内版）

本仓库是 Wispar（https://github.com/Scriptbash/Wispar ，GPL-3.0）的 fork。方案见 [PLAN.md](PLAN.md)。

## 工作方式
- 按 PLAN.md §1 的里程碑**顺序**推进，**每次只做被指派的那一个**，做完就停下来汇报。
- **不要执行 git commit 或 push**（Codex 沙箱里的 `.git` 是只读的），由协调方（Claude）审查后提交。汇报时附上建议的提交信息，格式为 `A<n>: <摘要>`。
- 国内版的改动在 `cn` 分支上进行；`main` 只跟随上游，不做任何修改。
- 遇到以下情况时**停下来问**：
  - 需要账号、密钥或签名文件；
  - 需要决定 App 名称或包名；
  - 需要学校相关信息（IdP entityID、WebVPN 样例）；
  - 需要新增 `pubspec.yaml` 依赖；
  - 实测结论与 PLAN.md 的前提不一致。
- 不确定的外部事实（API 字段、模型名、出版商 URL 格式）**先查官方文档或实测，再写入**。

## 环境
- WSL Ubuntu，内存 7 GB，没有 sudo。工具链统一装在 `~/android-dev/` 下，通过 `scripts/env.sh` 引入。
- 不要在 `~/.pub-cache`、`~/.gradle`、`~/.android` 等默认位置写入，一律用环境变量把这些目录指到 `~/android-dev/` 下。
- 不要修改仓库中上游的构建参数，例如 `gradle.properties` 里的内存设置。需要调整时，用本地环境变量或命令行参数。

## 代码约定
- 国内特有的功能尽量放在 `lib/cn/` 下；改动上游文件时，保持最小改动，并在改动处加 `// CN:` 注释说明原因。
- 发给上游的修复放在 `upstream-fix/<主题>` 分支，不要混入国内特有的改动。
- 每个新功能都要写测试（`flutter test`）；`flutter analyze` 不能新增警告。

## 红线
- GPL-3.0：保留 LICENSE 和版权声明；不要删除上游作者署名；不要冒用 Wispar 的名称和图标发布。
- 不保存、不请求、不处理用户的学校账号或密码，不实现代为登录。
- 不实现批量或自动下载出版商 PDF 的功能（保留 Wispar 原有的、由用户逐篇手动触发的下载）。
- 签名密钥库、API Key、个人邮箱不得进入仓库或日志。
