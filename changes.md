# 变更记录

## 2026-08-05 页面基准线与安全区域修复

- **状态**：`done`
- 统一五个常规页面的标题栏高度、返回按钮槽位、左右内边距和正文起始线。
- 固定首页底部导航图标与文字的垂直槽位，图标使用 26vp、文字使用 11vp，图标位于文字正上方。
- 将系统导航安全区和首页底部导航颜色统一为页面主题色 `#030A16`。
- 普通页面使用传感器自动方向，展示页保持按配置锁定方向；增加首页、模板、历史、计数器和自定义颜色页的间距。
- 已完成响应式布局、窗口状态、UI 契约和 ArkTS 编译本地回归；设备截图确认首页、模板、历史和计数器页面的内容位于安全区内，底部手势区颜色为 `#030A16`。

## 2026-08-04｜LED 横屏展示与沉浸式安全区

- 状态：`done`
- `AppTheme` 新增状态栏和导航栏颜色，`EntryAbility` 在窗口创建后应用深黑蓝系统栏主题。
- 重构 `ScreenService` 为常规页面、进入展示和退出展示三组确定性窗口状态，统一管理方向、全屏、系统栏、常亮和亮度恢复。
- `DisplayPage` 按“横屏显示”开关请求横屏或竖屏全屏，并在窗口状态切换后更新显示尺寸；返回时统一恢复应用窗口状态。
- `CounterPage` 移除全屏和常亮副作用，保持正常安全区布局。
- 新增 `scripts/test-window-layout.ps1` 并纳入 `scripts/check-standard.ps1`，覆盖系统栏主题、展示页生命周期和计数器安全区回归合同。
- 已在 DevEco Emulator 验证：常规页系统栏与安全区、展示页全屏隐藏系统栏、开启横屏开关后的方向请求、关闭开关后的竖屏展示路径，以及两种展示状态返回后的恢复。
- 模拟器只支持竖屏物理显示模式，不能以该设备作为横屏实际画布的验收；横屏首选方向逻辑已构建和合同验证，仍需在支持旋转的真机或模拟器复验。
- 本轮未修改 bundleName、versionCode、签名配置或 AGC 元数据。

## 2026-08-04｜接入 Gitee 并提交项目

- 状态：`done`
- 初始化本地 Git 仓库并接入 `https://gitee.com/YR23/led.git`，保留远端 `master` 初始 README。
- 新增仓库级 `.gitignore`，排除 `.idea`、`.hvigor`、`oh_modules`、构建产物和日志，不提交 IDE 本地配置与构建缓存。
- 本轮未修改 bundleName、versionCode、签名配置或应用 UI。
- `scripts/check-standard.ps1` 通过（0 错误，0 警告）。
- `scripts/build-harmony.ps1` 构建成功，生成 debug unsigned HAP；保留既有 ArkTS 弃用 API、异常处理和未配置签名提示。

## 2026-08-03｜设计稿 UI 全面还原

- 状态：`done`
- 新增集中视觉主题 `Theme.ets` 与复用点阵组件 `LedPanel.ets`。
- 重做首页、自定义颜色、场景模板、历史记录和计数器页面，保留原有路由、持久化、模板编辑和全屏字幕能力。
- 首页新增固定主操作、8 种模式、11 个色样、双滑杆、三项开关与四项导航；所有状态实时驱动预览。
- 颜色页实现彩虹色相轨道、HSV/RGB 双向换算、最近颜色补齐和渐变确认按钮。
- 模板页实现 2/3/4 列响应式卡片与设计稿 8 个首屏模板；历史页实现真实记录卡；计数器实现点阵数字和圆形发光按钮。
- 使用用户提供的 1024×1024 图稿替换 `startIcon.png`，未修改 bundleName、versionCode 或签名配置。
- 新增 `scripts/test-ui-contract.ps1`，最终 UI 合同、标准检查和 debug HAP 构建均通过。
- 在 DevEco Emulator `127.0.0.1:5555` 完成覆盖安装、启动、逐页截图与关键交互验证。

## 2026-08-03｜构建修复与模拟器测试

- 状态：`done`

### 本次改动

- 补齐项目本地 Hvigor 包装器、`hvigor/hvigor-config.json5` 和 entry 的 Stage 构建配置；补全模块包元数据，且未修改 bundleName、versionCode 或签名配置。
- 修复 Windows PowerShell 5 对构建脚本 UTF-8 编码的解析问题，并将构建进程改为直接调用包装器，规避重复 `Path`/`PATH` 环境变量导致的启动失败。
- 修复 ArkTS 严格编译问题：显式颜色和路由参数类型、禁止对象展开的配置构造，以及页面状态字段与组件属性的命名冲突。
- 新增构建引导、构建脚本和 ArkTS 编译回归检查脚本。

### 验证结果

- `check-standard.ps1`：通过（0 错误，1 个 `README.md` 缺失警告）；以仅当前进程的 `-ExecutionPolicy Bypass` 运行，未改动系统策略。
- `build-harmony.ps1`：debug 构建成功，生成 `entry/build/default/outputs/default/entry-default-unsigned.hap`。
- 模拟器：HAP 已成功安装并以 `com.ledscroll.banner/EntryAbility` 启动。
- 已实际验证：首页默认加载、输入同步预览、静态模式高亮、红色预设配色和全屏静态字幕。

### 遗留验证项

- 构建无错误，但仍有 target SDK 配置及 ArkTS 过时 API/异常处理提示。
- 尚未逐项复测模板、历史、计数器、HSV/RGB、其余七种显示模式、暂停手势和 tablet/2in1 布局；不将审查报告中的全量测试结论视作本轮运行时证据。

## 2026-08-03｜项目初始化和全功能实现

- 状态：`done`
- 用户请求：设计一个LED滚动字幕纯鸿蒙单机应用，功能完备，不用登录
- 项目类型：纯鸿蒙 Stage 模型

### 本次改动

- 创建完整项目结构（AppScope + entry模块）
- 实现配置文件：app.json5、module.json5、build-profile.json5、oh-package.json5、hvigorfile.ts
- 实现数据模型：BannerConfig（8种显示模式+5档速度+LED风格）、ColorScheme（12套预设配色）、Template（12个场景模板）、HistoryRecord
- 实现服务层：StorageService（Preferences持久化）、ScreenService（全屏/常亮/亮度/横屏）、AnimationService（速度参数映射）、TemplateService（模板数据管理）
- 实现6个完整页面：Index首页、DisplayPage全屏显示、TemplatePage模板、HistoryPage历史、ColorPickerPage颜色选择器、CounterPage计数器
- 实现6个动画组件：ScrollingText、BlinkingText、BreathingText、BarrageText、NeonText、BorderEffect
- 实现通用模块：Constants常量、Utils工具函数（颜色转换等）
- 实现EntryAbility和EntryBackupAbility
- 创建资源文件：string.json、color.json、float.json、main_pages.json
- 零权限申请，完全离线，无需登录

### 验证
- 标准检查：待执行（需DevEco Studio环境）
- HarmonyOS 构建：待执行
- 设备与交互：待执行
- 构建产物：待确认
- 证据索引：`docs/qa/`

### 遗留风险
- 彩虹渐变模式使用颜色轮换近似实现，非真正文字渐变
- DisplayPage 字幕样式统一使用 ArkUI Text；点阵纹理已用于预览卡片和计数器，独立展示页的 ledStyle 仍未开放为用户可选控件。
- 弹幕模式多实例动画性能需实机验证
- 模板图标元数据使用语义键；模板卡片直接展示真实字幕预览，不依赖外部图标资源。

## 2026-08-05｜SDK 22 单机应用全量静态审计与可靠性修复

- 状态：`in_progress`（本地验证完成；修复后设备回归等待独占时间片）
- P0：无；未发现启动阻断、数据泄露、联网依赖或签名/包标识变更。
- P1：修复 Preferences 初始化竞态、配置/历史并发写入覆盖、首页启动早于存储初始化以及计数器加载与保存竞态；增加配置和持久化数据校验。
- P2：修复模板、历史和颜色保存/删除失败后的无反馈路径；增加异步按钮锁、失败回滚和可重试提示；修复展示页生命周期定时器清理、后台暂停/前台恢复以及弹幕数组状态未触发刷新的问题。
- P3：补充 RGB 整数范围校验，清理模板未使用字段中的占位元数据并同步开发文档。
- 新增 `scripts/test-business-contract.ps1`，覆盖存储初始化、数据校验、页面加载状态、动画生命周期和重复点击保护；该脚本已完成先失败后通过的回归验证。
- 本地验证：`check-standard.ps1`、UI/窗口/构建脚本合同、业务合同和 `test-arkts-compile.ps1` 全部通过；Debug 和 Release HAP 均构建成功。
- 构建仍输出既有的 `@ohos/hypium` 未安装/符号链接、未配置签名、ArkTS 可能抛异常和弃用 API 警告；这些提示未被隐藏，本轮未修改 SDK、bundleName、versionCode、签名或网络能力。
- 设备约束：本轮未执行新的 `hdc` 安装、启动、卸载、清数据或截图，也未将旧设备证据冒充为修复后结果；待独占时间片按最终报告中的最小矩阵执行。

## 2026-08-05｜修复底部导航标签错位

- 修复首页底部导航文字默认左对齐导致的图标与标签视觉错位。
- 四个 tab 标签统一水平居中，分别对应“首页、模板、历史、计数器”图标。
- 新增 UI 合同断言，防止底部导航标签再次缺少居中样式。
- 未改变导航顺序、路由、图标槽位、主题色和点击行为。

## 2026-08-05｜扩大首页其他设置行距

- 将“其他设置”三行控件的行高从 27 调整为 38，并增加面板上下各 6 的内边距。
- 文字、图标和开关继续保持同一行垂直居中；滚动区域和底部操作区行为保持不变。
- 增加 UI 合同断言，固定该区域的共享间距常量和布局使用方式。

## 2026-08-05｜统一放大常规 UI 字号

- 新增 `AppTheme.uiFontSize()`，将常规 UI 固定文字统一放大约 8%。
- 首页、模板、历史、自定义颜色、计数器和展示页提示文字同步应用字号规则。
- 保持 LED 字幕和计数器主数字的动态字号不变，避免影响用户配置和核心展示。

## 2026-08-05｜加粗常规 UI 文字

- 新增 `AppTheme.UI_FONT_WEIGHT`，统一将常规 UI 文字提升到 Medium 字重。
- 首页、模板、历史、自定义颜色、计数器和展示页提示层同步应用，标题和主按钮仍保留 Bold。
- 未改变用户设置的 LED 字幕、计数器大数字、路由或交互行为。

## 2026-08-05｜应用图标上架资源审计

- 审计发现 `AppScope/resources/base/media/app_icon.png` 原为 64x64 的纯绿色占位图，不满足正式应用图标的清晰度和内容要求。
- 使用已有的 1024x1024 LED 设备图标统一替换 `app_icon.png`，保持应用清单、Ability 图标和启动窗口图标的引用关系不变。
- 新增 `scripts/test-icon-assets.ps1`，检查图标尺寸、非占位内容和 `app.json5`/`module.json5` 资源引用。
- 未修改 bundleName、versionCode、签名配置或 AGC 元数据。

## 2026-08-07｜审核问题修复与验证收尾

- 更新固定 UI 对比度、常规页系统栏/安全区、五个真实滚动容器的 Spring 边界反馈，以及 1024x1024 应用/Ability 分层图标；用户 LED 颜色继续可配置，首页两个布局 `Grid` 不增加伪滚动反馈。
- `scripts/check-standard.ps1` exit 0（脚本自身 0 错误、0 警告）；UI、业务、构建脚本、构建引导和 ArkTS 编译回归均 exit 0。
- `scripts/build-harmony.ps1` exit 0，生成 `entry/build/default/outputs/default/entry-default-signed.hap`（2,322,096 bytes）。本次增量构建的 `CompileArkTS` 为 `UP-TO-DATE`，没有重新输出编译器警告；标准检查的“0 警告”不代表既有 `@ohos/hypium`/符号链接、签名配置、可能抛异常或弃用 API 警告已消失。
- phone `127.0.0.1:5555` 和 2in1 `127.0.0.1:5557` 均安装、启动成功；`bm dump` 读取到 app `$media:app_icon`、Ability `$media:layered_image`、splash `$media:startIcon`。
- phone 已覆盖首页、颜色、模板、历史和展示页；展示页横屏全屏/隐藏系统栏有直接证据。Spring 精确静态合同与实际边界滑动/持续响应通过，只有瞬态动画录像为 partial；展示页退出时共享模拟器被其他应用抢占前台，未保留无法独立归因的恢复截图。有效证据为 `docs/qa/2026-08-07-home-5555.png` 与 `docs/qa/2026-08-07-home-5555.json`、`docs/qa/2026-08-07-color-5555.png` 与 `docs/qa/2026-08-07-color-5555.json`、`docs/qa/2026-08-07-template-refocused-5555.png` 与 `docs/qa/2026-08-07-refocused-5555.json`；`docs/qa/2026-08-07-template-5555.json` 是重新拉起前的独立模板页快照。另有 `docs/qa/2026-08-07-history-5555.png` 与 `docs/qa/2026-08-07-history-5555.json`、`docs/qa/2026-08-07-display-5555.png` 与 `docs/qa/2026-08-07-display-5555.json`，以及 app-only 2in1 截图 `docs/qa/2026-08-07-home-5557-app.png` 与布局 `docs/qa/2026-08-07-home-5557.json`。
- 展示页暂停、引导和退出覆盖层改用固定 `#FFFFFF` 前景与 `#07111F` 背景（18.94:1），不再受用户 LED 配色影响。最新 signed debug HAP 在 phone 覆盖安装并重启成功；“反转白”设备证据 `docs/qa/2026-08-07-display-white-overlay-5555.png` 与 `docs/qa/2026-08-07-display-white-overlay-5555.json` 显示白色动态背景上的深色引导/退出表面和清晰浅色固定 UI。双击命令已发出，但本次布局未出现“已暂停”，不据此宣称暂停状态或动画行为已验证。

## 2026-08-07｜修复竖屏纵向字幕顶部闪退

- 根因是 `DisplayPage` 将字幕居中后再执行 `translate(y)`，但由下向上的旧结束点直接使用 `-textHeight`；该坐标仍位于可视区域内，计时器会在文字尚未完整越过顶部时立即重置。
- 纵向两端统一改为 `(screenHeight + textHeight) / 2` 的正负对称坐标。文字从屏幕下边完整进入，远侧边缘越过屏幕上边后才重置；总路程和原实现一致，不改变速度档位与循环时长。
- `scripts/test-business-contract.ps1` 新增纵向边界合同并完成 RED/GREEN：旧实现准确失败 5 项，修复后通过。
- `scripts/check-standard.ps1` 通过（0 错误、0 脚本警告），signed debug HAP 构建成功，大小 2,321,693 bytes，SHA-256 为 `B6800A3AA9E5DDD518DE6F7A5312C818A7E718348C6D58AA54FA44888EE3B58A`。
- phone 在关闭“横屏显示”后以 `1320x2856` 竖屏运行纵向模式；连续帧 `docs/qa/2026-08-07-portrait-vertical-a-5555.png` 至 `-h-5555.png` 覆盖顶部离开、底部进入和画面内上移，应用进程持续存活。为建立无历史状态的确定性验证基线，测试前仅清除了 phone 模拟器内该应用的本地测试数据。

## 2026-08-07｜优化纵向字幕循环入场

- 根因是纵向循环把位移重置到屏外起点时仍保留 `textOpacity = 1.0`，导致文字刚越过屏幕边缘就以满亮度出现，视觉上像直接闪现。
- `DisplayPage.startScrollV()` 现在在首次起步和每轮重置时归零透明度，并按离开起点的距离在一个文字高度内渐显到完全不透明；既有上下方向、速度、总路程和完整出屏端点保持不变。
- `scripts/test-business-contract.ps1` 新增入场渐显合同；RED 阶段准确失败 3 项，最小实现后转为通过。合同同时锁定零透明度起点、文字高度渐显距离和距离驱动的透明度计算。
- 未强制竖屏，横竖屏仍由现有“横屏显示”开关控制；2in1 以横屏窗口完成受控时序取样，文字沿当前画布下边到上边移动。
- `check-standard.ps1` 通过（0 错误、0 脚本警告），signed debug HAP 构建成功，大小 2,321,332 bytes，SHA-256 为 `7C658C6F4A66F8FE3B61B0B192C412A0804399DFE95251675A8D56174B8C06CB`。构建仍输出项目既有的弃用 API 与可能抛异常提示，本次未新增编译错误。
- 2in1 受控取样 `docs/qa/2026-08-07-entry-fade-sample-01-5557.jpeg` 至 `-05-5557.jpeg` 覆盖屏外透明起点、下边进入和持续上移；布局证据为 `docs/qa/2026-08-07-entry-fade-page-5557.json`，验证后应用进程仍存活。phone 与 2in1 均受共享前台应用抢占，未把外部应用截图纳入证据，也未宣称录制到连续视频中的每个透明度中间值。

## 2026-08-07｜API 22 上架就绪修复

- 保持签名、bundleName、versionCode 和 SDK 编译链不变；实际 Release HAP 的 compatible/target API 均为 22。
- 展示页改用原生排他单双击手势，双击暂停优先于单击显示退出按钮；移除计时器式点击计数。
- 打开历史项时保存配置并增加次数；修复 `ForEach` 只按固定 ID 复用卡片导致立即返回仍显示旧次数的问题，回归合同完成 RED/GREEN。
- 关闭系统备份恢复；清单权限保持为空，并由发布合同扫描网络权限、网络 SDK 和请求代码。
- 应用和 Ability 图标改为 1024x1024 分层资源，前景 alpha 内容位于 80px 安全区内；补齐隐私政策、用户协议和 AppGallery 提交清单。
- 页面弃用的全局路由、提示、上下文、像素换算和动画入口迁移到 `UIContext`；干净 Debug 与 Release ArkTS 编译均无警告。
- `scripts/check-standard.ps1` 通过（0 错误、0 警告）；最终 signed Release HAP 为 2,083,497 bytes，SHA-256 `5C1E931A20C02D7449FBE6A0A953D571088083CF3AD63AD0BF1651A2D0F03801`。
- phone（OpenHarmony 6.0.2.130）和 2in1（OpenHarmony 6.1.1.125）均覆盖安装并启动；两端双击暂停/恢复和展示页返回通过。phone 历史记录从“使用9次”打开后立即返回显示“使用10次”，展示页根节点覆盖 `[0,0][2856,1320]`。当前无在线 tablet，tablet 布局与商店截图仍是提交前验收项。

## 2026-08-11｜AppGallery 验收修复

- 将应用和 EntryAbility 的用户可见名称统一为 `光迹字幕`，未修改 bundleName、版本、签名、路由或权限。
- 普通页恢复非全屏系统栏布局，状态栏使用不透明 `PAGE_BG #030A16`；五个普通页不再扩展到系统安全区，`DisplayPage` 继续保持独立全屏展示。
- 将四处低于 12fp 基准的固定 UI 文本提升为 `uiFontSize(12)`；用户可调 LED 显示字号不变。
- 新增 AppGallery 验收合同，并将窗口和响应式合同同步为新的普通页规则；图标合同确认 AppScope/Ability 两对 PNG 的 SHA-256 完全一致。
- `check-standard.ps1` 以 0 错误、0 警告通过；基线签名配置为空，Debug 构建成功并生成 unsigned HAP（2,285,937 bytes，SHA-256 `205EDF11C36D9136550D3C027804193B591C8AA6172763D421C0B023C8828908`），保留包名 `com.ledscroll.banner`、版本 `1.0.0` / `1000000` 和零权限。正式签名须通过受控外部流程完成。
- phone `127.0.0.1:5555` 成功覆盖安装并启动当前 Debug HAP；首页、展示页和返回首页截图分别为 `docs/qa/2026-08-11-appgallery-home-5555.png`、`-display-5555.png`、`-exit-5555.png`。布局证据确认展示页全屏 `[0,0][2856,1320]`，返回后首页恢复普通安全区 `[0,137][1320,2856]` 和 `#FF030A16` 页面背景；tablet 与 2in1 未连接。

## 2026-08-11｜可识别名称与重新上架交接

- 将通用名称替换为已确认的 `光迹字幕`，覆盖 AppScope、EntryAbility 资源和 Index 的双色标题；AppGallery 验收合同会拒绝任何不一致。
- 现有 phone 证据在 `docs/qa/2026-08-11-appgallery-name-app-5555.*` 和 `docs/qa/2026-08-11-appgallery-name-launcher-5555.png` 中记录了运行标题和启动器标签。
- app `$media:app_icon` 与 Ability `$media:layered_image` 仍来自像素一致的分层 PNG 对。共享模拟器中的最近任务截屏无法独立归因给本应用，因此不将其作为视觉证据。
- 未执行上传。当前 HAP 是 unsigned Debug 输出；Release 签名必须继续通过受控外部流程，只有取得经批准的已签名 Release HAP 后才能提交到 AppGallery。

## 2026-08-11｜鸿蒙问题排查表全量审计与修复

- 对 `C:\Users\27363\Desktop\鸿蒙问题排查表.md` 的 11 个编号项逐一完成适用性、现状和证据核对，报告见 `docs/qa/2026-08-11-troubleshooting-table-audit.md`。
- 确认首页普通页底部额外避让原为 24vp，低于表中 28vp 门槛；先修改响应式合同并观察预期失败，再将共享 `SYSTEM_BOTTOM_PADDING` 提高到 28。
- 确认首页开关只设置硬编码选中色、关闭轨道和滑块仍依赖原生主题默认值；先增加对比度和真实 Toggle 链合同并观察预期失败，再新增共享设置面板/关闭轨道/滑块颜色和 `switchStyle`。
- `TOGGLE_OFF_TRACK` 对 `SETTING_PANEL_BG` 为 5.94:1，`TOGGLE_THUMB` 对关闭轨道为 6.11:1、对选中轨道为 12.32:1；phone 截图确认关闭态仍清晰可辨。
- 其余相关条目由现有名称、分层图标、普通页窗口、固定 12fp 字号、响应式宽度和固定对比度合同覆盖；提醒、代理提醒、账单、统计、日历、专注、时钟和白噪音等其他应用功能明确判定为不适用。
- 最终 `check-standard.ps1` 为 0 错误、0 警告；parse、UI、业务、ArkTS 编译和 `build-harmony.ps1` 均 exit 0。Debug HAP 为 2,286,536 bytes，SHA-256 `2054CB280DD5D18971316FD23385D9177B662F3CF4707D3BA2C016C34C2EDA01`；签名配置仍为空。
- phone `127.0.0.1:5555` 安装/启动成功，普通页、开关关闭态和展示页全屏证据已保存。退出阶段共享模拟器被另一应用抢占，因此本轮退出恢复运行时证据标记 partial；当前无 tablet/2in1。
## 2026-08-11 底部安全区颜色修复

- **状态**：`done`
- 修复普通页面底部手势安全区显示系统白色的问题。`ScreenService.applyAppChrome()` 现在同步设置窗口背景色为 `AppTheme.PAGE_BG`，并在首页内容加载完成后再次应用窗口/系统栏主题，避免加载时序覆盖深色安全区。
- 保留普通页面非全屏布局和 `DisplayPage` 全屏展示行为；未修改 bundleName、versionCode、签名、权限或 AGC 元数据。
- RED/GREEN：`test-window-layout.ps1` 先验证“内容加载完成后必须重新应用系统栏主题”而失败，随后加入生命周期契约与窗口背景色契约并通过。
- 设备证据：`docs/qa/2026-08-11-safe-area-color-5555.png` 与对应 JSON 显示首页内容区和底部手势安全区均为深色，不再出现截图中的白色条带。

## 2026-08-11 排查表复核：身份、对比度与最小字号

- 重新核对 AppScope/EntryAbility/首页标题，确认用户可见名称统一为 `光迹字幕`；重新检查分层图标图层哈希，并在 phone 启动器与最近任务列表中取证，两个位置显示同一名称和同一 LED 图标。AppGallery Connect 与软件资质仍需提交人使用同一名称和同一源图人工同步。
- 定位并修复审核坐标对应的点阵背景 `Text`：移除 8fp 和 0.25 透明度/用户色耦合，改用共享 `LED_MATRIX_DOT_FONT_SIZE = 10`、`LED_MATRIX_DOT_COLOR = #8793A8`、`LED_MATRIX_DOT_OPACITY = 0.85`，在深色表面上保持可读对比度。
- 为 AppGallery 和无障碍合同增加 RED/GREEN 约束，防止点阵字号再次回到 8fp、点阵文字脱离共享可读颜色或降低透明度。
- 状态栏复核确认普通页面仍非全屏且使用系统安全区，phone 首页标题位于状态栏下方；未修改 bundleName、versionCode、签名配置或 AGC 元数据。
- 全量复核构建生成 unsigned Debug HAP 2,288,292 bytes，SHA-256 `B126C29FCA829C49E056E3E18FAAE8BF4CAED7B2E9E0EEAB475C0CE33D045F40`；phone 覆盖安装、启动器、最近任务和首页布局取证完成。

## 2026-08-11｜上架规范复核（仅审计）

- 复核了用户提供的 11 项鸿蒙问题排查表及当前工程，未发现新的适用源码缺陷；适用项（底部安全区、浅/深色对比度、状态栏避让、最小字号、名称/图标包内一致性）均有通过的静态契约或 phone 运行证据。
- 本轮没有修改产品源码、bundleName、versionCode、签名配置或 AGC 标识，仅补充任务/质量记录。
- 结论不是“可直接上架”：当前产物仍是 unsigned Debug HAP；tablet/2in1 本轮无在线目标；AGC 商店名称/图标/介绍/截图、公开隐私政策 URL、软件资质/版权材料仍须由提交主体完成并核对。
- 证据与逐项结论见 `docs/qa/2026-08-11-troubleshooting-table-audit.md` 和 `docs/release/appgallery-submission-checklist.md`。

## 2026-08-12｜展示对比度与点击响应修复

- 在 `Utils` 增加可复用的 sRGB 对比度计算与 `ensureTextContrast()`；`LedPanel` 和 `DisplayPage` 均在最终渲染边界强制正文达到 `4.5:1`，全屏彩虹/霓虹帧也会被逐帧校正。
- 移除展示字幕的淡入、半透明弹幕和低透明度呼吸/闪烁路径，改为轻微缩放动效，避免动画中的可见字符降到审核对比度阈值以下。
- `StorageService.saveDisplayConfig()` 把上次配置和历史记录合并为一个序列化写入/一次 `flush()`；首页、模板、历史改为先路由展示页、后后台保存。颜色、计数器和历史列表的非破坏性可见操作同步改为即时 UI 更新和后台持久化。
- 新增 `scripts/test-display-safety-contract.ps1` 并纳入标准检查，锁定 4.5:1 后备策略、所有展示入口的路由优先级、可见 LED 文字不透明度和即时状态更新，防止同类问题回归。
- 未修改 bundleName、versionCode、权限、路由、AGC 元数据或签名配置。工作区已有的 `build-profile.json5` 签名材料仍会使仓库 AppGallery 合同失败，未被读取、复制或修改。

## 2026-08-12｜HarmonyOS App Quality 全局技能

- 学习并结构化整理华为《通用应用 UX 体验标准》、官方性能时延指南、两篇应用市场官方上架检测 FAQ 和《应用审核指南》。按来源权重保留官方条款、官方论坛审核案例、页面更新时间和原始 URL。
- 在 Codex 用户级全局目录 `C:\Users\27363\.agents\skills\harmonyos-app-quality` 安装技能。核心工作流与三份按需参考分别覆盖 39 条 UX 要求、性能/图标审核阈值和 AppGallery 13 章审核路由。
- 技能结构校验通过，五个安装文件与前向测试版本的 SHA-256 完全一致；代表性测试能够区分推荐/必须阈值、引用点击响应与完成时延，并识别手持弹幕品类的差异化上架风险。
- 本次未修改应用源码、资源、bundleName、versionCode、权限、AGC 元数据或签名配置，也没有可见 UI 变化。HarmonyOS Debug 构建成功；标准检查仍被任务前已有的 tracked signing material 合同阻断，且当前环境未找到可用 `hdc`，因此无新增设备运行证据。

## 2026-08-12｜鸿蒙自检增量能力

- 将用户提供的重复、粘连和失效链接归一为华为布局、对比度、深色模式、底部导航条、状态栏、应用分类、应用资质和审核指南来源；`50104-0` 为 404，`0203198799217774051` 未提供可核实正文，均未据此新增规则。
- 在全局 `harmonyos-self-check` 中新增 `release-preflight-cases.md`，补充布局错位/截断/变形/模糊/遮挡案例、底部导航区域运行时矩阵、深色与状态栏证据、分类/标签选择和备案/资质适用性流程。
- 已有对比度阈值、UX 2.1.2.1/2.1.4.1/2.2.1/2.2.5/2.2.6 和 13 章审核路由保持原位，不在新 reference 中复制；28vp 明确保留为 FAQ 操作案例，并要求以实际系统 inset 和当前官方标准复核。
- 更新 skill description、reference 路由和默认提示，使分类、标签、备案、资质、深色模式、状态栏和安全区域请求可发现新增能力；展示名和内部 ID 保持 `鸿蒙自检` / `harmonyos-self-check`。
- 本次没有修改应用源码、资源、签名、bundleName、versionCode、应用 ID 或 AGC 元数据，也没有新增运行时 UI 行为。
- skill 契约、结构校验和构建通过；`check-standard.ps1` 仍被工作区既有的 AppGallery 修复合同与签名材料合同阻断，本任务未扩大范围处理这些应用改动。

## 2026-08-12｜AppGallery 审核驳回整改

- 审核报告共映射 6 项：4 项阻断为旧 AGC 名称 `LED滚动字幕` 过于泛化、AGC 图标透明、AGC 与安装包名称/图标不一致、隐私模块名称不一致；2 项非本次阻断为历史空态“清空”对比度 `1.76/1.82/1.81/1.86` 和点击完成 `3117ms`。
- `entry/src/main/ets/pages/HistoryPage.ets` 仅在存在记录时构建 48x48 `清空` Text；空态使用 48x48 `Blank`，不应用 opacity 且不可点击。有记录时的确认和清空逻辑保持不变。
- `scripts/generate-layered-icon.ps1`、`scripts/test-icon-assets.ps1`、`scripts/test-appgallery-remediation-contract.ps1`、`scripts/check-standard.ps1` 和 `docs/release/appgallery-submission-checklist.md` 增加商店图标、身份一致性、历史空态和外部提交交接合同。`docs/release/appgallery-icon.png` 为 265,721 bytes、1024x1024、`Transparent=0`、`NonOpaque=0`、四角 alpha 255、采样颜色数 939；它与 AppScope 背景+前景逐像素合成结果一致，两次生成 SHA-256 均为 `D35D3F2B48ADC98FABFB0D63B195F9321878D80B5A0A76F62B64D5B3367BA82D`。
- 包内身份现为 `光迹字幕`；AppScope/EntryAbility/Index/隐私政策/用户协议合同通过。remediation、icon、accessibility、display-safety 合同通过，ArkTS 编译和 HarmonyOS 构建通过。最新产物 `entry/build/default/outputs/default/entry-default-signed.hap` 为 2,335,890 bytes，SHA-256 `95CE055466E51113110B5B9E2FA218DABD42C756C1A75F109A782BA1265150AE`，构建时间 `2026-08-12 23:44:29 +08:00`。
- 最新 HAP 已覆盖安装并启动于 phone emulator OpenHarmony `6.0.2.130`、`1320x2856`。空态 `docs/qa/2026-08-12-appgallery-remediation-current-history-5555.*` 无“清空”，尾部 `Blank` 为 `[1096,255][1264,423]`、`clickable=false`、opacity 1.0；有记录态 `...-history-populated-5555.*` 的 `清空` 使用相同 168x168 px（48x48 vp）边界、完全不透明且可点击；`...-clear-dialog-5555.*` 证明确认弹窗与取消路径。最终确认删除时共享模拟器被其他应用抢占，不能把删除完成记为通过；tablet/2in1 离线。
- `scripts/check-standard.ps1` exit 1，仅剩既有 `build-profile.json5` tracked signing configuration/material 的 3 项 AppGallery acceptance 阻断；该文件未读、未改。AppAnalyzer/DevEco Testing 精确 T1/T2 CLI 不可用，`<=900ms` 保持 `unverified`，不能用源码或构建替代。
- 未写入 AGC。商品名、图标上传/预览、简介、隐私资料、软件资质、正式包上传和重新提审均未执行，必须在动作时确认；因此本轮不能宣称全绿、AGC 外部阻断通过或应用可上架。

## 2026-08-13｜桌面与启动图标复检

- 保持 AppScope/EntryAbility 的 1024x1024 分层桌面图标不变，将 `startIcon.png` 从 1024x1024 启动位图替换为基于同一背景层和前景层合成、缩放的独立 144x144 完整启动图标；避免系统启动过渡中把大幅透明前景或超大位图当成启动图显示。
- 更新 `scripts/test-icon-assets.ps1`，锁定独立 `$media:startIcon` 引用和当前 DevEco Stage 模板/项目采用的 144x144 启动资源基线。该尺寸不作为 UX 2.1.4.3.1 的官方启动图强制尺寸；官方 1024x1024、背景零透明规则仍只用于分层应用图标。
- 最新 signed Debug HAP 为 751,392 bytes，SHA-256 `903453DE741501D463185278FC06FF39D6169649A5C87EF282C40C1D4B749CFF`；phone `127.0.0.1:5555` 覆盖安装成功，启动器和多轮冷启动截图均显示完整、清晰图标。
- 图标合同通过且构建成功；全项目 `check-standard.ps1` 仍失败于本次图标范围外的既有状态：响应式/窗口合同要求 5 个页面保留旧固定系统 padding 表达式，以及 AppGallery 合同拒绝现有 tracked signing configuration/material。本轮未回退页面安全区实现，也未修改签名配置。
- 未修改 bundleName、versionCode、签名配置、应用 ID、权限或 AGC 元数据。tablet/2in1、AGC 上传预览和 production provisioning 仍未验证。
