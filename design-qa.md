# 设计与交互QA记录

## 2026-08-05 页面基准线、安全区域与旋转适配

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 响应式布局契约 | passed | `scripts/test-responsive-layout.ps1` 通过，覆盖主题尺寸、五个页面标题栏引用、导航槽位和安全区颜色 |
| 窗口状态契约 | passed | `scripts/test-window-layout.ps1` 通过，常规页面使用 `UNSPECIFIED`，展示页保留显式方向 |
| UI 契约 | passed | `scripts/test-ui-contract.ps1` 通过 |
| ArkTS 编译 | passed | `scripts/test-arkts-compile.ps1` 通过；保留项目原有非阻断弃用 API 和依赖链接警告 |
| 设备安全区颜色 | passed | `127.0.0.1:5555` 实测截图 `C:\Users\27363\AppData\Local\Temp\led-banner-safe-area.jpeg`；系统手势区像素与页面主题一致，为 `#030A16` |
| 设备旋转 | waiting | 当前模拟器只提供 `1320x2856` 竖屏物理显示，普通页面的 `UNSPECIFIED` 合同已通过，真实横屏画布仍需在支持旋转的设备确认 |

## 2026-08-04 横屏展示与沉浸式安全区验证

**环境**：DevEco Emulator `127.0.0.1:5555`，HarmonyOS 5.0+，`com.ledscroll.banner/EntryAbility`。

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 窗口状态合同 | passed | `scripts/test-window-layout.ps1` 通过 |
| 标准检查 | passed | `scripts/check-standard.ps1`，0 错误、0 警告 |
| debug HAP 构建 | passed | `scripts/build-harmony.ps1`，生成 `entry-default-unsigned.hap`（603353 bytes） |
| 常规页安全区与系统栏 | passed | `2026-08-04-home-system-bars.jpeg`；布局根节点从 y=137 开始，底部内容止于 y=2758 |
| 横屏开关开启后的展示页 | partial | `2026-08-04-display-landscape.jpeg` 和布局树确认进入 `DisplayPage`、全屏并隐藏状态栏/导航栏；窗口代码请求 `LANDSCAPE` |
| 横屏开关关闭后的展示页 | passed | `2026-08-04-home-landscape-disabled-layout.json` 中开关为 `checked:false`；`2026-08-04-display-portrait-layout.json` 确认进入竖屏全屏展示 |
| 展示页返回恢复 | passed | `2026-08-04-home-after-display.jpeg`、`2026-08-04-home-after-display-layout.json` 和 WindowManager 转储确认返回 `pages/Index`、状态栏与导航栏恢复可见 |
| 关闭横屏后的返回恢复 | passed | `2026-08-04-home-after-portrait-layout.json` 确认返回 `pages/Index`，状态栏与导航栏恢复可见 |

**横屏设备限制**：该模拟器的 RenderService 只报告 `1320x2856` 单一竖屏模式，WindowManager 中展示窗口方向仍为 `0`。因此不能将其用于真实横屏画布验证；需在支持旋转传感器/横屏模式的真机或模拟器上复验实际横屏方向。全屏、系统栏隐藏和返回恢复已在该设备验证。

## 2026-08-04 仓库提交前验证

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 标准检查 | passed | `scripts/check-standard.ps1`，0 错误，0 警告 |
| HarmonyOS 构建 | passed | `scripts/build-harmony.ps1`，debug unsigned HAP 构建成功 |
| 远端基线 | passed | `origin/master` 为远端初始提交，已保留 README 文件 |
| 生成物隔离 | passed | `.gitignore` 排除 `.idea`、`.hvigor`、`oh_modules`、构建目录和日志 |
| 设备验证 | reused | 沿用 2026-08-03 已记录的 phone 模拟器验证；本轮未新增 UI 行为 |

结论：仓库接入和提交前检查完成。本轮只涉及 Git 元数据、忽略规则和验证记录，不改变应用功能或设计。

## 运行环境

- 设备/模拟器：DevEco Emulator 已运行；本应用已安装并启动
- 系统版本：HarmonyOS 5.0+
- Bundle：com.ledscroll.banner
- Ability：EntryAbility
- 构建产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`

## 构建与部署检查（2026-08-03）

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 标准检查 | passed | 0 错误，1 个 `README.md` 缺失警告 |
| HAP 构建 | passed | `build-harmony.ps1` 成功生成 debug HAP；编译无错误，但有非阻断的 target SDK 和 ArkTS 提示 |
| 模拟器可用性 | passed | DevEco Emulator 已启动 |
| 模拟器部署 | passed | HAP 安装成功，并以 `com.ledscroll.banner/EntryAbility` 启动 |

## 检查结果

| 场景 | 前置状态 | 用户操作 | 期望后果 | 结果 | 证据 |
|------|---------|---------|---------|------|------|
| 首页加载 | 首次启动 | 打开应用 | 显示默认配置 | passed | 模拟器显示默认“Hello World”首页 |
| 文字输入 | 首页 | 修改文字 | 预览区实时更新 | passed | 输入后预览文字同步改变 |
| 模式切换 | 首页 | 点击静态模式芯片 | 高亮切换 | passed | 静态芯片显示选中状态 |
| 预设配色 | 首页 | 点击红色预设 | 预览颜色与选中态更新 | passed | 预览文字变为红色，色球出现白色选中环 |
| 全屏显示 | 首页已配置 | 点击开始 | 进入全屏LED | passed | 黑底红字静态字幕已显示，并出现首次操作引导 |
| 双击暂停 | 全屏播放中 | 双击屏幕 | 动画暂停 | untested | 本轮只验证静态显示进入全屏 |
| 历史恢复 | 有历史记录 | 点击记录项 | 恢复配置并显示 | untested | 未逐项验证 |
| 计数器 | 计数器页 | 点击+/- | 数字变化 | untested | 未逐项验证 |

## 多设备覆盖

| 设备类型 | 状态 | 说明 |
|---------|------|------|
| phone | passed | DevEco Emulator 上已安装并验证核心流程 |
| tablet | untested | 未启动对应设备 |
| 2in1 | untested | 未启动对应设备 |

## 结论

已完成 HAP 构建、模拟器安装和首页核心流程验证。构建阶段没有错误，但保留非阻断的 target SDK 配置与 ArkTS 提示。审查报告所列 26 项中，只有本表标记为 `passed` 的项目具备本轮运行时证据；其余功能和 tablet/2in1 覆盖仍需后续逐项复测。

## 2026-08-03 UI 重设计验证

| 检查项 | 结果 | 证据 |
|------|------|------|
| UI 合同测试 | passed | `scripts/test-ui-contract.ps1`，0 个失败 |
| 标准检查 | passed | `scripts/check-standard.ps1`，0 错误，1 个既有 README 警告 |
| debug HAP 构建 | passed | `entry/build/default/outputs/default/entry-default-unsigned.hap`，600538 bytes |
| 模拟器安装与启动 | passed | `hdc install -r`、`aa start` 均成功，目标 `127.0.0.1:5555` |
| 首页视觉与首屏完整性 | passed | `docs/qa/led-home-final.png` |
| 场景模板双列卡片 | passed | `docs/qa/led-template.png` |
| 历史记录真实数据卡 | passed | `docs/qa/led-history.png` |
| 自定义颜色 HSV/RGB | passed | `docs/qa/led-color.png` |
| 计数器页面 | passed | `docs/qa/led-counter.png`；点击加号后布局树数字由 0 变为 1 |
| 开始显示路由 | passed | `docs/qa/display-layout.json` 中 `pagePath` 为 `pages/DisplayPage` |
| tablet/2in1 | static passed | 构建通过；配置页最大宽度、模板 2/3/4 列断点和计数器最大尺寸已实现，当前无对应在线设备截图 |

最终 phone 截图确认无文字裁切、控件重叠或空白画布。构建仍包含项目既有的 ArkTS 弃用 API/可能抛异常警告，均为非阻断项；遵循项目边界未改 targetSdkVersion、签名或应用标识。

## 2026-08-05 修复后本地回归 QA

**环境**：HarmonyOS SDK 22 项目工作区；DevEco Emulator `127.0.0.1:5555`，`com.ledscroll.banner/EntryAbility`。

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 项目结构、配置、路由和资源标准检查 | passed | `scripts/check-standard.ps1`，0 错误、0 警告 |
| UI、窗口和构建脚本合同 | passed | `test-ui-contract.ps1`、`test-window-layout.ps1`、`test-build-script.ps1`、`test-build-bootstrap.ps1` |
| 业务闭环回归合同 | passed | `test-business-contract.ps1` |
| ArkTS 编译回归 | passed | `test-arkts-compile.ps1`，Debug HAP 成功生成 |
| Debug 构建 | passed | `build-harmony.ps1 -BuildMode debug`，产物 `entry-default-unsigned.hap` |
| Release 构建 | passed | `build-harmony.ps1 -BuildMode release`，产物 `entry-default-unsigned.hap` |
| 修复后设备运行时回归 | passed | `hdc install -r`、`aa start` 和截图已完成；首页、模板、历史、计数器页面均确认标题位于 `y=137` 安全边界下，系统手势区为主题深色 |

### 待独占设备时间片的最小矩阵

| 场景 | 核验重点 |
|------|------|
| 冷启动、首页输入和重启 | 配置加载、输入边界、预览同步和持久化 |
| 模式选择、展示启动、单双击 | 8 种模式入口、暂停/恢复、退出按钮和重复点击 |
| 模板、历史和颜色 | 编辑启动、使用/删除/清空、HSV/RGB 合法与非法输入、重启后数据 |
| 计数器与生命周期 | 加减/重置/重启、后台暂停/前台恢复、系统栏恢复 |
| 竖屏/横屏展示 | 方向请求、全屏、安全区和返回恢复 |

预计独占设备时间：约 15 分钟。

## 2026-08-05 底部导航对齐回归

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 底部导航标签居中合同 | passed | `scripts/test-ui-contract.ps1`，检查 `buildBottomNav()` 的标签 `TextAlign.Center` |
| 首页底部导航设备截图 | passed | `docs/qa/led-tabbar-aligned.jpeg`；四个标签均位于对应图标正下方 |
| Debug 构建与安装启动 | passed | `scripts/build-harmony.ps1 -BuildMode debug`、`hdc install -r`、`aa start` |

本次修复未改变 tab 顺序、路由映射、图标大小或安全区布局。

## 2026-08-05 首页其他设置间距回归

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 其他设置垂直间距合同 | passed | `scripts/test-ui-contract.ps1`，检查 38 行高和 6 上下内边距共享常量 |
| 首页滚动后的设备布局 | passed | `docs/qa/led-other-settings-spacing-scrolled.jpeg`；三行控件完整可见且间距均匀 |
| Debug 构建与安装启动 | passed | `scripts/build-harmony.ps1 -BuildMode debug`、`hdc install -r`、`aa start` |

本次布局调整未改变开关状态绑定、点击区域、底部开始按钮和 TabBar。

## 2026-08-05 常规 UI 字号回归

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 统一字号合同 | passed | `scripts/test-ui-contract.ps1`，检查 `AppTheme.uiFontSize()` 在常规页面使用 |
| 首页字号与滚动布局 | passed | `docs/qa/led-font-scale-scrolled.jpeg`；字号放大后无文字裁切、控件重叠 |
| Debug 构建与设备启动 | passed | `scripts/build-harmony.ps1 -BuildMode debug`、`hdc install -r`、`aa start` |

本次字号调整未改变用户设置的 LED 字幕字号、计数器大数字、路由或交互行为。

## 2026-08-05 常规 UI 字重回归

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 统一字重合同 | passed | `scripts/test-ui-contract.ps1`，检查常规页面使用 `AppTheme.UI_FONT_WEIGHT` |
| 首页加粗后布局 | passed | `docs/qa/led-font-weight-scrolled-full.jpeg`；文字更清晰且无裁切、重叠或错位 |
| Debug 构建与设备启动 | passed | `scripts/build-harmony.ps1 -BuildMode debug`、`hdc install -r`、`aa start` |

本次字重调整保留标题、主按钮和 LED 字幕的既有 Bold 层级。

## 2026-08-05｜应用图标上架资源回归

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 应用图标资源尺寸与内容 | passed | `scripts/test-icon-assets.ps1` 通过；`app_icon.png` 和 `startIcon.png` 均为 1024x1024，且不是纯色占位资源 |
| 清单资源引用 | passed | `AppScope/app.json5` 引用 `$media:app_icon`；Ability 的 `icon` 和 `startWindowIcon` 引用 `$media:startIcon` |
| 应用图标视觉检查 | passed | 统一使用实际 LED 设备图标，主体具有安全留白，未出现纯绿色占位图 |
| 静态检查 | passed | `scripts/check-standard.ps1` 通过，0 错误、0 警告 |
| Debug/设备验证 | passed | Debug HAP 构建成功；`hdc install -r` 和 `aa start` 成功；`bm dump -n com.ledscroll.banner` 读取到应用 `$media:app_icon` 与 Ability `$media:startIcon` |

## 2026-08-07 审核问题修复 QA

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 固定 UI 对比度 | passed | `TEXT_MUTED #8793A8`、`ON_ACCENT #00131A`；七组实际比值为 18.66、7.91、5.56、12.32、5.57、5.83、10.13；用户 LED 颜色不在强制范围 |
| 常规页状态栏/安全区 | passed | `docs/qa/2026-08-07-home-5555.png` 与 `docs/qa/2026-08-07-home-5555.json` 显示深色状态栏连续背景、浅色系统内容和 `PAGE_BG` 手势区 |
| 展示页隐藏系统栏 | passed | `docs/qa/2026-08-07-display-5555.png` 与 `docs/qa/2026-08-07-display-5555.json`：`pages/DisplayPage` 根节点 `[0,0][2856,1320]`，横屏画面无系统栏 |
| 展示页退出恢复 | partial | 退出按钮可在 `docs/qa/2026-08-07-display-exit-5555.json` 中定位，自动化退出命令已发出；因未保留可归因的 after-state transcript/截图，且共享前台随后被其他应用抢占，运行时恢复证据仍为 partial。方法级静态窗口合同证明已配置的恢复路径为 `exitDisplayMode()` 调用 `applyAppChrome()` |
| 边缘反馈（static passed / runtime observed / animation capture partial） | static passed / runtime observed / animation capture partial | 静态 `test-ui-contract.ps1` 证明首页 Scroll、颜色 Scroll、模板横向 Scroll/纵向 Grid、历史 List 精确使用 Spring + alwaysEnabled，两个首页布局 Grid 排除；UITest 边界滑动返回 `No Error` 且应用保持响应。`docs/qa/2026-08-07-color-5555.png`、`docs/qa/2026-08-07-template-refocused-5555.png`、`docs/qa/2026-08-07-history-5555.png` 只证明滑动后的页面状态，不证明瞬态 Spring 运动 |
| 分层图标 | passed | 四个分层 PNG 与 `startIcon.png` 均为 1024x1024；背景完全不透明且无圆角遮罩，前景透明并满足 80px 安全区；设备元数据引用正确 |
| 标准/独立回归 | passed | `check-standard.ps1` 0 错误、0 警告；UI、业务、构建脚本/引导、ArkTS 编译回归均 exit 0 |
| debug 构建 | passed with limitation | signed HAP 2,322,096 bytes；增量 `CompileArkTS` 为 `UP-TO-DATE`，本次无新告警输出但不等于历史 ArkTS 告警清零 |
| phone / 2in1 | partial / launch passed | 两目标安装启动成功；phone 覆盖主要路径但受共享前台干扰。2in1 app-only 证据为 `docs/qa/2026-08-07-home-5557-app.png`（2091x1394）与 `docs/qa/2026-08-07-home-5557.json`；模板重新拉起后的截图对应 `docs/qa/2026-08-07-refocused-5555.json`，`docs/qa/2026-08-07-template-5555.json` 为此前独立快照 |
| tablet | waiting | `hdc list targets` 无 tablet 目标 |

结论：`DONE_WITH_CONCERNS`。产品要求、静态合同、构建、phone/2in1 安装启动与 phone 主要运行路径已完成，`T-20260807-001` 标记为 `done`。剩余关注项仅为非阻断证据增强：独占 phone 时间片补录 Spring 瞬态动画和不受共享前台干扰的退出恢复画面；tablet 因无在线目标未覆盖。

### 反转白背景固定覆盖层

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 固定覆盖层静态合同 | passed | `DISPLAY_OVERLAY_FG #FFFFFF` 对 `DISPLAY_OVERLAY_BG #07111F` 为 18.94:1；暂停、引导、退出三类固定 UI 均引用该颜色对，且不读取用户展示色。该合同已纳入既有可访问性静态检查 |
| 当前 signed debug HAP | passed | 使用最新 `entry-default-signed.hap`（2,321,741 bytes）覆盖安装到 `127.0.0.1:5555`，随后强停并启动 `com.ledscroll.banner/EntryAbility`，安装/启动命令成功；本轮未重复构建 |
| 白色背景设备显示 | passed | `docs/qa/2026-08-07-display-white-overlay-5555.png` 与 `docs/qa/2026-08-07-display-white-overlay-5555.json`：`pages/DisplayPage` 根节点 `[0,0][2856,1320]`，动态展示背景 `#FFFFFFFF`；底部引导层和退出按钮背景为 `#FF07111F`，截图中浅色固定文字/符号清晰可读且不含敏感内容 |
| 暂停覆盖层 | not observed | UITest 双击命令返回 `No Error`，但最终布局没有“已暂停”节点；因此只证明引导/退出覆盖层与白色用户背景解耦，不对暂停状态切换或动画暂停作运行时结论 |

## 2026-08-07 竖屏纵向字幕边界回归

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| RED/GREEN 业务合同 | passed | 旧端点触发 5 项预期失败；使用 `travelLimit = (screenHeight + textHeight) / 2` 后 `scripts/test-business-contract.ps1` 通过 |
| 竖屏方向 | passed | phone 关闭“横屏显示”后展示页保持 `1320x2856`，滚动轴为屏幕下边到屏幕上边 |
| 下边进入、上边退出、连续循环 | passed | `docs/qa/2026-08-07-portrait-vertical-a-5555.png` 至 `-h-5555.png` 连续覆盖顶部离开、底部重入和画面内上移；计时器未在顶部可见阶段强制重置 |
| 稳定性 | passed | 多轮截图后 `pidof com.ledscroll.banner` 仍返回活动进程，展示页保持响应 |
| 标准检查与构建 | passed | `check-standard.ps1` 0 错误、0 脚本警告；`build-harmony.ps1` 为 `BUILD SUCCESSFUL`，signed HAP 2,321,693 bytes |
| 其他设备 | partial | 2in1 已覆盖安装并启动；本问题的竖屏纵向动画以 phone 为直接验收目标。当前无在线 tablet |

结论：`T-20260807-002` 通过。用户截图中的“到达上边后突然消失”由中心坐标端点错误导致，现已改为完整出屏后循环。

## 2026-08-07 纵向字幕平滑入场回归

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 问题归因 | passed | 循环位移重置到 `startPos` 时旧逻辑仍保持 `textOpacity = 1.0`，首批进入画布的像素直接满亮显示，形成闪现感 |
| RED/GREEN 业务合同 | passed | 新合同在实现前准确失败 3 项；实现后 `scripts/test-business-contract.ps1` 通过，并锁定 `entryFadeDistance`、零透明度起点和距离驱动的透明度计算 |
| 入场渐显 | passed | `startScrollV()` 首次起步和两个方向的循环重置均设为 `0.0`；每帧使用 `min(abs(offsetY - startPos) / max(textHeight, 1), 1.0)` 平滑增亮 |
| 原有行为保持 | passed | 对称 `travelLimit`、`startPos/endPos`、`duration`、`steps` 和 `increment` 未变；横向及其他模式未修改，横竖屏仍读取现有 `isLandscape` 配置 |
| 静态检查与构建 | passed | `check-standard.ps1` 0 错误、0 脚本警告；`build-harmony.ps1` 为 `BUILD SUCCESSFUL`，signed HAP 2,321,332 bytes，SHA-256 `7C658C6F4A66F8FE3B61B0B192C412A0804399DFE95251675A8D56174B8C06CB` |
| 2in1 运行时取样 | passed with limitation | `entry-fade-page-5557.json` 确认 `pages/DisplayPage`；`entry-fade-sample-01-5557.jpeg` 至 `-05-5557.jpeg` 为 0.1/0.25/0.45/0.7/1.0 秒受控取样，覆盖屏外透明起点、下边出现及向上移动，且窗口保持横屏。共享前台干扰使其不是一段连续录像，因此透明度中间值以静态合同为精确证据 |
| 稳定性与其他设备 | passed / partial | 取样后 2in1 `pidof com.ledscroll.banner` 返回活动进程；phone 新 HAP 覆盖安装成功但被另一应用反复抢前台，错误外部截图已删除且未作为证据；当前无在线 tablet |

结论：`T-20260807-003` 通过。纵向字幕仍按当前画布从下边进入、从上边完整离开，循环重置不再以满亮度突兀闪现，也没有新增强制竖屏行为。

## 2026-08-07 API 22 上架就绪回归

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| API 与发布包元数据 | passed | HAP `pack.info` 的 compatible/target 均为 22；设备类型为 phone、tablet、2in1；包名与 versionCode 未改 |
| 单机与隐私边界 | passed | HAP 权限数为 0，`allowToBackupRestore=false`；发布合同未发现网络权限、网络 SDK 或请求代码 |
| 分层图标 | passed | app/Ability 前景与背景均为 1024x1024；背景不透明，前景 alpha 内容满足 80px 安全区；两个前景哈希一致、两个背景哈希一致 |
| 双击暂停/恢复 | passed | phone 证据 `2026-08-07-release-display-final-before-5555.json`、`-paused-5555.json`、`-resumed-5555.json`；2in1 对应 `-5557.json`，暂停态均出现“已暂停”，再次双击后消失 |
| 沉浸式进入/退出 | passed | phone 展示页根节点 `[0,0][2856,1320]`，退出并稳定后 `2026-08-07-release-display-final-exit-settled-5555.json` 返回 `pages/HistoryPage` 和普通安全区 `[0,137][1320,2856]`；2in1 在桌面应用窗口内进入展示并返回 `pages/Index` |
| 历史次数即时刷新 | passed | 修复前证据显示返回后仍为“使用8次”、重新进入才为“使用9次”；修复后 `2026-08-07-release-history-after-final-5555.json` 在同一页面立即由“使用9次”更新为“使用10次” |
| 标准检查与回归合同 | passed | `scripts/check-standard.ps1`：0 错误、0 警告；UI、业务、窗口、响应式、发布和图标合同均通过 |
| 干净 Debug/Release 构建 | passed | 两次先执行 `hvigorw clean`，随后完整 ArkTS 编译均 `BUILD SUCCESSFUL` 且无编译警告；最终 Release HAP 2,083,497 bytes |
| 最终 HAP 安装启动 | passed | 最终 Release 包覆盖安装到 phone/2in1；`2026-08-07-release-final-launch-5555.json` 与 `-5557.json` 均为 `pages/Index` |
| 系统版本覆盖 | passed / waiting | phone 为 OpenHarmony 6.0.2.130；2in1 为 6.1.1.125；`hdc list targets` 没有 tablet，tablet 保留为提交前验收项 |

结论：`T-20260807-004` 的仓库内修复和可用设备验证通过。AppGallery Connect 主体资料、正式隐私政策 URL、正式证书核对、官方图标蒙版预览、商店截图以及真实 tablet 验收仍须由上架主体在提交前完成。

## 2026-08-11 AppGallery 验收回归

| 检查项 | 结果 | 证据/说明 |
|------|------|------|
| 名称与标识 | passed | AppScope `app_name`、EntryAbility label/description 均为 `光迹字幕`；HAP 清单保持 `com.ledscroll.banner`、`1.0.0` / `1000000` |
| 图标一致性 | passed | `test-icon-assets.ps1` 通过；app/Ability 的背景层 SHA-256 均为 `8F045ED494D2BC05E802FCC8F56FCE5C9BE46FB7B01E55CD99A59C8EC465DBFD`，前景层均为 `2F7D8E0E60C681D779F925705291892CC0AA39CCD7C3463EBBA16ADA09067515` |
| 普通页与展示页窗口 | passed | `test-window-layout.ps1` 与 `test-appgallery-acceptance.ps1` 均通过；普通页为非全屏且不扩展系统安全区，展示页仍全屏隐藏系统栏 |
| 固定 UI 字号与对比度 | passed | AppGallery 合同未发现 10/11fp 固定 UI 调用；`test-accessibility-contract.ps1` 通过 |
| 标准检查与构建 | passed with signing handoff | `scripts/check-standard.ps1`：0 错误、0 警告；`scripts/build-harmony.ps1`：`BUILD SUCCESSFUL`；基线空签名配置生成 unsigned HAP 2,285,937 bytes，SHA-256 `205EDF11C36D9136550D3C027804193B591C8AA6172763D421C0B023C8828908`。正式签名不写入仓库，由受控外部流程完成 |
| HAP 清单与资源 | passed | 包内有 app/Ability 两个分层描述符及四个 PNG 图层；清单为零权限、app `$media:app_icon`、Ability `$media:layered_image` |
| phone 安装、启动和截图 | passed | `127.0.0.1:5555` 覆盖安装并启动成功，进程保持存活。`2026-08-11-appgallery-home-5555.png/json` 为普通首页，根节点 `[0,137][1320,2856]`；`-display-5555.png/json` 为展示页全屏 `[0,0][2856,1320]`；Back 后 `-exit-5555.png/json` 返回首页普通安全区与 `#FF030A16` 页面背景 |
| tablet / 2in1 | not run | 当前 `hdc list targets` 只发现 phone `127.0.0.1:5555`；`COM3` 与 `COM4` 仍非可连接目标 |

结论：`T-20260810-001` 的源码、合同、HAP 和 phone 运行时验收已通过。tablet 和 2in1 待目标连接后补做，不能由历史截图替代。

## 2026-08-11 可识别名称复核

| 检查项 | 结果 | 证据 |
|---|---|---|
| 用户可见名称 | passed | AppScope `app_name`、EntryAbility label/description 和 Index 标题均为 `光迹字幕`；已安装应用与启动器证据为 `2026-08-11-appgallery-name-app-5555.*` 和 `2026-08-11-appgallery-name-launcher-5555.png`。 |
| 图标一致性 | 资源合同通过 | app `$media:app_icon` 与 Ability `$media:layered_image` 的前景/背景 PNG 哈希一致。共享模拟器最近任务截图不能独立归因，因此不作为视觉证据。 |
| 对比度、状态栏、字号 | 合同与 phone 布局通过 | 验收/无障碍/窗口合同要求固定正文 >= 4.5:1、标题/图标 >= 3:1、固定 UI >= 12fp、普通页保留安全区，只有 `DisplayPage` 全屏。 |
| Release 上架资格 | 提交受阻 | `build-profile.json5` 故意不包含仓库内签名配置；生成的 Debug HAP 未签名。上传需经批准的外部签名 Release HAP 和提交时确认。 |

## 2026-08-11 鸿蒙问题排查表全量审计 QA

| 检查项 | 结果 | 证据/说明 |
|---|---|---|
| 11 项适用性矩阵 | passed | `docs/qa/2026-08-11-troubleshooting-table-audit.md` 对编号 1-11 各有且仅有一个结论；其他应用的提醒、日历、账单、专注、时钟和白噪音问题明确标记不适用。 |
| 28vp RED/GREEN | passed | 合同先以缺少 `SYSTEM_BOTTOM_PADDING: number = 28` 失败 1 项；实现从 24 改为 28 后 `test-responsive-layout.ps1` 通过。 |
| 开关主题 RED/GREEN | passed | 合同先报告缺少两个颜色常量、共享选中色和 `switchStyle` 共 5 项；实现后 `test-accessibility-contract.ps1` 通过。 |
| 开关对比度 | passed | 关闭轨道/面板 5.94:1，滑块/关闭轨道 6.11:1，滑块/选中轨道 12.32:1；开关状态同时有位置差异。 |
| 名称与图标 | passed / external handoff | AppScope、EntryAbility 和首页标题均为 `光迹字幕`；app/Ability 背景层哈希一致、前景层哈希一致。AppGallery Connect 商品资料需由上架主体同步。 |
| 状态栏、字号、响应式、固定对比度 | passed | `check-standard.ps1` 内的窗口、AppGallery、响应式、可访问性和图标合同均通过；脚本结果 0 错误、0 警告。 |
| parse / UI / business | passed | `test-parse.ps1` 输出 `ok`；`test-ui-contract.ps1` 与 `test-business-contract.ps1` 均通过。 |
| ArkTS / Debug 构建 | passed with expected signing notice | `test-arkts-compile.ps1` 与 `build-harmony.ps1` 均 `BUILD SUCCESSFUL`；unsigned HAP 2,286,536 bytes，SHA-256 `2054CB280DD5D18971316FD23385D9177B662F3CF4707D3BA2C016C34C2EDA01`。唯一构建提示为仓库故意没有签名配置。 |
| phone 普通页安全区 | passed | `2026-08-11-troubleshooting-home-5555.*` 与 switch 布局：Index 根节点 `[0,137][1320,2856]`，应用内容列止于 `y=2758`，tab 内容止于 `y=2660`，底部保留 98px；左右边缘无裁切。 |
| phone 开关关闭态 | passed | `2026-08-11-troubleshooting-switch-off-5555.png/json`；首个 Toggle `checked=false`，边界 `[1097,1673][1244,1764]`，灰色关闭轨道和深色滑块清晰可辨。 |
| phone 展示页 | passed | `2026-08-11-troubleshooting-display-5555.png/json`；`pages/DisplayPage` 覆盖 `[0,0][2856,1320]`，无系统栏遮挡。 |
| 展示页退出恢复 | partial | 本轮退出阶段共享 phone 被另一款“宠物陪伴”应用抢占前台，无法保留可独立归因的 after-state；方法级窗口合同通过，同日较早的 `2026-08-11-appgallery-exit-5555.*` 已记录可归因恢复证据。 |
| tablet / 2in1 | not run | `hdc list targets` 仅有 phone `127.0.0.1:5555`；不把 phone 结果外推为本轮多设备运行时证据。 |

结论：仓库内适用问题已修复并通过全量本地验证，phone 取得普通页、关闭态开关和全屏展示证据。剩余事项是外部商店资料/正式签名，以及本轮无法连接的 tablet/2in1 和受共享前台干扰的退出恢复补证，不是新增源码缺陷。
## 2026-08-11 底部安全区颜色回归

| 检查项 | 结果 | 证据 |
|---|---|---|
| 白色安全区复现 | passed (before fix) | 用户截图与模拟器基线复现显示底部手势区为白色，而首页内容/底部导航为 `#030A16`。 |
| RED/GREEN 生命周期契约 | passed | `scripts/test-window-layout.ps1` 在缺少内容加载完成后的 `applyAppChrome()` 时失败；加入回调重应用契约和 `setWindowBackgroundColor(AppTheme.PAGE_BG)` 后通过。 |
| phone 设备视觉结果 | passed | `docs/qa/2026-08-11-safe-area-color-5555.png`：首页底部手势安全区与应用深色背景一致；对应布局记录为 `docs/qa/2026-08-11-safe-area-color-5555.json`。 |
| 静态检查与构建 | passed | `scripts/check-standard.ps1`、`test-window-layout.ps1`、ArkTS 编译和 `scripts/build-harmony.ps1` 均通过；产物为 unsigned Debug HAP。 |

结论：普通页面的系统手势安全区已与应用主题统一；`DisplayPage` 的独立全屏路径保持不变。当前仅有 phone `127.0.0.1:5555` 可用于运行时截图，tablet/2in1 未连接。

## 2026-08-11 排查表复核回归

| 检查项 | 结果 | 证据 |
|---|---|---|
| 名称与图标一致性 | passed / external handoff | `AppScope app_name`、EntryAbility label/description、Index 标题均为 `光迹字幕`；`2026-08-11-icon-name-launcher-final-5555.jpeg` 与 `2026-08-11-icon-name-recents-final-5555.jpeg` 在 phone 启动器和最近任务均显示同一名称/图标；商店商品资料仍需人工同步 |
| 点阵文字对比度 | passed | `LedPanel` 与 `CounterPage` 点阵均使用 `LED_MATRIX_DOT_COLOR #8793A8` 和 `LED_MATRIX_DOT_OPACITY 0.85`；颜色对 `PAGE_BG` 6.56:1，点阵不再使用 `#0089D2`/0.48 或用户颜色 |
| PC/2in1 最小字号 | passed | `LED_MATRIX_DOT_FONT_SIZE = 10`，AppGallery 合同拒绝 8/缺失 token；主 LED 字幕仍是用户内容字号 |
| 状态栏/安全区 | passed on phone / multi-device pending | phone fresh layout 首页根节点 `[0,137][1320,2856]`，标题 y=290 起；普通页非全屏、展示页独立全屏合同通过；本轮无在线 tablet/2in1 |
| RED/GREEN 合同 | passed | AppGallery 合同先拒绝点阵 8fp/缺少共享字号，accessibility 合同先拒绝点阵颜色/透明度，修复后均通过 |
| 构建与运行 | passed with signing handoff | `check-standard.ps1`、parse/UI/business/accessibility/AppGallery、ArkTS 编译和 `build-harmony.ps1` 均通过；最终 unsigned Debug HAP 2,288,292 bytes，SHA-256 `B126C29FCA829C49E056E3E18FAAE8BF4CAED7B2E9E0EEAB475C0CE33D045F40`；正式签名仍走外部受控流程 |

结论：本轮发现的仓库内残留问题已完成最小修复，最终结论以全量构建和重新安装后的 phone 证据为准；AppGallery Connect 名称/图标和正式签名仍属于提交人外部交接。

## 2026-08-11 鸿蒙上架规范复核

| 检查项 | 结果 | 说明 |
|---|---|---|
| 排查表 11 项适用性 | passed | 适用源码问题已修复；提醒、日历、专注、时钟、白噪音等其他产品问题标为不适用 |
| 对比度/字号/安全区/状态栏 | passed on phone | 静态契约和 phone 截图通过；tablet/2in1 仍需真实目标验收 |
| 名称与图标 | package/runtime passed; AGC pending | AppScope、Ability、安装后启动器和最近任务一致；AGC 商品资料及软件资质名称仍需人工同步 |
| 构建 | passed with signing handoff | Debug unsigned HAP 构建成功；正式提交必须换成受控签名的 Release HAP |
| 隐私与资质 | external pending | 隐私政策目前是仓库文档，尚未证明已发布为公开 URL；版权/资质按发行区域由提交主体提供 |

结论：代码自测通过，但尚未满足“可直接提交上架”的外部发布条件。

## 2026-08-12 展示对比度与点击响应 QA

| 检查项 | 结果 | 证据 |
|---|---|---|
| RED/GREEN 展示安全合同 | passed | 新合同初始失败 21 项（无共享保护、显示入口先写盘、低透明度动画和阻塞操作）；实现后 `scripts/test-display-safety-contract.ps1` 通过，覆盖黑/白后备、全屏与预览渲染边界、首页/模板/历史入口和颜色/计数器即时更新。 |
| 动画对比度 | passed | `DisplayPage` 不再存在 `textOpacity`、`entryFadeDistance` 或 `opacity(0.9)`；呼吸、闪烁、翻页均采用 `textScale`，可见字符保持完全不透明。 |
| phone 白底字幕 | passed | 目标 `127.0.0.1:5555` 安装当前 HAP 后选择“反转白”并立即点击“开始显示”；在 200ms 采样时布局为 `pages/DisplayPage`，根区域 `[0,0][2856,1320]`。截图 `docs/qa/2026-08-12-final-display-5555.jpeg` 显示白底黑字。 |
| phone 颜色确认 | passed | 在 `pages/ColorPickerPage` 点击“确认选择”后 120ms 导出的 `docs/qa/2026-08-12-color-confirm-5555.json` 已为 `pages/Index`，确认不等待 Preferences 写入才返回。 |
| phone 连续计数 | passed | `pages/CounterPage` 连续三次点击加号，150ms 后布局数值从 `20` 到 `23`（`docs/qa/2026-08-12-counter-instant-5555.json`）；等待后台队列后重启应用仍为 `23`（`docs/qa/2026-08-12-counter-restart-5555.json`）。 |
| 解析、业务、无障碍、UI/响应式/窗口/发布/图标合同 | passed | `test-parse.ps1`、`test-business-contract.ps1`、`test-accessibility-contract.ps1`、`test-ui-contract.ps1`、`test-responsive-layout.ps1`、`test-window-layout.ps1`、`test-release-contract.ps1`、`test-icon-assets.ps1` 均通过。 |
| ArkTS 与构建 | passed | 最新构建 `BUILD SUCCESSFUL`；产物 `entry/build/default/outputs/default/entry-default-signed.hap`，2,336,838 bytes，SHA-256 `D4EDF3A38868F9B77D9459FD54F8D5A3546A6D72F085A47331F459BD13F24C2E`。 |
| AppGallery 合同 | blocked by pre-existing workspace change | `test-appgallery-acceptance.ps1` 仅报告 `build-profile.json5` 含 tracked signing configuration/material。该文件在本任务前已带有敏感签名改动，按项目安全约束未读取、记录或修改；因此不能据此宣称仓库已满足最终上架包要求。 |

结论：本轮覆盖的展示颜色、动画帧和用户可见点击结果已经由代码合同、构建和 phone 运行时回归验证。上架前仍必须先从版本库和构建配置移除已跟踪的签名材料，并使用受控外部签名流程生成最终提交包；tablet/2in1 仍需在可用目标上复验。

## 2026-08-12 HarmonyOS App Quality 全局技能 QA

| 检查项 | 结果 | 证据 |
|---|---|---|
| 官方来源 | passed | 已读取用户提供的 4 个华为页面，并沿点击完成 FAQ 的官方引用补读“应用性能体验建议-时延”；记录页面标题、更新时间、来源权重和 URL。 |
| UX 条款完整性 | passed | `references/general-ux-standard.md` 包含 39 个唯一标准编号，覆盖基础体验、动效和系统特性；保留等级、设备范围、阈值与证据方法。 |
| 性能与 FAQ | passed | 记录应用启动 `<=1100ms`、点击响应 `<=100ms`、应用点击完成 `<=900ms`、滑动与视频阈值；点击完成采用 FAQ 的 `T2-T1` 定义，并记录三类图标拒审案例。 |
| AppGallery 审核路由 | passed | `references/appgallery-review-guide.md` 覆盖应用信息、安全、功能、内容、广告、付费、隐私、未成年人、知识产权、资质、开发者行为、品类要求和不收录类型。 |
| 技能结构 | passed | `quick_validate.py` 输出 `Skill is valid`；`SKILL.md`、`agents/openai.yaml` 和 3 个 reference 文件齐全，未残留 TODO/TBD。 |
| 全局安装 | passed | 安装位置为 OpenAI 官方 Codex 文档列出的用户级目录 `C:\Users\27363\.agents\skills\harmonyos-app-quality`；旧 `.codex/skills` 副本不存在；安装版 5/5 文件与测试版哈希一致。 |
| 前向测试 | passed | 无技能基线误把 48vp 推荐值当成强制值且混入无来源阈值；技能测试正确输出 48/40vp、2in1 5mm/7mm、`<=100ms`/`<=900ms`、图标 1024px 分层要求和手持弹幕差异化风险。 |
| 项目标准检查 | partial / pre-existing blocker | accessibility、display-safety、responsive、window、icon、release 合同通过；AppGallery 合同仅因任务前已修改的 `build-profile.json5` 含 tracked signing configuration/material 而失败，本任务未读取或修改该材料。 |
| 构建 | passed | `scripts/build-harmony.ps1` 输出 `BUILD SUCCESSFUL`；产物 `entry/build/default/outputs/default/entry-default-signed.hap`，2,336,836 bytes。 |
| 设备验证 | not run | 当前环境未找到可用 `hdc` 可执行文件；本任务无 UI/运行时变更，未生成新的设备证据。 |

结论：全局技能已通过来源、结构、内容、前向使用和安装一致性验证。项目构建成功，但不能把现有签名材料导致的 AppGallery 合同失败写成通过；设备覆盖保持未验证。

## 2026-08-12 鸿蒙自检增量 QA

| 检查项 | 结果 | 证据 |
|---|---|---|
| URL 归一化与去重 | passed | 重复的 `50104-01/03` 归一为当前 `50104`；粘连输入拆出 `80301`、`50104-03` 和 FAQ；`classify-0000001960172909` 跳转至 `classify-1`；`50104-0` 为 404。 |
| 无正文来源 | unverified / omitted | `0203198799217774051` 没有可核实标题、描述或正文；深色与状态栏 FAQ 仅取得页面标题/描述，因此新增操作仍以 UX 2.2.5/2.2.6 为规则来源，未臆造正文。 |
| RED 契约 | passed | 新契约对旧安装版非零退出，报告缺少新 reference、路由及分类/备案/深色/系统栏触发语义共 10 项。 |
| GREEN 契约 | passed | 工作副本和全局安装版均通过 `scripts/test-harmonyos-self-check-skill.ps1` 的 50 条断言；确认 28vp 限定、五类布局信号、六类底部场景、分类/资质路由和禁止重复阈值。 |
| 结构校验 | passed | `PYTHONUTF8=1` 下 `quick_validate.py` 输出 `Skill is valid!`。 |
| 安装一致性 | passed | `SKILL.md`、`agents/openai.yaml`、`release-preflight-cases.md` 的工作副本/安装版 SHA-256 成对一致；三个既有 reference 的 SHA-256 也保持一致。 |
| 代表性评估 | passed | `.superpowers/harmonyos-self-check-evals/results.md` 的三组场景分别拒绝常量即通过、整份资质目录和源码即深色通过，并在缺少运行时/AGC 证据时使用 `unverified`。 |
| 应用运行时 | not applicable | 本任务只更新用户级 skill 和项目记录，没有修改 ArkTS、资源、清单、签名或 UI；不产生新的设备行为证据。 |
| HarmonyOS 构建 | passed | `scripts/build-harmony.ps1` 输出 `BUILD SUCCESSFUL`；`entry-default-signed.hap` 为 2,336,836 bytes，SHA-256 `82990C4C42D807CBF06DBFBB3A12A6FB75A948710971C19E1A363485B0321583`。 |
| 项目标准检查 | failed / pre-existing blockers | accessibility、display-safety、responsive、window、icon、release 合同通过；AppGallery rejection-remediation 合同有 9 项既有应用/发布文档差异，AppGallery acceptance 合同有 3 项既有 tracked-signing 差异。本任务未修改其涉及的应用、发布或签名文件。 |

结论：`鸿蒙自检` 的本次增量已完成 RED/GREEN、结构、安装哈希和代表性行为验证，HarmonyOS 构建成功。项目全局标准检查不能宣称通过，其 12 个阻断断言归属于工作区既有的应用修复/签名状态，而非本次 skill 文件。

## 2026-08-12 AppGallery 审核驳回整改 QA

| ID | Level | Devices | Applicability | Evidence | Verdict | Gap / remediation |
|---|---|---|---|---|---|---|
| AGR-01 旧 AGC 名称 `LED滚动字幕` 泛化 | 阻断 | AGC、phone/tablet/2in1 安装包 | applicable | 包内 AppScope、EntryAbility、Index、隐私政策、用户协议及 remediation 合同统一为 `光迹字幕`；phone 包内状态已验。 | unverified | AGC 商品名、简介、隐私资料和软件资质未写入；在实际保存、预览并与提交包核对前保持外部阻断。 |
| AGR-02 AGC 图标含透明像素 | 阻断；UX 2.1.4.3.1 必须 | AGC；phone/tablet/2in1 | applicable | `docs/release/appgallery-icon.png`：265,721 bytes，1024x1024，`Transparent=0`、`NonOpaque=0`、四角 alpha 255、采样颜色数 939，SHA-256 `D35D3F2B48ADC98FABFB0D63B195F9321878D80B5A0A76F62B64D5B3367BA82D`；与 AppScope 背景+前景逐像素合成一致，两次生成同哈希；icon/remediation 合同通过。 | unverified | 本地图标产物通过，但尚未上传 AGC 或检查 AGC 预览；需动作时上传并逐像素/视觉复核。 |
| AGR-03 AGC 与安装名称/图标不一致 | 阻断 | AGC、phone/tablet/2in1 | applicable | 包内唯一名称为 `光迹字幕`，运行时继续使用同源 layered icons；商店 PNG 由相同 AppScope 两层合成。最新 HAP 为 2,335,890 bytes，SHA-256 `95CE055466E51113110B5B9E2FA218DABD42C756C1A75F109A782BA1265150AE`。 | unverified | AGC 名称/图标未保存或预览；tablet/2in1 离线。上传后必须对 AGC、启动器、最近任务和包元数据做同轮核对。 |
| AGR-04 隐私模块名称不一致 | 阻断 | AGC 隐私模块、phone/tablet/2in1 包内文档 | applicable | 包内隐私政策、用户协议及身份合同均使用 `光迹字幕`，resource/Index/privacy/agreement 合同通过。 | unverified | AGC 隐私链接、隐私标签、主体资料及软件资质均未修改或验证；需动作时确认公开可达内容和 AGC 字段与实际行为一致。 |
| AGR-05 空历史“清空”对比度 `1.76/1.82/1.81/1.86` | 非本次阻断；UX 2.1.3.3 必须、2.1.4.1 推荐 | phone/tablet/2in1 | applicable | 源码合同：`records > 0` 才构建 48x48 Text，空态为无 opacity 的 48x48 `Blank`。当前 HAP 在 phone OpenHarmony `6.0.2.130`、`1320x2856` 上验证：空态 `...-current-history-5555.*` 无“清空”，尾部 `Blank` 为 `[1096,255][1264,423]`、`clickable=false`、opacity 1.0；有记录态 `...-history-populated-5555.*` 的 `清空` 为同一 168x168 px（48x48 vp）边界、完全不透明且可点击；`...-clear-dialog-5555.*` 显示确认弹窗并完成取消路径。 | partial | phone 空态、有记录态、确认弹窗和取消通过。最终确认删除时共享模拟器被其他应用抢占，未形成可归因的删除完成证据；tablet/2in1 未连接。 |
| AGR-06 点击完成 `3117ms` | 非本次阻断；性能规则 | phone/tablet/2in1 | applicable | 华为应用点击完成门槛为 `T2-T1 <= 900ms`；remediation/display-safety 合同、ArkTS 编译和构建通过，但没有可用 AppAnalyzer/DevEco Testing 精确 T1/T2 CLI 证据。 | unverified | 不能以源码顺序或构建成功替代运行时性能。需在各目标设备按 T1=手指释放、T2=目标页占位内容加载完成采集至少三次并记录最差值。 |

总体边界：本地 remediation/icon/accessibility/display-safety 合同、ArkTS 编译和构建通过；`scripts/check-standard.ps1` exit 1，仅剩未读未改的既有 `build-profile.json5` tracked signing configuration/material 三项。Phone 的空态、有记录态、48vp 清空操作、确认弹窗和取消路径有运行证据；最终确认删除、tablet/2in1 和精确性能仍未验证。AGC 名称、图标、简介、隐私、资质、包上传及重新提审未执行，不能据此宣称全绿或可上架。

## 2026-08-13 桌面与启动图标 QA

| ID | Level | Devices | Applicability | Evidence | Verdict | Gap / remediation |
|---|---|---|---|---|---|---|
| 2.1.4.3.1 分层应用图标 | 必须 | phone | applicable | AppScope 与 EntryAbility 的背景/前景各 1024x1024；背景 alpha 全 255；`scripts/test-icon-assets.ps1` 通过；phone 启动器截图显示无白边、透明洞或预裁圆角异常。 | pass | 无 phone 图标缺口。 |
| 2.1.4.3.3 图标清晰度 | 必须 | phone | applicable | 1320x2856 phone 启动器及 3 次冷启动、20/50/100 ms 过渡帧均显示清晰、未拉伸的 LED 图标。 | pass | 无 phone 图标缺口。 |
| PROJECT-START-01 独立完整启动图 | project criterion | phone | applicable | `startWindowIcon=$media:startIcon`；资源 144x144、20,704 bytes；冷启动过渡帧显示完整背景与 LED 前景，不再显示大幅透明前景或过大位图。 | pass | 144x144 是当前 DevEco Stage 模板/项目基线，不是 UX 2.1.4.3.1 官方启动图尺寸条款。 |
| 2.1.4.3.1 / 2.1.4.3.3 | 必须 | tablet, 2in1 | applicable | module 声明支持 tablet/2in1，但当前无在线目标。 | unverified | 在真实或官方目标上复测启动器、冷启动和缩放清晰度。 |
| AGC-ICON-PREVIEW | review blocking | AppGallery Connect | applicable | 本地同源商店图标合同通过，但本轮未上传或查看 AGC 预览。 | unverified | 正式提交时上传并核对 AGC 预览、包内图标与安装后图标一致性。 |
| REPO-STANDARD-CHECK | project criterion | source/repository | applicable | 图标、无障碍、display-safety、remediation、release 等组通过；响应式和窗口组各报告 5 个页面缺少旧固定 padding 表达式，AppGallery 组报告 3 个现有 tracked signing 断言。 | fail | 属于本次图标范围外的既有合同/实现与签名状态；需另行审查当前安全区实现后更新合同或实现，并移出受控签名材料。 |

构建与安装：`scripts/build-harmony.ps1 -BuildMode debug` 输出 `BUILD SUCCESSFUL`；signed Debug HAP 751,392 bytes，SHA-256 `903453DE741501D463185278FC06FF39D6169649A5C87EF282C40C1D4B749CFF`；`127.0.0.1:5555` 覆盖安装成功。全项目标准检查仍有上述非图标失败，且该包为 debug provisioning，不能据此宣称 production 上架包已就绪。
