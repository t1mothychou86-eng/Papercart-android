# Papercart Android 发版

本 fork 基于 [Wispar（Scriptbash）](https://github.com/Scriptbash/Wispar)，遵循 GPL-3.0。
发布 APK 的对应源码必须公开并与 tag 一致；保留 LICENSE、版权和原作者署名。

## GitHub 配置

在仓库 Settings → Secrets and variables → Actions → Repository secrets 中配置以下四项：

- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`

使用协调方保管的签名材料，通过 GitHub 页面安全录入。不要把值放进 issue、PR、命令行参数、终端输出或仓库文件。
workflow 发现任一项缺失或为空时会明确报出其名称并失败。
签名文件只在构建时创建；`always()` 清理步骤在成功或失败后删除临时密钥库及 `android/key.properties`。
GitHub 托管的临时 runner 销毁后也不会保留工作目录；不上传、不缓存签名文件。

## 发版步骤（协调方执行）

1. 在 `cn` 上修改 `pubspec.yaml` 的 `version`，例如 `0.10.6+42`；versionCode 必须递增。
2. 加载 `source scripts/env.sh`，完成测试、analyze 基线比较和本地 release 验证；审查并提交版本改动。
3. 给该提交打版本 tag，再推送分支和 tag（例子中的版本必须对应 pubspec）：

   ```bash
   git tag -a v0.10.6 -m 'Papercart 0.10.6'
   git push origin cn
   git push origin v0.10.6
   ```

4. `cn-release.yml` 在推送 `v*` tag 后构建三种 ABI 的签名 APK，并由
   [softprops/action-gh-release](https://github.com/softprops/action-gh-release) 创建或更新 GitHub Release，
   上传 APK 和 `SHA256SUMS`。Release 包含 GPL-3.0、Wispar 致谢及该 tag 的源码链接。
5. 下载设备对应 APK 和 `SHA256SUMS`，运行 `sha256sum --ignore-missing -c SHA256SUMS`，
   并用 SDK 的 `apksigner verify --print-certs` 核验签名。安装、启动并测试从上一 release 的覆盖升级。
   debug 使用不同签名，不能直接覆盖安装；卸载会清除本地数据，先用应用备份功能保存数据。

仅给已审查的 `cn` 提交打 tag；本次实现没有提交、打 tag、推送或实际发布 GitHub Release。
现有 debug CI 仅验证构建，不代表 release 发布验证。

## 本地构建

加载 `scripts/env.sh`。本地忽略文件 `android/key.properties` 由协调方或安全脚本生成，
其中 `storeFile` 指向仓库外的绝对路径。不要将密码写在 shell 参数中，不要打印该文件。
运行 `flutter build apk --release --split-per-abi`。
产物目录为 `build/app/outputs/flutter-apk/`；常见安卓手机选择 `app-arm64-v8a-release.apk`，
其他设备先确认 ABI。本次实测见 [A1 release 验证报告](A1-RELEASE-REPORT.md)。

## 签名备份和恢复

长期保管原始密钥库、alias 和两个密码，至少保留两份加密、离线、异地备份，限制访问并定期验证恢复。
base64 只是编码，不是加密。它和原始密钥库都应当按密钥材料保护。
GitHub Secrets 不能作为唯一备份；不得依赖从 GitHub 读回其内容。

恢复时在受控机器上从加密备份恢复原始密钥库和口令到仓库外，重新安全录入四个 Secrets，
重新生成本地忽略的 key.properties；先构建并验证证书 SHA-256 与历史 release 相同，再做覆盖升级测试。
本项目直接分发 APK；丢失原签名私钥将无法以相同签名更新已安装应用。
重新生成一个同名 alias 或新密钥库不能恢复原签名身份。

预期证书 SHA-256（公开标识，不是密钥）：
`E8:3E:78:C8:51:92:E1:18:F7:5F:9A:BE:B1:62:4A:47:70:D4:46:7C:D5:3E:5B:EA:9E:87:F4:64:F3:6B:5A:49`。
