# 任务追踪

状态定义：`pending` | `in_progress` | `done` | `blocked`

## T-20260813-ICON-RETEST

- **状态**：`in_progress`
- **目标**：更新当前依赖，从工作区最新源码重建应用，并在模拟器复测桌面图标和启动图标。
- **范围**：OHPM 依赖、图标静态合同、Debug HAP 构建、phone 启动器和三轮冷启动抓帧。

### 检查清单
- [x] 比较本地工作区与远端状态并保留现有未提交成果
- [x] 查询 OHPM 最新依赖版本并开始统一根模块与 entry 模块
- [ ] 完成图标静态合同和全量项目检查
- [ ] 从当前源码构建并覆盖安装最新 HAP
- [ ] 完成 phone 桌面图标和三轮冷启动图标复测
- [ ] 回填 changes.md 和 design-qa.md

---

## T-20260803-001

- **状态**：`done`
- **目标**：项目搭建和基础框架
- **范围**：配置文件、数据模型、服务层、通用模块、EntryAbility

### 检查清单
- [x] 创建项目目录结构
- [x] app.json5 / module.json5 / build-profile.json5 / oh-package.json5
- [x] main_pages.json 路由配置
- [x] 数据模型（BannerConfig, ColorScheme, Template, HistoryRecord）
- [x] 服务层（StorageService, ScreenService, AnimationService, TemplateService）
- [x] 通用模块（Constants, Utils）
- [x] EntryAbility / EntryBackupAbility

---

## T-20260803-002

- **状态**：`done`
- **目标**：核心页面实现
- **范围**：6个主要页面全部实现

### 检查清单
- [x] Index.ets 首页（输入+配置+预览+底部导航）
- [x] DisplayPage.ets 全屏LED显示（8种模式动画）
- [x] TemplatePage.ets 模板选择页
- [x] HistoryPage.ets 历史记录页
- [x] ColorPickerPage.ets 颜色选择页（HSV+RGB）
- [x] CounterPage.ets 计数器页

---

## T-20260803-003

- **状态**：`done`
- **目标**：显示效果组件
- **范围**：独立动画组件

### 检查清单
- [x] ScrollingText.ets
- [x] BlinkingText.ets
- [x] BreathingText.ets
- [x] BarrageText.ets
- [x] NeonText.ets
- [x] BorderEffect.ets

---

## T-20260803-004

- **状态**：`done`
- **目标**：构建验证和设备测试
- **范围**：通过标准检查和实际构建

### 检查清单
- [x] 通过 check-standard.ps1（0 错误，1 个 README.md 缺失警告）
- [x] 通过 build-harmony.ps1 构建（debug HAP）
- [x] 在模拟器安装并启动应用
- [x] 核心功能交互验证（首页、输入预览、模式/预设颜色、全屏静态显示）

### 验证与遗留覆盖

- HAP 已生成：`entry/build/default/outputs/default/entry-default-unsigned.hap`，并成功安装、启动于 DevEco Emulator。
- 构建无错误，但仍有 target SDK 配置与 ArkTS 过时 API/可能抛异常提示；本轮未修改其行为。
- 模板、历史、计数器、HSV/RGB、自适应设备和其余动画模式尚未逐项完成模拟器复测。

---

## T-20260803-005

- **状态**：`done`
- **目标**：按用户提供的三张视觉稿全方位还原 LED 滚动字幕应用 UI
- **范围**：首页、自定义颜色、场景模板、历史记录、计数器、应用图标、公共视觉组件与多设备布局

### 检查清单

- [x] 建立深黑蓝、青色霓虹、点阵纹理的统一视觉系统
- [x] 还原首页预览、输入、模式、配色、滑杆、设置与底部导航
- [x] 还原自定义颜色页 HSV/RGB、最近使用与确认操作
- [x] 还原场景模板双列卡片、分类筛选与模板使用流程
- [x] 还原历史记录预览卡片、删除与清空流程
- [x] 还原计数器点阵面板、重置、加减按钮
- [x] 使用参考图更新应用图标
- [x] 完成静态检查、构建和可用设备验证
- [x] 回填 changes.md、design.md、design-qa.md
## T-20260804-001

- **Status**: `done`
- **Goal**: Connect the existing LED banner project to the Gitee repository and commit the current project state.
- **Scope**: Initialize local Git metadata, preserve the remote master README, add project source and documentation, and exclude generated caches and local IDE state.

### Checklist
- [x] Initialize the local repository and connect the Gitee remote
- [x] Review and stage only source, project configuration, and intentional documentation
- [x] Run the required static check and build
- [x] Commit and push to `origin/master`

---

## T-20260804-002

- **状态**：`done`
- **目标**：在 LED 展示页实现可靠的横屏显示，并将常规页面调整为不侵入系统栏的沉浸式深色布局。
- **范围**：窗口方向与系统栏状态管理、主题色常量、DisplayPage 生命周期、静态回归检查、构建与设备验证。

### 检查清单

- [x] 首页和配置页保留状态栏、导航栏与安全区，系统栏颜色与应用主题一致
- [x] LED 展示页按“横屏显示”配置请求横屏全屏；关闭时保持竖屏全屏
- [x] 从展示页返回后恢复竖屏、系统栏、常亮和亮度状态
- [x] 先完成窗口状态回归测试的红绿验证
- [x] 完成静态检查、构建和可用设备验证
- [x] 回填 design.md、changes.md、design-qa.md 并提交

---

## T-20260805-001

- **状态**：`in_progress`
- **目标**：按照 HarmonyOS SDK 22 单机应用测试提示词完成全项目检查、问题修复和回归验证。
- **范围**：静态扫描、ArkTS 编译、构建、页面与控件闭环、本地持久化、生命周期、异常处理、自动化回归和可用设备验证。

### 检查清单
- [x] 完成项目结构、配置、路由、页面、控件和服务扫描
- [x] 执行静态检查、脚本测试、ArkTS 检查和 Debug 构建
- [x] 定位并记录 P0-P3 问题及待模拟器或真机验证项
- [x] 为确认的问题补充回归测试并完成最小修复
- [ ] 完成修复后的全量回归、构建和可用设备验证（本地回归与构建已完成，设备等待独占时间片）
- [x] 回填 changes.md、design-qa.md、design.md 并完成最终报告

---

## T-20260805-003

- **Status**: `done`
- **Goal**: Align bottom navigation labels with their corresponding icons.
- **Scope**: Center each tab label below its icon and add a regression contract.

### Checklist
- [x] Center all four tab labels below the matching icons
- [x] Add a UI contract assertion that reproduces the current misalignment
- [x] Complete static checks, build, and device regression
- [x] Update changes.md, design.md, and design-qa.md

---

## T-20260805-007

- **Status**: `done`
- **Goal**: Audit and replace the application icon resource for store-readiness.
- **Scope**: Validate manifest references and icon dimensions/content, replace the 64x64 placeholder with the existing 1024x1024 LED icon, and run build/device checks.

### Checklist
- [x] Confirm the application icon is high-resolution and non-placeholder
- [x] Replace the invalid application icon resource
- [x] Add icon asset regression checks
- [x] Complete static checks, build, and device verification
- [x] Update changes.md, design.md, and design-qa.md

---

## T-20260805-006

- **Status**: `done`
- **Goal**: Make the normal UI typography slightly heavier while preserving title and LED display hierarchy.
- **Scope**: Add a shared medium UI weight, apply it to fixed text across normal pages, and verify the resulting layout.

### Checklist
- [x] Add a shared medium UI font weight
- [x] Apply the weight to home, template, history, color, counter, and display overlay text
- [x] Complete static checks, build, and device regression
- [x] Update changes.md, design.md, and design-qa.md

---

## T-20260805-005

- **Status**: `done`
- **Goal**: Increase the readable UI font sizes consistently across the app's normal operation pages.
- **Scope**: Add a shared typography scale, apply it to fixed UI text, preserve user-controlled LED text sizing, and verify layout.

### Checklist
- [x] Add a shared UI font scaling helper
- [x] Apply the helper to home, template, history, color, counter, and display overlay text
- [x] Complete static checks, build, and device regression
- [x] Update changes.md, design.md, and design-qa.md

---

## T-20260805-004

- **Status**: `done`
- **Goal**: Increase vertical spacing between the three controls in the home page's other settings panel.
- **Scope**: Add shared layout constants, increase setting row height and panel vertical padding, and verify the home layout.

### Checklist
- [x] Increase the setting row height and panel top/bottom padding
- [x] Add a UI contract assertion for the expanded vertical rhythm
- [x] Complete static checks, build, and device regression
- [x] Update changes.md, design.md, and design-qa.md

---

## T-20260805-002

- **状态**：`done`
- **目标**：修正常规页面的统一基准线、安全区域颜色、跟随设备旋转的横屏行为，并增加首页模块与选项之间的间距。
- **范围**：`Theme`、`ScreenService`、首页及常规功能页布局、布局回归脚本、设计与 QA 记录。

### 检查清单
- [x] 统一首页、模板、历史、计数器和自定义颜色页的标题栏与内容起始线
- [x] 固定底部导航图标槽位，使图标大于文字并位于文字正上方
- [x] 统一页面背景、底部导航和系统导航安全区域颜色
- [x] 允许普通页面跟随设备传感器旋转，保留展示页按配置锁定方向
- [x] 增加首页各模块、显示模式和颜色方案之间的间距
- [x] 完成静态检查、回归脚本、构建和可用设备验证
- [x] 回填 changes.md、design-qa.md、design.md

---

## T-20260807-001

- **状态**：`done`
- **目标**：修复应用审核指出的颜色对比度、状态栏适配、分层应用图标和滚动边界反馈问题。
- **范围**：共享主题、常规页面滚动容器、系统栏窗口配置、应用/Ability 图标资源、静态回归脚本及设计与 QA 记录。

### 检查清单
- [x] 图标或标题文字对背景对比度大于 3:1，正文文字对背景对比度大于 4.5:1
- [x] 状态栏背景与页面沉浸一体化，并按深色背景使用清晰的浅色系统图标
- [x] 应用图标采用 1024x1024 前景层和背景层，不预裁圆角且主体无额外内间距
- [x] 所有可滚动页面和横向选择器在边界位置提供回弹反馈
- [x] 完成静态检查、构建和可用设备验证
- [x] 回填 changes.md、design.md 和 design-qa.md

### 2026-08-07 验证状态

- 静态检查、独立回归脚本、签名 debug HAP 构建，以及 phone/2in1 安装和正常启动均已完成。
- phone 已执行首页、颜色、模板和历史的边界滑动；命令成功、页面继续响应且未发生崩溃。精确静态合同证明五个容器均使用 Spring + alwaysEnabled；仅瞬态动画录像/连续帧证据为 partial，不阻断验收。
- `DisplayPage` 的横屏全屏和系统栏隐藏已实证；退出阶段共享模拟器被其他应用抢占前台，因此未保留无法独立归因的恢复截图。恢复路径由窗口静态合同覆盖；phone 与 2in1 可用设备验证完成，tablet 无在线目标。

---

## T-20260807-002

- **Status**: `done`
- **Goal**: Fix bottom-to-top vertical text so it enters from below and fully exits above without snapping away at the top edge.
- **Scope**: DisplayPage vertical travel geometry, regression contract, documentation, build, and available-device verification.

### Checklist
- [x] Reproduce the centered-coordinate boundary error with a failing contract
- [x] Use symmetric off-screen travel limits that include screen and text height
- [x] Verify bottom entry, complete top exit, and continuous looping
- [x] Run standard checks, build, and available-device regression
- [x] Update changes.md, design.md, and design-qa.md

---

## T-20260807-003

- **Status**: `done`
- **Goal**: Smooth the vertical banner's repeated entry so text fades in from the off-screen edge instead of appearing abruptly.
- **Scope**: DisplayPage vertical entry opacity, business regression contract, design records, build, and available-device verification.

### Checklist
- [x] Add a failing contract for distance-based vertical entry opacity
- [x] Fade each vertical entry from transparent to opaque over one estimated text height
- [x] Preserve direction, speed, travel distance, orientation selection, and non-vertical modes
- [x] Run standard checks, build, and available-device regression
- [x] Update changes.md, design.md, and design-qa.md

---

## T-20260807-004

- **Status**: `done`
- **Goal**: Resolve the approved release-readiness findings while preserving the existing signing configuration and API 22 compatibility target.
- **Scope**: Native double-tap pause, history usage updates, strict offline backup behavior, layered-icon safe area, store-facing documentation, ArkTS deprecation warnings, regression contracts, builds, and available-device verification.

### Checklist

- [x] Replace timer-based tap counting with native exclusive single/double-tap recognition
- [x] Refresh history usage count and last-used time before opening a saved record
- [x] Disable backup/restore and verify the package remains permission-free and network-free
- [x] Keep all layered-icon foreground pixels inside a deterministic safe inset
- [x] Align SDK, feature, color, border, and LED-style documentation with the implementation
- [x] Add privacy, user-agreement, and AppGallery submission-checklist documents
- [x] Replace deprecated global ArkUI APIs with UIContext-scoped APIs
- [x] Run static checks, debug/release builds, and available-device regression
- [x] Update changes.md, design.md, and design-qa.md

### 2026-08-07 Verification

- Standard check passed with 0 errors and 0 warnings; clean Debug and Release builds completed without ArkTS warnings.
- The signed Release HAP reports compatible/target API 22, zero permissions, backup restore disabled, and layered app/Ability icon references.
- Phone (OpenHarmony 6.0.2.130) and 2in1 (OpenHarmony 6.1.1.125) passed install/start, native double-tap pause/resume, immersive display entry, and exit regression.
- Phone history usage refreshed immediately from 9 to 10 after opening and returning. No tablet target was online, so tablet remains an AppGallery pre-submission acceptance item.

---

## T-20260810-001

- **Status**: `done`
- **Goal**: Resolve the current AppGallery rejection findings with the minimum release-focused change set.
- **Scope**: Set the display name to `LED跑马灯`, unify submitted/installed/recent-task icon resources, correct normal-page status-bar safe-area behavior, raise fixed UI text sizes, enforce fixed-color contrast, and verify the built HAP.

### Checklist

- [x] Set AppScope and EntryAbility display text to `LED跑马灯` without changing bundleName or version metadata
- [x] Keep AppScope and Ability layered icon resources pixel-identical and verify all icon references
- [x] Correct normal-page system-bar and safe-area configuration while preserving DisplayPage fullscreen behavior
- [x] Raise undersized fixed UI text and enforce fixed-color contrast contracts
- [x] Run static checks, build, and attempt available-device installation/start verification
- [x] Update changes.md, design.md, and design-qa.md

### 2026-08-11 Verification

- `scripts/check-standard.ps1`, ArkTS compilation, parse, UI, accessibility, responsive, window, icon, business, release, and AppGallery acceptance contracts passed.
- Baseline debug build HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 2,285,937 bytes, SHA-256 `205EDF11C36D9136550D3C027804193B591C8AA6172763D421C0B023C8828908`. The tracked signing configuration remains empty; release signing must use the approved external process.
- HAP metadata keeps `com.ledscroll.banner`, version `1.0.0` / `1000000`, zero permissions, app `$media:app_icon`, and Ability `$media:layered_image`; both layered descriptors and their four PNG layers are packaged.
- phone `127.0.0.1:5555` installed and started the current Debug HAP successfully. `pages/DisplayPage` covered `[0,0][2856,1320]`; after Back, `pages/Index` restored to `[0,137][1320,2856]` with `#FF030A16` surface. Evidence: `docs/qa/2026-08-11-appgallery-home-5555.*`, `-display-5555.*`, and `-exit-5555.*`. No tablet or 2in1 target was connected.

---

## T-20260811-001

- **Status**: `in_progress`
- **Goal**: Complete the final AppGallery re-review against the reported icon, accessibility, system-bar, typography, and name findings, then prepare the approved signed package for resubmission.
- **Scope**: Official-guidance comparison, phone launcher/recent-task icon evidence, release-package eligibility, and release QA records. No bundle, version, signing configuration, or AGC metadata changes.

### Checklist

- [x] Capture and inspect the installed launcher and recent-task icon on the available phone emulator
- [x] Compare the three Huawei guidance links with the current implementation and acceptance contracts
- [x] Confirm the minimum release-signing requirement before AppGallery submission
- [ ] Update release QA records and resubmit only an approved externally signed Release HAP

### 2026-08-11 Name and submission handoff

- The approved installed and store-facing name is `光迹字幕`. AppScope, EntryAbility, launcher, and the Index title must stay aligned; use the same name in AppGallery Connect.
- The AppScope and EntryAbility icon descriptors use pixel-identical foreground and background PNG layers. Launcher evidence is retained; an attributable recent-task screenshot could not be captured from the shared emulator, so the identity claim is grounded in packaged resource references and matching layer hashes.
- Huawei guidance comparison is complete: fixed body text meets the 12fp project acceptance floor (above the phone/tablet 8fp minimum and 2in1 10fp minimum), fixed body-text contrast is at least 4.5:1, title/icon contrast is at least 3:1, ordinary pages preserve system-bar safe areas with matching `PAGE_BG`, and `DisplayPage` alone is fullscreen.
- Submission remains pending: this workspace deliberately produces an unsigned Debug HAP. An approved externally signed Release HAP and user confirmation at submission time are required before upload.

---

## T-20260811-002

- **Status**: `done`
- **Goal**: Audit every finding in `C:\Users\27363\Desktop\鸿蒙问题排查表.md` against the current LED banner application and fix every applicable issue that still exists.
- **Scope**: Bottom navigation/safe areas, light and dark contrast, functional integrity, app identity, status bar, typography, responsive layout, regression contracts, documentation, build, and available-device verification. Findings for unrelated reminder, calendar, focus, clock, billing, statistics, settings, or white-noise features are applicability-audited but do not expand this app's product scope.

### Checklist

- [x] Record an applicability and current-status verdict for all 11 findings
- [x] Reproduce each applicable remaining defect with a failing regression contract
- [x] Implement minimal root-cause fixes without changing bundle, version, signing, or AGC metadata
- [x] Run standard checks, build, and available-device regression
- [x] Update changes.md, design.md, and design-qa.md with evidence and limitations

### 2026-08-11 Verification

- The complete 11-item matrix is `docs/qa/2026-08-11-troubleshooting-table-audit.md`; unrelated reminder, calendar, billing, focus, clock, and white-noise examples are explicitly out of product scope.
- RED/GREEN contracts reproduced and fixed the two remaining applicable gaps: ordinary-page bottom clearance increased from 24vp to 28vp, and the home switches now use explicit theme-independent selected/off/thumb colors.
- `check-standard.ps1` passed with 0 errors and 0 warnings; parse, UI, business, ArkTS compilation, and `build-harmony.ps1` all exited 0.
- Final unsigned Debug HAP: 2,286,536 bytes, SHA-256 `2054CB280DD5D18971316FD23385D9177B662F3CF4707D3BA2C016C34C2EDA01`. Bundle, version, signing, permissions, and AGC metadata were not changed.
- phone install/start, 28vp ordinary-page clearance, visible switch-off state, and fullscreen DisplayPage passed. Exit-restoration capture was partial because another app took over the shared emulator; no tablet/2in1 target was online.

---

## T-20260811-003

- **Status**: `done`
- **Goal**: Ensure the ordinary-page bottom system gesture area uses the same dark background as the LED banner app instead of the default white system surface.
- **Scope**: Window/system-bar lifecycle and regression verification only. Do not change bundle name, version, signing, permissions, or unrelated page styling.

### Checklist

- [x] Reproduce the white bottom safe-area surface and lock the load-order regression
- [x] Reapply the themed system-bar properties after ordinary page content loads
- [x] Run standard checks, build, and available-device screenshot verification
- [x] Update changes.md, design.md, and design-qa.md with evidence

### 2026-08-11 Verification

- Baseline phone screenshot reproduced the white gesture safe area; the RED contract failed until `EntryAbility` reapplied `ScreenService.applyAppChrome()` after `loadContent` completed.
- `ScreenService.applyAppChrome()` now sets the window background to `AppTheme.PAGE_BG`, and the post-load retry makes the system gesture surface match the app background in the available phone runtime.
- `scripts/check-standard.ps1`, `scripts/test-window-layout.ps1`, ArkTS compilation, and `scripts/build-harmony.ps1` passed. Final unsigned Debug HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 2,287,954 bytes, SHA-256 `410BB8C989132DC42F517619B4B9C8BFF2ECBBA21B943D16F023EA6D073238F3`.
- Evidence: `docs/qa/2026-08-11-safe-area-color-5555.png` and `.json`. No tablet or 2in1 target was connected.

---

## T-20260811-004

- **Status**: `done`
- **Goal**: Re-audit the previous troubleshooting findings, with emphasis on AppGallery name/icon consistency, recent-task identity, contrast, status-bar overlap, and minimum font size.
- **Scope**: AppScope/Ability metadata, packaged icon resources, visible UI contracts, available-device evidence, and related documentation. Do not change bundleName, versionCode, signing, or AGC metadata identifiers.

### Checklist

- [x] Re-check all prior findings and collect fresh source/package/device evidence
- [x] Verify installed launcher and recent-task name/icon identity against the submitted package
- [x] Reproduce and fix any remaining contrast, status-bar, or minimum-font-size findings
- [x] Run full checks/build/device verification and update audit records

### 2026-08-11 Verification

- Fresh phone evidence confirms launcher and recent-task identity: `docs/qa/2026-08-11-icon-name-launcher-final-5555.jpeg`, `docs/qa/2026-08-11-icon-name-recents-final-5555.jpeg`, and `docs/qa/2026-08-11-icon-name-recents-final-5555.json` show the same `光迹字幕` label and LED icon after installing the final HAP. `bm dump` confirms app `$media:app_icon`, Ability `$media:layered_image`, bundle `com.ledscroll.banner`, version `1.0.0` / `1000000`; metadata snapshot is `docs/qa/2026-08-11-icon-name-bm-5555.txt`.
- `module_desc` is now `光迹字幕主模块`; the AppGallery acceptance contract locks the package description together with `app_name`, Ability labels/descriptions, and the Index title.
- The remaining audit Text was `LedPanel`'s decorative dot matrix and the matching counter-page dot matrix. They used 8fp or `#0089D2` at 0.48 opacity; they now use `LED_MATRIX_DOT_FONT_SIZE = 10`, `LED_MATRIX_DOT_COLOR = #8793A8`, and `LED_MATRIX_DOT_OPACITY = 0.85`. Fresh app evidence `docs/qa/2026-08-11-accessibility-final-home-5555.jpeg/json` shows the home dot grid remains visible while fixed-color/alpha contracts pass.
- `check-standard.ps1`, parse, UI, business, accessibility, AppGallery, ArkTS compilation, and `build-harmony.ps1` all pass. Final unsigned Debug HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 2,288,292 bytes, SHA-256 `B126C29FCA829C49E056E3E18FAAE8BF4CAED7B2E9E0EEAB475C0CE33D045F40`.
- Ordinary phone page remains non-fullscreen with root `[0,137][1320,2856]` and title y=290; status-bar overlap is not reproduced. No tablet/2in1 target was online, and AppGallery Connect/software-qualification name/icon plus Release signing remain external submission handoffs.

---

## T-20260811-005

- **Status**: `done`
- **Goal**: Re-check current `led-banner` against the Huawei release-review guidance and the supplied troubleshooting table, and classify any remaining release blockers without changing product code.
- **Scope**: Current source contracts, final HAP metadata, release documents, available-device evidence, and AppGallery Connect handoff requirements. No bundleName, versionCode, signing configuration, or source behavior changes.

### Checklist

- [x] Re-run the supplied 11-item self-test matrix against the current project
- [x] Re-run repository acceptance, accessibility, release, parse/UI/business, and ArkTS checks
- [x] Compare current release package and evidence with official AppGallery submission requirements
- [x] Record blockers, non-blockers, device-coverage limits, and external submission actions

### 2026-08-11 Verification

- The supplied 11-item matrix was re-run against `led-banner`: all applicable code findings are fixed or not applicable; unrelated reminder/calendar/focus/clock/white-noise findings do not belong to this product. Full matrix: `docs/qa/2026-08-11-troubleshooting-table-audit.md`.
- `scripts/check-standard.ps1` passed with 0 errors and 0 warnings. `test-parse.ps1`, `test-ui-contract.ps1`, `test-business-contract.ps1`, `test-accessibility-contract.ps1`, `test-appgallery-acceptance.ps1`, `test-icon-assets.ps1`, `test-release-contract.ps1`, `test-arkts-compile.ps1`, and `scripts/build-harmony.ps1` all passed; build output is `BUILD SUCCESSFUL`.
- Final phone HAP evidence remains `entry/build/default/outputs/default/entry-default-unsigned.hap` (2,288,292 bytes, SHA-256 `B126C29FCA829C49E056E3E18FAAE8BF4CAED7B2E9E0EEAB475C0CE33D045F40`). Launcher and recent-task captures show the same `光迹字幕` label and LED icon.
- Release readiness is not yet complete: this workspace intentionally has no signing configuration, so the artifact is an unsigned Debug HAP; no tablet/2in1 target was online for this audit; AGC store metadata, public privacy-policy URL, qualification/copyright materials, and final store screenshots remain external submission handoffs.

---

## T-20260812-001

- **Status**: `done`
- **Goal**: Prevent every LED display path from rendering low-contrast text and make in-app click results independent of local Preferences flush latency.
- **Scope**: Shared contrast normalization, display/history/template/color/counter click paths, storage batching, regression contracts, required design/QA records, standard check, build, and available-device verification. No bundle, version, signing, permission, or AGC metadata changes.

### Checklist

- [x] Add a shared 4.5:1 LED text contrast guard for previews and full-screen display
- [x] Route visible display actions before background persistence and batch the saved display record into one flush
- [x] Make non-destructive local updates render immediately while retaining serialized background persistence
- [x] Add RED/GREEN source and color-math regression coverage
- [x] Complete source contracts, ArkTS build, and phone verification; repository AppGallery check remains blocked by pre-existing tracked signing material
- [x] Update design.md, changes.md, and design-qa.md

---

## T-20260812-002

- **Status**: `done`
- **Goal**: Learn Huawei's official HarmonyOS UX, performance, AppGallery FAQ, and application-review guidance and package the reusable guidance as a globally discoverable Codex skill.
- **Scope**: Official Huawei documentation research, global skill files, skill validation, and project workflow records only. No application source, resources, signing, bundle, or version changes.

### Checklist

- [x] Read all supplied Huawei sources and preserve source authority, update dates, and provenance
- [x] Create a concise global skill with progressive-disclosure UX, performance/FAQ, and AppGallery review references
- [x] Validate the skill structure, metadata, trigger wording, exact thresholds, and representative usage
- [x] Install the skill in the current Codex user-level global discovery directory
- [x] Record completion and verification evidence in tasks.md, changes.md, design.md, and design-qa.md

### 2026-08-12 Verification

- Installed `harmonyos-app-quality` under `C:\Users\27363\.agents\skills\`, the user-level global skill directory documented by OpenAI for Codex. The skill contains `SKILL.md`, `agents/openai.yaml`, and three progressive-disclosure references.
- The references preserve 39 unique Huawei general UX requirement IDs; add current official performance thresholds and two AppGallery official-account FAQ workflows; and route the 13 chapters of the official application review guide without copying secrets or private submission data.
- `quick_validate.py` reports `Skill is valid`; the five installed files are SHA-256 identical to the forward-tested build copy. Baseline/forward tests confirmed the skill distinguishes 48vp recommended from 40vp mandatory touch targets, uses click response `<=100ms` and app click completion `<=900ms`, and detects the review guide's saturated handheld-banner category risk.
- `scripts/build-harmony.ps1` completed with `BUILD SUCCESSFUL` and produced `entry-default-signed.hap` (2,336,836 bytes). `scripts/check-standard.ps1` passed accessibility, display-safety, responsive, window, icon, and release contracts but remains failed because the pre-existing modified `build-profile.json5` contains tracked signing configuration/material; it was not read, copied, or changed by this task.
- No usable `hdc` executable was found in the current environment, so no fresh device installation or runtime verification was possible. This task changes no application UI or runtime behavior.

---

## T-20260812-003

- **Status**: `in_progress`
- **Goal**: Read the complete private AppGallery rejection report, summarize and map every finding, then apply one approved remediation set and rename the global skill display name to `鸿蒙自检`.
- **Scope**: Read-only AGC audit-report inspection; repository evidence mapping; approved application fixes; global skill rename to internal id `harmonyos-self-check`; required project records and verification. Do not change bundleName, versionCode, signing configuration, app ID, or AGC metadata unless explicitly approved.

### Checklist

- [x] Extract every rejection item, screenshot, reviewer recommendation, version, timestamp, device, and linked requirement from all report sections
- [x] Deduplicate the findings and map each one to repository evidence, likely root cause, fix scope, and external dependencies
- [x] Present the complete issue summary and unified remediation design for approval before editing application source
- [x] Rename and validate the global skill as `鸿蒙自检` with internal id `harmonyos-self-check`
- [x] Implement the approved fixes with focused regression coverage
- [x] Run static checks and build, then verify the available phone target; tablet/2in1 remain offline and `unverified`
- [x] Update changes.md, design.md, and design-qa.md with final evidence and unresolved external handoffs

### 2026-08-12 Verification / Handoff

- Local remediation is complete: package identity is `光迹字幕`; resource/Index/privacy-policy/user-agreement contracts pass; the History header builds the 48x48 `清空` Text only when records exist and uses a non-clickable 48x48 `Blank` in the empty state without opacity; the separate AppGallery store artifact is generated from the same AppScope layers.
- Focused remediation, icon, accessibility, and display-safety contracts pass. ArkTS compilation and `scripts/build-harmony.ps1` pass. Latest artifact: `entry/build/default/outputs/default/entry-default-signed.hap`, 2,335,890 bytes, SHA-256 `95CE055466E51113110B5B9E2FA218DABD42C756C1A75F109A782BA1265150AE`, built `2026-08-12 23:44:29 +08:00`.
- `scripts/check-standard.ps1` exits 1 only on three pre-existing AppGallery acceptance findings for tracked signing configuration/material in `build-profile.json5`. That file was not read or changed; this result is not a full-green or release-readiness claim.
- The current HAP was installed and started on phone emulator OpenHarmony `6.0.2.130` at `1320x2856`. Empty History evidence `docs/qa/2026-08-12-appgallery-remediation-current-history-5555.jpeg` / `.json` confirms no `清空` Text and a trailing `Blank` with bounds `[1096,255][1264,423]`, `clickable=false`, and opacity `1.0`. Populated evidence `...-history-populated-5555.*` confirms a visible, fully opaque, clickable `清空` with the same 168x168 px (48x48 vp) bounds; `...-clear-dialog-5555.*` confirms the `确认清空` dialog and cancel path. The shared emulator took foreground during the final destructive confirmation attempt, so completed deletion is not claimed. Tablet and 2in1 remain `unverified`.
- `docs/release/appgallery-icon.png` is 265,721 bytes, 1024x1024, fully opaque (`Transparent=0`, `NonOpaque=0`, four corners alpha 255, sampled color count 939), and SHA-256 `D35D3F2B48ADC98FABFB0D63B195F9321878D80B5A0A76F62B64D5B3367BA82D`; two generations produced the same hash. This passes the local artifact check only; AGC upload/preview is `unverified`.
- Status remains `in_progress`: AGC name/icon/description/privacy/qualification edits, package upload, and resubmission were not performed and require action-time confirmation. AppAnalyzer T1/T2 measurement for the official `<=900ms` threshold was unavailable, so the reported 3117ms finding remains `unverified` rather than inferred from source or build success.

---

## T-20260812-004

- **Status**: `done`
- **Goal**: Incrementally extend the global `鸿蒙自检` skill with the unique Huawei guidance supplied by the user while omitting content already covered by the skill.
- **Scope**: Deduplicate and repair supplied Huawei URLs, compare live official content with the installed skill, add only missing UX/release-check capabilities, validate representative behavior, and update project workflow records. No application source, resources, signing, bundle, version, application ID, or AGC metadata changes.

### Checklist

- [x] Normalize, deduplicate, and classify the supplied Huawei URLs, including malformed and unavailable entries
- [x] Approve the incremental skill design and exact new audit surfaces
- [x] Update the installed `harmonyos-self-check` skill without duplicating existing rules
- [x] Validate skill structure, source provenance, deduplication, and representative audit behavior
- [x] Run required project checks and build, then update changes.md, design.md, and design-qa.md

### 2026-08-12 Increment Verification

- Normalized the supplied repeated and malformed input into the live layout, contrast, dark-mode, bottom-navigation, status-bar, classification, qualification, and application-review sources. `50104-0` returned 404; topic `0203198799217774051` exposed no verifiable article content and contributed no rule.
- Added only `references/release-preflight-cases.md` plus routing/metadata changes. Existing contrast thresholds, UX requirements 2.1.2.1/2.1.4.1/2.2.1/2.2.5/2.2.6, and the 13-chapter review routing remain authoritative and were not duplicated.
- The old installed skill failed the new contract with 10 expected missing-capability assertions. The validated work copy and installed skill both pass 50 assertions and `quick_validate.py`; the three changed files are SHA-256 identical between copies, and the three existing references remain hash-identical.
- Three representative evaluations pass: a 28vp constant cannot prove bottom-navigation compliance without actual insets/runtime states; classification and qualifications are selected from observable product behavior without copying the full catalog; dark-mode/status-bar source configuration remains `unverified` without switched runtime evidence.
- `scripts/build-harmony.ps1` completed with `BUILD SUCCESSFUL`; `entry-default-signed.hap` is 2,336,836 bytes with SHA-256 `82990C4C42D807CBF06DBFBB3A12A6FB75A948710971C19E1A363485B0321583`.
- `scripts/check-standard.ps1` ran and remains failed on pre-existing application-remediation state: nine AppGallery rejection-remediation assertions for the history clear action, approved name, store-icon generator, and submission checklist, plus three tracked-signing assertions. This skill task did not modify those application/signing files. Accessibility, display-safety, responsive, window, icon, and release contracts passed.

---

## T-20260813-001

- **Status**: `done`
- **Goal**: Rebuild the current FlipClock, WaterReminder, and led-banner sources, reinstall every latest HAP on the available phone target, and re-audit launcher/start-window icons against Huawei requirements.
- **Scope**: led-banner icon/config/package/runtime evidence and required project records. Preserve bundleName, versionCode, signing configuration, app ID, permissions, and unrelated working-tree changes.

### Checklist

- [x] Record current icon/config/resource baselines and pixel metrics
- [x] Rebuild the latest led-banner HAP from the current working tree
- [x] Reinstall and cold-start the latest HAP on `127.0.0.1:5555`
- [x] Capture package/runtime icon evidence and rerun icon/build checks
- [x] Update changes.md and design-qa.md with exact results and remaining device/AGC gaps

### 2026-08-13 Verification

- Replaced the 1024x1024 startup bitmap with a dedicated 144x144 complete icon derived from the existing layered icon. The 144x144 size is the current DevEco Stage-template/project baseline, not an official UX 2.1.4.3.1 startup-icon mandate.
- `scripts/test-icon-assets.ps1` passed. The launcher background remains 1024x1024 and fully opaque; the installed package reports `iconPath=$media:layered_image` for EntryAbility and `startWindowIcon=$media:startIcon`.
- `scripts/build-harmony.ps1 -BuildMode debug` completed with `BUILD SUCCESSFUL`. The current signed HAP is 751,392 bytes with SHA-256 `903453DE741501D463185278FC06FF39D6169649A5C87EF282C40C1D4B749CFF`.
- The HAP reinstalled successfully on phone target `127.0.0.1:5555` (1320x2856). Three cold-start runs plus 20/50/100 ms device-side captures show the complete LED icon during the system launch transition; the launcher shows the layered icon without white corners, holes, or visible blur.
- The full `scripts/check-standard.ps1` is not green: its responsive/window groups still assert the old fixed system-padding expression on five pages, and its AppGallery group rejects the existing tracked signing configuration/material. These pre-existing, non-icon findings were not changed or hidden by this task.
- Tablet and 2in1 runtime rendering, AppGallery Connect upload/preview, and production signing remain `unverified`; the installed debug-provisioned HAP is not claimed as the final store package.
