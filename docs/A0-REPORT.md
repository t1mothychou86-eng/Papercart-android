# A0 工具链与原样编译报告

执行日期：2026-10-19。分支：`cn`。基线提交：`a15007c76d69cd23ef2f8c4e8b725d908831559c`。

## 当前结论

**A0 工具链与原样编译已完成，debug APK 构建成功。** 真机安装和启动待用户验证，步骤见 [DEVICE.md](DEVICE.md)。analyze / test 存在下述上游原有失败，未做修复。

未修改上游源码、依赖声明、锁文件或构建参数。没有执行 commit/push。未应用上游 workflow 中的 dartjni 缓存补丁。

## 环境与版本

| 工具 | 版本 |
| --- | --- |
| 系统 | WSL2 / Ubuntu 22.04.5 LTS，约 7.7 GiB 内存、2 GiB swap |
| Flutter | stable 3.47.5，framework `6a19cca564`，engine `af7e796e16` |
| Dart / DevTools | 3.13.4 / 2.60.0 |
| JDK | Eclipse Temurin 25.0.4.1+1（按上游 CI 的 JDK 25 要求） |
| Android Command-line Tools | 22.0（下载包 15859902） |
| Android Platform | API 36 r2；依赖自动安装 API 34 r3、API 35 r2 |
| Android Build-Tools | 36.0.0 |
| Android Platform-Tools | 37.0.1 |
| NDK | 29.0.14206865 |
| 依赖额外要求的 NDK | 28.2.13676358（Gradle 自动安装完成） |
| CMake / Ninja | 3.22.1-g37088a8 / 1.10.2 |
| Gradle | 9.7.1（上游 wrapper 指定） |
| Android Gradle Plugin / Kotlin | 9.4.1 / 2.4.20（上游配置，构建成功） |

工具链位于 `/home/tidalflux/android-dev/`。`source scripts/env.sh` 设置 Flutter、JDK、SDK、CMake/Ninja 路径，以及 Pub、Gradle、Android 用户目录、XDG 目录、TMPDIR 和 Dart analyzer 状态目录；不改变系统 HOME。

SDK 许可通过 `sdkmanager --licenses` 接受。SDK 组件安装命令：

```bash
source scripts/env.sh
sdkmanager --sdk_root="$ANDROID_HOME" \
  'platform-tools' 'platforms;android-36' 'build-tools;36.0.0' \
  'ndk;29.0.14206865' 'cmake;3.22.1'
```

JDK 及命令行工具从上次中断的文件续传，完整文件均已校验：

- [Temurin 官方发布包](https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4.1%2B1/OpenJDK25U-jdk_x64_linux_hotspot_25.0.4.1_1.tar.gz)，SHA-256：`dbb698396d478e7fa2b1e50f4103324b2a99b90569ee27c33f2261f9215cf41e`；官方元数据保存在 `~/android-dev/downloads/temurin25-assets.json`。
- [Android 官方命令行工具包](https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip)，SHA-256：`4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583`，校验值来源：[官方下载页](https://developer.android.com/studio#command-tools)。
- Flutter 使用上次已核对 SHA-256 的安装包；本次确认 `flutter --version` 能正常显示 3.47.5。

## 命令与耗时

使用单调时钟测量完整命令墙钟时间（含命令自己的依赖解析），下表仅代表本次运行；上次 Flutter 解压日志另记录 46.53 秒，历史下载总耗时不可恢复。

| 步骤 | 秒 | 退出码 |
| --- | ---: | ---: |
| `download_jdk_resume` | 5.71 | 0 |
| `extract_jdk` | 1.71 | 0 |
| `download_android_tools_resume` | 85.37 | 0 |
| `extract_android_tools` | 0.31 | 0 |
| `sdk_list` | 3.93 | 0 |
| `sdk_licenses` | 0.96 | 0 |
| `sdk_install` | 651.42 | 0 |
| `doctor` | 46.95 | 0 |
| `pub_get` | 66.42 | 0 |
| `analyze` | 2.45 | 255 |
| `analyze_retry` | 20.32 | 1 |
| `test` | 46.70 | 1 |
| `build_debug` | 2305.87 | 0 |

步骤标签 `doctor`、`pub_get`、`analyze`、`analyze_retry`、`test` 分别对应 `flutter doctor -v`、`flutter pub get`、首次 `flutter analyze`、环境修正后的 `flutter analyze`、`flutter test`，按顺序执行。

本地原始日志：`~/android-dev/logs/*.log`；计时：`~/android-dev/logs/a0-steps.jsonl`。日志不进入仓库。

## doctor 与环境问题

- Flutter、Android toolchain、所有 Android 许可和 Network resources 通过。doctor 退出码为 0，不代表所有检查均通过。
- 未安装 Chrome、桌面 Linux 所需 clang++ / pkg-config；未为本次安卓构建安装这些桌面工具。
- Connected device 检查崩溃：adb 37.0.1 尝试创建 `/home/tidalflux/.android`，被沙箱只读权限拒绝。`ANDROID_USER_HOME` 未能重定向此行为；没有在该默认目录写入文件。真机验证优先通过 Windows 手动安装。
- 首次 analyze 因尝试创建 `/home/tidalflux/.dartServer` 失败（退出码 255）。依据已安装 analyzer 源码，设置 `ANALYZER_STATE_LOCATION_OVERRIDE=~/android-dev/dart-server` 后重跑，获得下列完整基线结果。
- pub get 成功，未升级依赖。提示 77 个包有不兼容当前约束的新版本，并提示多种语言有未翻译消息（其中 zh 为 389 条）；均未修改。

## 上游原有 analyze / test 结果

analyze 重跑退出码 1：**177 项 = 1 error + 5 warnings + 171 infos**。唯一 error 为 `test/widget_test.dart:16:35` 的 `creation_with_non_type`：`MyApp` 不是现存类。

5 个 warning：

| 位置 | 规则 |
| --- | --- |
| `lib/screens/article_website.dart:407:71` | `body_might_complete_normally_nullable` |
| `lib/screens/chat_screen.dart:49:10` | `unused_field` |
| `lib/screens/chat_screen.dart:62:8` | `unused_field` |
| `lib/screens/database_settings_screen.dart:34:7` | `unused_field` |
| `lib/screens/zotero_settings_screen.dart:21:11` | `unused_field` |

`flutter test` 退出码 1：唯一测试文件 `test/widget_test.dart` 在加载时编译失败，找不到 `MyApp` 构造函数（16:35）；0 个测试通过、1 个加载失败。保持上游测试不变。

全部静态检查项（位置、级别和规则，供后续对比基线）：

<details>
<summary>展开 177 项</summary>

| 级别 | 位置 | 规则 |
| --- | --- | --- |
| info | `lib/main.dart:169:34` | `use_build_context_synchronously` |
| info | `lib/models/crossref_journals_models.dart:127:13` | `constant_identifier_names` |
| info | `lib/models/crossref_journals_models.dart:127:25` | `constant_identifier_names` |
| info | `lib/models/openAlex_works_models.dart:1:1` | `file_names` |
| info | `lib/screens/ai_settings_screen.dart:53:7` | `prefer_final_fields` |
| info | `lib/screens/ai_settings_screen.dart:119:39` | `prefer_is_empty` |
| info | `lib/screens/ai_settings_screen.dart:473:44` | `use_build_context_synchronously` |
| info | `lib/screens/ai_settings_screen.dart:476:53` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:345:38` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:348:47` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:381:38` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:384:47` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:462:28` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:463:43` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:797:41` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:859:52` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:862:78` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:863:78` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:1041:9` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:1056:38` | `use_build_context_synchronously` |
| info | `lib/screens/article_screen.dart:1061:7` | `use_build_context_synchronously` |
| info | `lib/screens/article_website.dart:160:45` | `use_build_context_synchronously` |
| info | `lib/screens/article_website.dart:234:41` | `use_build_context_synchronously` |
| info | `lib/screens/article_website.dart:272:43` | `use_build_context_synchronously` |
| info | `lib/screens/article_website.dart:331:50` | `use_build_context_synchronously` |
| info | `lib/screens/article_website.dart:333:67` | `use_build_context_synchronously` |
| warning | `lib/screens/article_website.dart:407:71` | `body_might_complete_normally_nullable` |
| info | `lib/screens/article_website.dart:435:53` | `use_build_context_synchronously` |
| info | `lib/screens/article_website.dart:440:53` | `use_build_context_synchronously` |
| info | `lib/screens/article_website.dart:1044:57` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:39:30` | `prefer_final_fields` |
| warning | `lib/screens/chat_screen.dart:49:10` | `unused_field` |
| warning | `lib/screens/chat_screen.dart:62:8` | `unused_field` |
| info | `lib/screens/chat_screen.dart:195:48` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:223:33` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:231:47` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:254:47` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:268:48` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:293:33` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:300:45` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:401:16` | `unnecessary_brace_in_string_interps` |
| info | `lib/screens/chat_screen.dart:401:33` | `unnecessary_brace_in_string_interps` |
| info | `lib/screens/chat_screen.dart:402:72` | `unnecessary_brace_in_string_interps` |
| info | `lib/screens/chat_screen.dart:491:35` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:502:35` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:518:33` | `use_build_context_synchronously` |
| info | `lib/screens/chat_screen.dart:523:45` | `use_build_context_synchronously` |
| info | `lib/screens/crossref_journals_search_results_screen.dart:5:65` | `library_prefixes` |
| warning | `lib/screens/database_settings_screen.dart:34:7` | `unused_field` |
| info | `lib/screens/database_settings_screen.dart:134:35` | `use_build_context_synchronously` |
| info | `lib/screens/downloads_screen.dart:9:9` | `use_super_parameters` |
| info | `lib/screens/downloads_screen.dart:12:3` | `library_private_types_in_public_api` |
| info | `lib/screens/downloads_screen.dart:26:8` | `prefer_final_fields` |
| info | `lib/screens/downloads_screen.dart:49:28` | `use_build_context_synchronously` |
| info | `lib/screens/downloads_screen.dart:50:52` | `use_build_context_synchronously` |
| info | `lib/screens/favorites_screen.dart:31:8` | `prefer_final_fields` |
| info | `lib/screens/favorites_screen.dart:113:48` | `use_build_context_synchronously` |
| info | `lib/screens/favorites_screen.dart:124:28` | `use_build_context_synchronously` |
| info | `lib/screens/favorites_screen.dart:125:52` | `use_build_context_synchronously` |
| info | `lib/screens/favorites_screen.dart:206:26` | `use_build_context_synchronously` |
| info | `lib/screens/favorites_screen.dart:209:61` | `use_build_context_synchronously` |
| info | `lib/screens/favorites_screen.dart:220:46` | `use_build_context_synchronously` |
| info | `lib/screens/home_screen.dart:414:30` | `use_build_context_synchronously` |
| info | `lib/screens/home_screen.dart:907:50` | `use_build_context_synchronously` |
| info | `lib/screens/home_screen.dart:959:51` | `use_build_context_synchronously` |
| info | `lib/screens/institutional_settings_screen.dart:228:14` | `unnecessary_to_list_in_spreads` |
| info | `lib/screens/institutions_screen.dart:6:7` | `use_key_in_widget_constructors` |
| info | `lib/screens/institutions_screen.dart:8:3` | `library_private_types_in_public_api` |
| info | `lib/screens/library_screen.dart:11:3` | `library_private_types_in_public_api` |
| info | `lib/screens/openalex_journal_results_screen.dart:5:65` | `library_prefixes` |
| info | `lib/screens/pdf_reader.dart:173:44` | `use_build_context_synchronously` |
| info | `lib/screens/pdf_reader.dart:174:61` | `use_build_context_synchronously` |
| info | `lib/screens/pdf_reader.dart:187:44` | `use_build_context_synchronously` |
| info | `lib/screens/pdf_reader.dart:189:51` | `use_build_context_synchronously` |
| info | `lib/screens/search_screen.dart:10:3` | `library_private_types_in_public_api` |
| info | `lib/screens/settings_screen.dart:193:22` | `use_build_context_synchronously` |
| info | `lib/screens/settings_screen.dart:203:49` | `use_build_context_synchronously` |
| info | `lib/screens/settings_screen.dart:210:49` | `use_build_context_synchronously` |
| info | `lib/screens/settings_screen.dart:214:37` | `use_build_context_synchronously` |
| info | `lib/screens/settings_screen.dart:388:28` | `use_build_context_synchronously` |
| warning | `lib/screens/zotero_settings_screen.dart:21:11` | `unused_field` |
| info | `lib/screens/zotero_settings_screen.dart:151:62` | `use_build_context_synchronously` |
| info | `lib/screens/zotero_settings_screen.dart:155:67` | `use_build_context_synchronously` |
| info | `lib/screens/zotero_settings_screen.dart:164:62` | `use_build_context_synchronously` |
| info | `lib/screens/zotero_settings_screen.dart:168:67` | `use_build_context_synchronously` |
| info | `lib/services/abstract_helper.dart:36:31` | `use_build_context_synchronously` |
| info | `lib/services/background_service.dart:171:34` | `deprecated_member_use` |
| info | `lib/services/crossref_api.dart:3:65` | `library_prefixes` |
| info | `lib/services/crossref_api.dart:5:8` | `library_prefixes` |
| info | `lib/services/feed_api.dart:5:8` | `library_prefixes` |
| info | `lib/services/logs_helper.dart:71:28` | `use_build_context_synchronously` |
| info | `lib/services/logs_helper.dart:74:42` | `use_build_context_synchronously` |
| info | `lib/services/logs_helper.dart:78:28` | `use_build_context_synchronously` |
| info | `lib/services/logs_helper.dart:80:47` | `use_build_context_synchronously` |
| info | `lib/services/logs_helper.dart:106:37` | `use_build_context_synchronously` |
| info | `lib/services/logs_helper.dart:111:28` | `use_build_context_synchronously` |
| info | `lib/services/logs_helper.dart:113:47` | `use_build_context_synchronously` |
| info | `lib/services/mathml_converter.dart:85:26` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/mathml_converter.dart:85:51` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/mathml_converter.dart:87:26` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/mathml_converter.dart:125:42` | `deprecated_member_use` |
| info | `lib/services/mathml_converter.dart:148:61` | `unnecessary_string_escapes` |
| info | `lib/services/mathml_converter.dart:152:61` | `unnecessary_string_escapes` |
| info | `lib/services/mathml_converter.dart:187:60` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/mathml_converter.dart:188:58` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/mathml_converter.dart:189:55` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/mathml_converter.dart:211:50` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/mathml_converter.dart:213:31` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/mathml_converter.dart:215:65` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/mathml_converter.dart:216:69` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/mathml_converter.dart:218:34` | `prefer_interpolation_to_compose_strings` |
| info | `lib/services/openAlex_api.dart:1:1` | `file_names` |
| info | `lib/services/openAlex_api.dart:6:8` | `library_prefixes` |
| info | `lib/services/unpaywall_api.dart:35:56` | `unnecessary_brace_in_string_interps` |
| info | `lib/services/zotero_api.dart:294:32` | `use_build_context_synchronously` |
| info | `lib/services/zotero_api.dart:295:47` | `use_build_context_synchronously` |
| info | `lib/services/zotero_api.dart:300:32` | `use_build_context_synchronously` |
| info | `lib/services/zotero_api.dart:301:47` | `use_build_context_synchronously` |
| info | `lib/services/zotero_api.dart:305:30` | `use_build_context_synchronously` |
| info | `lib/services/zotero_api.dart:307:33` | `use_build_context_synchronously` |
| info | `lib/services/zotero_api.dart:315:28` | `use_build_context_synchronously` |
| info | `lib/services/zotero_api.dart:317:45` | `use_build_context_synchronously` |
| info | `lib/widgets/article_crossref_search_form.dart:59:25` | `use_build_context_synchronously` |
| info | `lib/widgets/article_crossref_search_form.dart:61:13` | `use_build_context_synchronously` |
| info | `lib/widgets/article_crossref_search_form.dart:80:25` | `use_build_context_synchronously` |
| info | `lib/widgets/article_crossref_search_form.dart:81:32` | `use_build_context_synchronously` |
| info | `lib/widgets/article_crossref_search_form.dart:82:56` | `use_build_context_synchronously` |
| info | `lib/widgets/article_crossref_search_form.dart:89:21` | `use_build_context_synchronously` |
| info | `lib/widgets/article_crossref_search_form.dart:90:28` | `use_build_context_synchronously` |
| info | `lib/widgets/article_crossref_search_form.dart:91:52` | `use_build_context_synchronously` |
| info | `lib/widgets/article_doi_search_form.dart:6:3` | `use_key_in_widget_constructors` |
| info | `lib/widgets/article_doi_search_form.dart:6:3` | `prefer_const_constructors_in_immutables` |
| info | `lib/widgets/article_openAlex_search_form.dart:1:1` | `file_names` |
| info | `lib/widgets/article_openAlex_search_form.dart:245:21` | `use_build_context_synchronously` |
| info | `lib/widgets/article_openAlex_search_form.dart:247:9` | `use_build_context_synchronously` |
| info | `lib/widgets/article_openAlex_search_form.dart:264:21` | `use_build_context_synchronously` |
| info | `lib/widgets/article_openAlex_search_form.dart:265:28` | `use_build_context_synchronously` |
| info | `lib/widgets/article_query_search_form.dart:373:21` | `use_build_context_synchronously` |
| info | `lib/widgets/article_query_search_form.dart:377:9` | `use_build_context_synchronously` |
| info | `lib/widgets/article_query_search_form.dart:386:21` | `use_build_context_synchronously` |
| info | `lib/widgets/article_query_search_form.dart:389:28` | `use_build_context_synchronously` |
| info | `lib/widgets/article_query_search_form.dart:390:52` | `use_build_context_synchronously` |
| info | `lib/widgets/article_search_form.dart:5:7` | `use_key_in_widget_constructors` |
| info | `lib/widgets/article_search_form.dart:7:3` | `library_private_types_in_public_api` |
| info | `lib/widgets/author_search_form.dart:3:7` | `use_key_in_widget_constructors` |
| info | `lib/widgets/author_search_form.dart:5:3` | `library_private_types_in_public_api` |
| info | `lib/widgets/author_search_form.dart:37:15` | `avoid_print` |
| info | `lib/widgets/custom_feed_bottom_sheet.dart:440:48` | `use_build_context_synchronously` |
| info | `lib/widgets/custom_feed_bottom_sheet.dart:442:67` | `use_build_context_synchronously` |
| info | `lib/widgets/custom_feed_bottom_sheet.dart:482:39` | `use_build_context_synchronously` |
| info | `lib/widgets/downloaded_card.dart:72:31` | `use_build_context_synchronously` |
| info | `lib/widgets/downloaded_card.dart:100:44` | `use_build_context_synchronously` |
| info | `lib/widgets/downloaded_card.dart:103:51` | `use_build_context_synchronously` |
| info | `lib/widgets/journal_card.dart:12:9` | `use_key_in_widget_constructors` |
| info | `lib/widgets/journal_follow_button.dart:3:65` | `library_prefixes` |
| info | `lib/widgets/journal_header.dart:3:65` | `library_prefixes` |
| info | `lib/widgets/journal_search_form.dart:5:65` | `library_prefixes` |
| info | `lib/widgets/journal_search_results_card.dart:3:53` | `library_prefixes` |
| info | `lib/widgets/journal_search_results_card.dart:12:9` | `use_super_parameters` |
| info | `lib/widgets/journal_search_results_card.dart:17:3` | `library_private_types_in_public_api` |
| info | `lib/widgets/publication_card/publication_card.dart:444:38` | `use_build_context_synchronously` |
| info | `lib/widgets/publication_card/publication_card.dart:453:18` | `use_build_context_synchronously` |
| info | `lib/widgets/publication_card/publication_card.dart:484:22` | `use_build_context_synchronously` |
| info | `lib/widgets/publication_card/publication_card.dart:514:9` | `use_build_context_synchronously` |
| info | `lib/widgets/publication_card/publication_card.dart:535:38` | `use_build_context_synchronously` |
| info | `lib/widgets/publication_card/publication_card.dart:540:7` | `use_build_context_synchronously` |
| info | `lib/widgets/queries_tab_content.dart:13:9` | `use_super_parameters` |
| info | `lib/widgets/queries_tab_content.dart:22:3` | `library_private_types_in_public_api` |
| info | `lib/widgets/sort_dialog.dart:12:9` | `use_key_in_widget_constructors` |
| info | `lib/widgets/sort_dialog.dart:22:3` | `library_private_types_in_public_api` |
| info | `lib/widgets/translate_sheet.dart:101:9` | `use_super_parameters` |
| info | `lib/widgets/translate_sheet.dart:109:3` | `library_private_types_in_public_api` |
| info | `lib/widgets/translate_sheet.dart:424:21` | `control_flow_in_finally` |
| info | `lib/widgets/translate_sheet.dart:432:9` | `use_super_parameters` |
| info | `lib/widgets/zotero_bottomsheet.dart:166:28` | `use_build_context_synchronously` |
| info | `lib/widgets/zotero_bottomsheet.dart:168:31` | `use_build_context_synchronously` |
| error | `test/widget_test.dart:16:35` | `creation_with_non_type` |

</details>

## debug APK 构建

`flutter build apk --debug` **成功，退出码 0**。完整耗时 2305.87 秒（38 分 25.87 秒），其中 Flutter 输出 Gradle 阶段耗时 2302.7 秒；包含首次下载 Gradle、Maven 依赖及自动安装 SDK 组件。仅在本地设置内存和并行参数，未修改 `android/gradle.properties`：

```bash
export GRADLE_OPTS='-Dorg.gradle.jvmargs=-Xmx3g -Dorg.gradle.workers.max=2 -Dorg.gradle.parallel=false -Dorg.gradle.daemon=false'
flutter build apk --debug
```

daemon 日志确认 `-Xmx3g` 生效。

首次构建除下载 Gradle 和 Maven 依赖外，还自动安装依赖要求的 NDK 28.2.13676358、Android API 34 r3 / API 35 r2；耗时计入整个 build 命令。NDK 两版本并行安装在同一 SDK 目录。重建所需的组件清单应包含这些额外组件。

构建输出包括 JDK native-access、过时 API / unchecked 操作、Java 8 source/target 的 warning，没有构建错误；期间观察到约 307 MiB swap 使用，未发生 OOM。自动生成的调试签名文件仅在 `~/android-dev/android-user/`，未进入仓库或日志。

APK 产物：

| 项目 | 结果 |
| --- | --- |
| 主要路径 | `build/app/outputs/flutter-apk/app-debug.apk` |
| Gradle 原始输出 | `build/app/outputs/apk/debug/app-debug.apk` |
| 大小（两份相同） | 205,843,783 字节（196.31 MiB；205.84 MB） |
| SHA-256 | `2915401d82bfbc439d9231f21975487378585c4346c41e082c851c1ad515d7fc` |
| 包名 | `app.wispar.wispar`（A0 上游原样） |
| App 版本 | 0.10.5，versionCode 41 |
| 最低 Android | API 24（Android 7.0；来自构建输出元数据） |

检查 ZIP 中央目录和 CRC，确认 APK 结构完整；没有进行真机安装或运行验证。

构建结束时 `git diff` 确认上游代码、依赖和构建参数均未变化；最终变更仅为 A0 环境脚本、文档及 PLAN 进度；没有修改依赖缓存中的 jni 源码，也没有应用 workflow 的 dartjni 补丁。

## 真机验收

- [ ] 待用户安装 APK 并确认可启动、退出后可再次启动。
