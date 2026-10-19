# A2 上游修复报告

2026-10-19；当前分支 cn；未 commit / push，未修改 main 或 .git。
修复、测试均已应用于 cn 工作区。两个 CI workflow 现在都运行品牌和翻译修复的定向测试。

## 独立补丁

本仓库 .git 为只读，按本次授权提供补丁而不创建分支或 worktree。
每个补丁独立基于 main `289919df407b33c55a60518ae95e6c42aad08fe3`，不依赖另两个补丁。
每个主题同名 `.md` 为英文 PR 描述，包含建议分支、测试命令和提交信息。
补丁中无 cn 品牌改动或 CN 注释；cn 修改处的 CN 注释用于标记修复来源。

| 主题 / 建议分支后缀 | 修复内容 | 新测试 |
| --- | --- | ---: |
| [stream-content-types](upstream-prs/stream-content-types.patch) | DeepSeek 和 ChatGPT 仅拼接字符串 delta.content；null、数值、布尔、数组、对象等跳过，合法的字符串 `null` 保留 | 2 |
| [gemini-content-types](upstream-prs/gemini-content-types.patch) | Gemini part.text 同样只接受字符串；非 map part、非文本 part 跳过，保留文本顺序 | 1 |
| [deepseek-models](upstream-prs/deepseek-models.patch) | 默认 deepseek-flash，翻译请求显式 thinking disabled，统一 provider / 设置页 / 聊天回退的默认值及旧配置迁移 | 17 |

模型依据重新访问并核验了 [当前 API 参考](https://api-docs.deepseek.com/api/create-chat-completion/)
及 [2026-04-24 公告](https://api-docs.deepseek.com/news/news260424/)。
当前参考列出 deepseek-flash / deepseek-v4-pro，默认启用思考模式；公告确认旧别名
于 2026-07-24 15:59 UTC 后停用。公告里的当时 Flash 名称属于历史版本，以当前 API 参考为准。

已保存 deepseek-chat / deepseek-reasoner 的用户，在使用官方接口时自动迁移到 deepseek-flash，
并持久保存；再次加载幂等。显式选择的现行或其他模型名保留。
第三方自定义服务端可能仍支持旧别名，故不替它们改名；自定义 URL 若为精确官方 host 则迁移，
相似域名不迁移。未配置、空模型名回退到新默认值。
翻译始终请求非思考模式，不改变其他提供商的请求参数。

协调方可以为每个主题执行（需在有写入 .git 权限的环境中，先审查补丁）：

```bash
git switch -c upstream-fix/stream-content-types main
git apply /path/to/cn/docs/upstream-prs/stream-content-types.patch
flutter test test/services/translations/stream_content_test.dart
```

另两个主题分别从 main 新建分支；不应从 cn 新建上游修复分支。
提交到上游的内容是补丁本身，PR 文案使用相邻同名 md。

## 验证

- 所有命令先加载 scripts/env.sh；未增加 pubspec 依赖，未修改构建参数和锁文件。
- `flutter test test/services/translations/ test/cn/`：24 项通过（新增 20 + A1 品牌 4）。
- `flutter test`：24 项通过，仍只有既有的 test/widget_test.dart 引用不存在的 MyApp 而加载失败；退出 1。
- `flutter analyze`：177 项 = 1 error + 5 warnings + 171 infos；按文件、诊断信息、级别、规则、次数比较修改前后，零新增、零移除；退出 1 为上游既有问题。
- 导出纯 main 到临时源码目录，逐个 `git apply --check`、应用、执行各自测试、反向移除：三个独立补丁全部通过（2 / 1 / 17 项）。
- 三个补丁再组合应用，结果与 cn 的相关源码和测试逐字一致（仅排除 cn 来源注释）。
- cn-build / cn-release YAML 解析、内嵌 shell 语法检查通过。release 还原逻辑使用模拟材料验证，包括特殊字符及 Unicode；无真实签名材料进入测试。
- `git diff --check` 通过；签名材料扫描只给出通过/失败，不打印值；本地 key.properties 仍为 0600 且被忽略。

最终 release 构建和签名信息见 [A1 release 验证报告](A1-RELEASE-REPORT.md)。
日志位于仓库外 `~/android-dev/logs/a2-*.log`。
真机安装、启动、升级与真实翻译调用尚未验证；没有请求或使用真实模型 API Key。
