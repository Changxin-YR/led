# 页面基准线、安全区域与旋转适配设计

## 背景

当前首页的标题栏高度为 52vp，模板、历史、计数器和自定义颜色页的标题栏高度为 62vp，导致不同页面的正文起始线不一致。首页底部导航的图标尺寸和文字尺寸没有固定槽位，选中项与未选中项的字形差异会造成视觉基准线漂移。常规页面的底部导航、系统导航安全区和页面背景也使用了不同的深色值，设备上会出现明显的色带。

展示页退出时将窗口方向强制设置为竖屏，因此用户旋转手机后回到常规页面时，页面无法继续由系统传感器决定方向。

## 目标

1. 首页、模板、历史、计数器和自定义颜色页共用同一套标题栏高度、左右内边距和正文起始节奏。
2. 底部导航的四个入口使用固定高度的图标槽位，图标明显大于文字并位于文字正上方；选中状态不改变布局尺寸。
3. 页面背景、首页底部导航和系统导航安全区使用同一主题色，消除应用内容与系统安全区之间的色差。
4. 常规页面允许系统根据设备传感器自动决定竖屏或横屏；展示页仍按 `BannerConfig.isLandscape` 显式进入横屏或竖屏全屏显示。
5. 增加首页预览、输入、模式、颜色、滑杆和其他设置之间的垂直间距，并增加模式按钮和颜色方案之间的网格间距；模板卡片和历史列表同步使用更宽松的间距。

## 非目标

- 不修改 bundleName、versionCode、签名配置、AGC 元数据或权限。
- 不改变底部导航入口、路由、持久化数据结构、展示动画和业务操作逻辑。
- 不把展示页改为普通安全区页面；展示页继续使用独占全屏。

## 设计

### 1. 统一主题尺寸与颜色

在 `entry/src/main/ets/common/Theme.ets` 增加页面骨架常量：统一标题栏高度、底部导航高度、导航图标槽位高度、页面横向内边距、常规区块间距和卡片间距。保留现有 `PAGE_PADDING` 作为兼容别名，所有本次调整的页面布局改用这些集中常量。

将 `SYSTEM_NAVIGATION_BAR` 与 `PAGE_BG` 设为同一颜色，并让首页底部导航使用同一主题常量。状态栏继续使用 `PAGE_BG`，系统栏图标继续使用浅色，确保内容区、底部导航和系统安全区连续。

### 2. 统一页面骨架

不引入额外路由或页面容器，沿用各页面现有 `buildHeader`，但让 `Index`、`TemplatePage`、`HistoryPage`、`CounterPage` 和 `ColorPickerPage` 使用同一标题栏高度、左右内边距、返回按钮尺寸和标题间距。这样普通页面都从相同的安全区下边界开始绘制正文。

首页保留“滚动内容 + 固定开始按钮 + 固定底部导航”的结构。底部导航的每个入口保持 25% 宽度，内部使用固定高度的图标槽位和文字槽位：图标约 26vp，文字 11vp，图标在文字上方并且整体垂直居中。选中状态只改变颜色和字重，不改变槽位尺寸。

### 3. 旋转行为

`ScreenService.applyAppChrome()` 和 `ScreenService.exitDisplayMode()` 将窗口首选方向设置为 `window.Orientation.UNSPECIFIED`，把常规页面方向交给系统传感器。`enterDisplayMode(landscape)` 仍使用 `LANDSCAPE` 或 `PORTRAIT`，以保证 LED 展示页严格遵循用户配置。普通页面不新增方向开关，窗口尺寸变化由 ArkUI 重新布局处理。

### 4. 间距调整

首页各一级模块使用统一的区块间距；模式按钮增加列间距和行间距，颜色方案增加行间距，开始按钮与设置区之间保留清晰的操作留白。模板分类条与卡片网格、历史记录列表使用统一的卡片间距。所有内容仍在现有 `Scroll`、`Grid` 和 `List` 中，避免在小屏上产生裁切。

## 文件边界

- 修改 `entry/src/main/ets/common/Theme.ets`：集中声明尺寸和安全区颜色。
- 修改 `entry/src/main/ets/services/ScreenService.ets`：常规页面使用 `UNSPECIFIED` 方向。
- 修改 `entry/src/main/ets/pages/Index.ets`：统一首页标题栏、导航图标槽位和首页区块间距。
- 修改 `entry/src/main/ets/pages/TemplatePage.ets`、`HistoryPage.ets`、`CounterPage.ets`、`ColorPickerPage.ets`：统一标题栏与页面间距。
- 修改 `scripts/test-window-layout.ps1`：验证展示页方向和常规页面自动方向契约。
- 新增 `scripts/test-responsive-layout.ps1`：验证主题尺寸、导航槽位、颜色复用和首页间距契约。
- 修改 `scripts/check-standard.ps1`：纳入新的响应式布局回归脚本。
- 回填 `design.md`、`changes.md`、`design-qa.md` 和 `tasks.md`。

## 验证

实现前先运行新增的响应式布局脚本，确认它因缺少新契约而失败；实现后运行该脚本确认通过。随后运行 `scripts/test-window-layout.ps1`、`scripts/test-ui-contract.ps1`、`scripts/test-business-contract.ps1`、`scripts/test-arkts-compile.ps1`、`scripts/check-standard.ps1` 和 `scripts/build-harmony.ps1`。

设备验收覆盖：冷启动首页、首页滚动查看间距、四个底部导航入口、模板/历史/计数器/自定义颜色页标题栏对齐、底部导航与系统安全区颜色连续、旋转设备后普通页面跟随方向、展示页按配置进入方向并在退出后恢复自动方向。

## 设计自检

- 所有四项用户反馈都有对应实现边界和验收步骤。
- 方向行为区分了普通页面自动旋转与展示页显式方向，没有改变展示页的全屏产品行为。
- 没有引入新的持久化字段、路由、权限或外部依赖。
