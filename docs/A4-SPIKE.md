**建议 A4 先验证“aTrust 客户端连接后，Papercart 直接打开出版商原始网址”，CARSI 作为后续补充；目前没有足够证据实施武大 WebVPN 网址改写。**这是基于公开说明的建议，尚未经安卓真机验证。[武大图书馆校外访问指南](https://oldwww.lib.whu.edu.cn/webfile/category/Off-campus_access/309.html)

全程只读，未修改文件、未登录、未提交表单或尝试账号。部分官网正文通过搜索引擎收录读取；动态成员记录及数据库详情未能完整取得，以下明确区分已证实与未查到。

**1．vpn.whu.edu.cn 的类型及图书馆其他入口**

- **现行图书馆指南指向需要客户端的 aTrust 访问方式。**原文：“首次使用需安装 aTrust 客户端。”产品属于深信服零信任访问系统。因此，工程上应先按客户端 VPN／零信任接入处理，不能把这个地址当成已知格式的 WebVPN 改写入口。本次直接访问仅看到它跳转到 `/portal/`，未取得改写后的资源网址。[图书馆指南](https://oldwww.lib.whu.edu.cn/webfile/category/Off-campus_access/309.html)、[VPN 入口](https://vpn.whu.edu.cn/)、[深信服产品说明](https://support.sangfor.com.cn/productSoftware/list?category_id=160&product_id=19)

- **Android 下载：搜索 aTrust。**深信服官方社区说明，可从 aTrust 网页入口扫码，或在小米、华为、荣耀应用商店及应用宝搜索下载；该页也提供厂商 APK 下载地址。武大公开指南没有列出单独的 Android 安装包版本，实际应优先遵循武大入口提示。[深信服移动端下载说明](https://bbs.sangfor.com.cn/forum.php?mod=viewthread&tid=250405)

- **EasyConnect 是另一份旧说明中的名称。**图书馆《访问须知》写的是安装 EasyConnect，并填写 `https://vpn.whu.edu.cn`。两份材料存在版本差异；当前调研应优先参考写明 aTrust 的图文指南，不能要求用户同时安装两者。[旧《访问须知》](https://oldwww.lib.whu.edu.cn/webfile/category/information/530.html)、[aTrust 图文指南](https://oldwww.lib.whu.edu.cn/webfile/category/Off-campus_access/309.html)

- **图书馆确有独立校外访问方式。**官网说明：数据库导航右上角登录，使用信息门户身份；也可在图书馆首页选择“登录我的图书馆”中的图书馆单独认证。指南将这两种方式和学校 VPN 列为可访问所有数据库的方式，将 WAYFless、CARSI、个人账号漫游列为仅支持部分数据库的方式。这里的“所有数据库”应理解为馆方提供且用户有权限的资源。[馆方说明](https://oldwww.lib.whu.edu.cn/webfile/category/sjk_cj/1066.html)、[数据库导航](https://whu.metaersp.com/)

- **武大历史上确实部署过 WebVPN，但当前入口和改写规则未查到。**2020 年 CERNET 对武大信息中心主任的采访原文称：“学校紧急扩容VPN设备并新增WebVPN通道。”这只能证明历史部署，不能证明今天仍有可用的 `webvpn.whu.edu.cn`。本次也未查到馆方将当前系统明确称为 libvpn 或 EZproxy 的说明。[CERNET 采访](https://www.cernet.edu.cn/info/zt/fk/202002/t20200227_1713978.shtml)、[当前馆方访问指南](https://oldwww.lib.whu.edu.cn/webfile/category/Off-campus_access/309.html)

**2．CARSI 成员身份与 IdP entityID**

**武大已开通 CARSI 服务，有一手公开材料支持。**CERNET 的案例材料原文：“武汉大学在2019年11月就开通了CARSI服务”。武大图书馆也给出了选择 Wuhan University 的操作说明。[CERNET 案例](https://cerecp.cernet.edu.cn/zh/news/d7a1e29a6335c822e076d4d1210efc23.shtml)、[武大图书馆指南](https://oldwww.lib.whu.edu.cn/webfile/category/Off-campus_access/309.html)

**IdP entityID：未查到符合本次要求、可直接核验的官方记录。**我访问了 CARSI 官方成员列表及 eduGAIN 的实体查询、元数据入口，但未能读取武大对应的具体记录。第三方页面虽然列有候选值，按你的要求不把它当作确认结果，也不据此生成登录链接。[CARSI 官方成员列表](https://www.carsi.edu.cn/IdPlist.html)、[eduGAIN 实体列表](https://technical.edugain.org/entities)、[eduGAIN 元数据说明](https://technical.edugain.org/metadata)

**3．六家目标数据库是否获馆方明确确认支持 CARSI**

**本次未取得六家逐项支持武大 CARSI 的馆方原文。**不能由“武大开通 CARSI”推导出六家全部可用。

| 目标平台 | 本次查证结果与出处 |
|---|---|
| Elsevier／ScienceDirect | 馆方数据库导航有“Elsevier ScienceDirect电子期刊及电子图书”；未取得明确支持 CARSI 的具体说明。[导航](https://whu.metaersp.com/) |
| Wiley | 馆方电子期刊目录列有“Wiley电子期刊”；未取得明确支持 CARSI 的具体说明。[目录](https://oldwww.lib.whu.edu.cn/webfile/category/E-journal_database/336.html) |
| OUP | 同一馆方目录列有“Oxford University Press Journals”；未取得明确支持 CARSI 的具体说明。[目录](https://oldwww.lib.whu.edu.cn/webfile/category/E-journal_database/336.html) |
| JSTOR | 馆方导航有“JSTOR电子期刊和电子图书”；未取得明确支持 CARSI 的具体说明。[导航](https://whu.metaersp.com/) |
| UChicago Press、AEA | 未查到馆方明确说明这两家可通过 CARSI 访问的原文；不能据此判断支持或不支持。[馆方数据库导航](https://whu.metaersp.com/) |

馆方通用指南明确限定 CARSI 仅适用于部分数据库，并以 IEEE 为例，原文要求搜索“Wuhan University”，成功后显示“Access Provided by Wuhan University”。这不是上述六家的支持清单。[原文出处](https://oldwww.lib.whu.edu.cn/webfile/category/Off-campus_access/309.html)

**4．Papercart 的推荐路线与真机确认事项**

| 路线 | 建议 |
|---|---|
| 系统级 VPN 客户端，保留原始网址 | **优先验证。**馆方把学校 VPN 排在首位；但需确认 aTrust 的武大配置允许 Papercart 的流量通过。[依据](https://oldwww.lib.whu.edu.cn/webfile/category/Off-campus_access/309.html) |
| WAYFless＋CARSI | **作为补充。**先核验 entityID，再逐家核对馆方入口或出版商官方规则；目前不足以承诺覆盖六家。[依据](https://oldwww.lib.whu.edu.cn/webfile/category/sjk_cj/1066.html) |
| WebVPN 网址改写 | **暂不实施。**缺少当前入口、真实资源 URL 和规则；历史部署信息不足以生成改写算法。[历史出处](https://www.cernet.edu.cn/info/zt/fk/202002/t20200227_1713978.shtml) |

真机验收建议如下，属于待验证事项：

- **VPN 路线：**在校外网络连接武大 aTrust 后，分别在系统浏览器和 Papercart 中打开同一篇已知属于武大订阅范围的文章，逐家检查六个平台的机构识别、全文和用户手动 PDF 下载。如果只有 aTrust 自带浏览器可用，就不能采用“系统 VPN 自动覆盖 Papercart”的假设。[验证起点](https://vpn.whu.edu.cn/)
- **CARSI 路线：**关闭 VPN，通过馆方数据库详情的 CARSI／WAYFless 入口，由用户自行登录，检查能否返回原文章、是否取得全文，以及 Papercart 关闭重启后是否保留会话。这项实测还应比较系统浏览器与 App 内浏览器的结果。[馆方操作说明](https://oldwww.lib.whu.edu.cn/webfile/category/Off-campus_access/309.html)
- **WebVPN 路线：**若图书馆登录后确实出现改写网址，再确认其主机、路径、参数及跳转行为；仅凭 VPN 首页地址无法确定规则。[馆方数据库导航](https://whu.metaersp.com/)
- **分开测试不同方式。**馆方原文提醒：“建议以上多种校外访问方式不要同时使用”，否则可能产生冲突。[原文出处](https://oldwww.lib.whu.edu.cn/webfile/category/sjk_cj/1066.html)