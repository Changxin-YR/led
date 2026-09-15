# 鸿蒙问题排查表逐项审计（2026-08-11）

## 审计范围与判定方法

- 来源：`C:\Users\27363\Desktop\鸿蒙问题排查表.md`，共 11 个编号项。
- 当前产品：纯 HarmonyOS Stage 模型的 `光迹字幕`，页面只有首页、全屏展示、模板、历史、自定义颜色和计数器；没有提醒、代理提醒、账单、统计、设置默认视图、日历节假日、专注、时钟或白噪音功能。
- 判定原则：先判断条目是否适用于本产品，再用源码、静态合同、HAP 构建和可用设备证据核对。其他应用的具体功能缺陷不扩张为本产品的新功能需求。
- 保护边界：未修改 bundleName、versionCode/versionName、签名配置或 AGC 元数据。

## 逐项结论

| 编号 | 排查表问题 | 对本项目的适用性 | 当前结论 | 证据与处理 |
|---|---|---|---|---|
| 1 | 底部导航条未适配，底部控件避让小于 28vp | 适用 | **本轮确认存在并已修复** | `AppTheme.SYSTEM_BOTTOM_PADDING` 原为 24，回归合同提高到 28 后先准确失败；现统一为 28。phone 布局中应用内容列止于 `y=2758`、底部 tab 内容止于 `y=2660`，保留 98px，等于该目标 28vp 的像素结果；系统手势区没有遮挡应用控件。 |
| 2 | 浅色模式下控件文字与背景对比度不足 | 类别适用 | **未复现固定文字问题；开关状态补强后通过** | 应用使用显式固定深色视觉系统，正文/表面和强调按钮不读取系统浅色调色板。新增显式开关关闭轨道与滑块颜色，避免原生默认色随系统主题变化；关闭轨道/面板 5.94:1、滑块/关闭轨道 6.11:1、滑块/选中轨道 12.32:1。`test-accessibility-contract.ps1` 通过。 |
| 3 | 首页提醒显示“已保存”但未开通代理提醒能力 | 不适用 | **不存在该产品能力** | 源码和资源没有“提醒”或“代理提醒”，清单零权限，不声明代理提醒能力。没有伪保存提示需要修复。 |
| 4 | 提交图标、安装后图标、最近任务图标不一致 | 适用 | **安装包侧已解决；商店提交侧需继续保持一致** | AppScope `$media:app_icon` 与 EntryAbility `$media:layered_image` 使用独立描述符，但背景 PNG 两两哈希相同、前景 PNG 两两哈希相同；`test-icon-assets.ps1` 校验 1024x1024、透明度、安全区、引用和像素一致性。AppGallery Connect 上传图标不在仓库内，提交时必须继续使用同一源图。 |
| 5 | 应用名称过于广义且安装包、资质、商店未同步 | 适用 | **安装包侧已解决；资质/商店侧需人工同步** | AppScope、EntryAbility label/description 和首页标题均为可识别名称 `光迹字幕`，验收合同会拒绝不一致。bundle 和版本未改。软件资质名称和 AppGallery Connect 商品名属于外部提交资料，仓库不能代替上架主体修改。 |
| 6 | 状态栏与文本或功能按键遮挡 | 适用 | **当前不存在** | 普通页使用 `setWindowLayoutFullScreen(false)`，状态栏/导航栏启用，普通页不扩展到系统安全区；phone 首页根节点为 `[0,137][1320,2856]`，标题在安全边界下。只有 `DisplayPage` 使用全屏。`test-window-layout.ps1` 与 `test-appgallery-acceptance.ps1` 通过。 |
| 7 | PC/2in1 固定文字小于 10fp | 适用 | **当前不存在** | 普通页面固定 UI 最低基准为 `uiFontSize(12)`；验收合同拒绝 10/11fp 固定 UI。用户可调 LED 内容不是应用 chrome。当前无在线 2in1，结论由源码合同、ArkTS 编译和既有 2in1 历史证据共同支撑。 |
| 8 | 首页/账单/统计/设置左右显示不完全 | 具体示例不适用；响应式类别适用 | **本项目 phone 未复现，静态合同通过；tablet/2in1 本轮未连接** | 本项目没有账单、统计、设置主页面。现有页面使用 100%/相对宽度、共享左右内边距、滚动容器和 620/720vp 最大内容宽度；phone 截图左右无裁切。tablet/2in1 仍是设备覆盖限制，不把 phone 结果外推为完整多设备运行时证据。 |
| 9 | 深色模式下文字与背景最小对比度不足 | 适用 | **当前不存在** | 固定深色调色板由 `test-accessibility-contract.ps1` 实算；正文至少 4.5:1，控件/状态边界至少 3:1。展示页固定覆盖层为 18.94:1；用户自选 LED 前景/背景属于创作内容，不作为固定应用 chrome 强制改色。 |
| 10 | 默认列表/网格不即时刷新；除夕被写成阳历 12 月 31 日 | 不适用 | **不存在这些功能** | 本项目没有设置默认视图、事件、日历或节假日快速添加。源码检索没有相关业务词或模型；不能通过新增无关功能“修复”其他应用的问题。 |
| 11 | 深色模式下专注重置、时钟开关不清晰；白噪音并发/色块刷新异常 | 具体示例不适用；开关可见性类别适用 | **本轮补强本项目开关；其余功能不存在** | 本项目没有专注、时钟或白噪音。首页三个设置开关原先只有硬编码选中色且未显式指定关闭色；本轮改为共享 `ACCENT`、`TOGGLE_OFF_TRACK` 和 `TOGGLE_THUMB`，关闭/开启态均有位置和高对比色双重反馈。phone 关闭态截图可见灰色轨道与深色滑块。 |

## 本轮红绿验证

1. 将响应式合同的底部安全距离从 24 改为 28，执行后以“缺少 `SYSTEM_BOTTOM_PADDING: number = 28`”准确失败。
2. 增加开关颜色和真实 Toggle 修饰链合同，执行后以缺少 `TOGGLE_OFF_TRACK`、`TOGGLE_THUMB`、共享选中色和 `switchStyle` 准确失败。
3. 修改 `Theme.ets` 与 `Index.ets` 后，`test-responsive-layout.ps1`、`test-accessibility-contract.ps1` 和 `test-arkts-compile.ps1` 均通过。

## phone 运行时证据

- 安装/启动：`127.0.0.1:5555` 成功覆盖安装当前 `entry-default-unsigned.hap` 并启动 `com.ledscroll.banner/EntryAbility`。
- 普通首页：`2026-08-11-troubleshooting-home-5555.png/json`。
- 开关关闭态：`2026-08-11-troubleshooting-switch-off-5555.png/json`；第一个 Toggle 为 `checked=false`，边界 `[1097,1673][1244,1764]`，截图中关闭轨道和滑块清晰可辨。
- 展示页：`2026-08-11-troubleshooting-display-5555.png/json`；`pages/DisplayPage` 根节点覆盖 `[0,0][2856,1320]`。
- 退出恢复：本轮尝试退出时共享模拟器被另一款“宠物陪伴”应用抢占前台，无法保留可独立归因的 after-state；因此本轮运行时结论为 **partial**。恢复路径仍由 `test-window-layout.ps1` 精确覆盖，且 `2026-08-11-appgallery-exit-5555.*` 保留了同日较早的可归因 phone 证据。
- 在线设备：本轮只有 phone；没有 tablet 或 2in1 目标。

## 外部上架交接

仓库内代码、资源和 unsigned Debug HAP 不能完成以下外部动作：

- 将 `光迹字幕` 同步到软件资质和 AppGallery Connect 商品名称。
- 将与安装包分层 PNG 同源的图标上传为商店图标。
- 使用批准的外部签名流程生成 Release HAP 并提交。

这些事项继续由 `T-20260811-001` 跟踪，不应通过把签名材料写入仓库来解决。

## 最终验证结果

- `scripts/check-standard.ps1`：exit 0，0 错误、0 警告；可访问性、响应式、窗口、图标、Release 和 AppGallery 合同全部通过。
- `scripts/test-parse.ps1`：exit 0，输出 `ok`。
- `scripts/test-ui-contract.ps1`：exit 0。
- `scripts/test-business-contract.ps1`：exit 0。
- `scripts/test-arkts-compile.ps1`：exit 0，`BUILD SUCCESSFUL`。
- `scripts/build-harmony.ps1`：exit 0，`BUILD SUCCESSFUL`。
- 产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`，2,286,536 bytes，SHA-256 `2054CB280DD5D18971316FD23385D9177B662F3CF4707D3BA2C016C34C2EDA01`。
- 唯一构建提示：没有仓库内签名配置，符合项目安全边界；正式 Release 签名仍走批准的外部流程。

## T-20260811-004 复核补充

本次复核重点覆盖用户重新指出的应用身份、对比度、状态栏和 PC/2in1 字号问题，并重新检查 11 项矩阵：

- **应用身份（问题 2/3）已在安装包和运行时复核通过。** AppScope 的 `app_name`、EntryAbility 的 `label/description`、首页标题均为 `光迹字幕`；AppScope `$media:app_icon` 与 EntryAbility `$media:layered_image` 继续引用两组像素一致的 1024x1024 前景/背景图层。phone `127.0.0.1:5555` 的最终启动器截图 `2026-08-11-icon-name-launcher-final-5555.jpeg` 与最近任务截图 `2026-08-11-icon-name-recents-final-5555.jpeg` 均显示同一名称和 LED 图标，最近任务布局记录见 `2026-08-11-icon-name-recents-final-5555.json`。AppGallery Connect 商品名、软件资质名称及商店上传图标仍需提交人使用同一名称/源图人工同步，仓库无法替代外部资料修改。
- **对比度残留已定位并修复。** 复核发现 `LedPanel` 和 `CounterPage` 的点阵背景也是 `Text` 控件：前者原来使用 0.25 透明度并随用户颜色变化，后者使用 `#0089D2` + 0.48 透明度，正是审核坐标中低对比度 Text 的残留来源。现统一改为 `LED_MATRIX_DOT_COLOR #8793A8` 与 `LED_MATRIX_DOT_OPACITY 0.85`；该颜色对 `PAGE_BG` 为 6.56:1，按 0.85 alpha 与点阵表面合成后仍约 4.86:1。`test-accessibility-contract.ps1` 已加入两个点阵控件的颜色、透明度和同一控件修饰链合同。
- **PC/2in1 8fp 残留已定位并修复。** `LedPanel` 点阵背景原为 `.fontSize(8)`，现改用 `AppTheme.LED_MATRIX_DOT_FONT_SIZE = 10`；`test-appgallery-acceptance.ps1` 会拒绝缺少该共享 token、低于 10fp 或重新出现 8fp 的点阵字号。用户可调 LED 主字幕字号仍保持原有行为。
- **状态栏遮挡本轮未发现新的源码残留。** 普通页面仍由非全屏窗口预留系统栏，所有普通页根节点使用 `SYSTEM_TOP_PADDING`/`SYSTEM_BOTTOM_PADDING`，`DisplayPage` 才进入全屏；phone fresh layout 中首页根节点从 `[0,137]` 开始，标题从 y=290 开始，未与状态栏重叠。tablet/2in1 本轮没有在线目标，不能把 phone 运行时结果外推为多设备实测。
- **其余排查表条目逐项结论不变。** 底部 28vp、开关关闭态、普通页窗口、固定深浅色对比度、响应式宽度和无关功能适用性均由既有矩阵与合同覆盖；提醒、账单、日历、专注、时钟和白噪音等不属于本产品。

本补充对应的 RED/GREEN 记录为：先让 AppGallery 合同拒绝 `LED_MATRIX_DOT_FONT_SIZE` 缺失和 `.fontSize(8)`，再让无障碍合同拒绝缺少点阵颜色/透明度 token；实现后两项合同均通过。后续以本次最终构建和 phone 重新安装截图作为复核依据。

最终复核构建：`entry/build/default/outputs/default/entry-default-unsigned.hap`，2,288,292 bytes，SHA-256 `B126C29FCA829C49E056E3E18FAAE8BF4CAED7B2E9E0EEAB475C0CE33D045F40`；`check-standard.ps1`、ArkTS 编译和 `build-harmony.ps1` 均通过。
