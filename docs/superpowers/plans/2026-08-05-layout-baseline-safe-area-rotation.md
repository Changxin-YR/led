# 页面基准线、安全区域与旋转适配 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 统一常规页面的视觉骨架与安全区域颜色，让底部导航图标和文字稳定对齐，并允许普通页面跟随设备旋转。

**Architecture:** 沿用现有各页面 `buildHeader`，通过 `AppTheme` 集中声明尺寸和颜色契约，避免引入额外路由容器。`ScreenService` 只负责把常规窗口方向恢复为 `UNSPECIFIED`，展示页仍按配置锁定方向；页面内容继续由 ArkUI 的 `Scroll`、`Grid`、`List` 和区域变化自动布局。

**Tech Stack:** ArkTS、ArkUI `window` API、PowerShell 静态契约脚本、Hvigor HarmonyOS HAP 构建。

---

### Task 1: 建立布局回归契约

**Files:**
- Create: `scripts/test-responsive-layout.ps1`
- Modify: `scripts/test-window-layout.ps1`

- [ ] **Step 1: 写入响应式布局失败测试**

创建 PowerShell 脚本，读取 UTF-8 源文件，并断言以下契约：

```powershell
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]

function Assert-FileContains {
  param([string]$RelativePath, [string[]]$Patterns)
  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("Missing file: $RelativePath")
    return
  }
  $content = Get-Content -Encoding UTF8 -Raw -LiteralPath $path
  foreach ($pattern in $Patterns) {
    if ($content -notmatch [regex]::Escape($pattern)) {
      $failures.Add("$RelativePath is missing responsive layout contract: $pattern")
    }
  }
}

Assert-FileContains 'entry/src/main/ets/common/Theme.ets' @(
  'HEADER_HEIGHT: number = 60',
  'BOTTOM_NAV_HEIGHT: number = 72',
  'NAV_ICON_SLOT_HEIGHT: number = 30',
  'PAGE_SECTION_GAP: number = 14',
  "SYSTEM_NAVIGATION_BAR: string = '#030A16'"
)
Assert-FileContains 'entry/src/main/ets/pages/Index.ets' @(
  'AppTheme.HEADER_HEIGHT',
  'AppTheme.NAV_ICON_SLOT_HEIGHT',
  'AppTheme.PAGE_SECTION_GAP',
  'AppTheme.SYSTEM_NAVIGATION_BAR'
)
Assert-FileContains 'entry/src/main/ets/pages/TemplatePage.ets' @('AppTheme.HEADER_HEIGHT')
Assert-FileContains 'entry/src/main/ets/pages/HistoryPage.ets' @('AppTheme.HEADER_HEIGHT')
Assert-FileContains 'entry/src/main/ets/pages/CounterPage.ets' @('AppTheme.HEADER_HEIGHT')
Assert-FileContains 'entry/src/main/ets/pages/ColorPickerPage.ets' @('AppTheme.HEADER_HEIGHT')

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "Responsive layout contract failed with $($failures.Count) issue(s)."
}
Write-Host 'Responsive layout contract passed.' -ForegroundColor Green
```

- [ ] **Step 2: 修改窗口回归测试，使自动方向成为可验证行为**

在 `scripts/test-window-layout.ps1` 的 `ScreenService.ets` 契约中加入 `window.Orientation.UNSPECIFIED`，保留 `LANDSCAPE`、`PORTRAIT` 和 `exitDisplayMode` 的展示页契约。运行：

```powershell
& .\scripts\test-responsive-layout.ps1
& .\scripts\test-window-layout.ps1
```

预期：两个脚本都失败，失败原因是新主题常量、页面引用和 `UNSPECIFIED` 尚未实现，而不是脚本解析错误。

### Task 2: 集中主题尺寸并修复窗口颜色与方向

**Files:**
- Modify: `entry/src/main/ets/common/Theme.ets`
- Modify: `entry/src/main/ets/services/ScreenService.ets`

- [ ] **Step 1: 增加页面骨架常量并统一安全区颜色**

在 `AppTheme` 中加入：

```ts
static readonly HEADER_HEIGHT: number = 60
static readonly BOTTOM_NAV_HEIGHT: number = 72
static readonly NAV_ICON_SLOT_HEIGHT: number = 30
static readonly PAGE_SECTION_GAP: number = 14
static readonly CARD_GAP: number = 14
static readonly SYSTEM_NAVIGATION_BAR: string = '#030A16'
```

保留 `PAGE_PADDING`，让系统导航栏和页面背景使用相同的 `#030A16`。

- [ ] **Step 2: 恢复普通页面的传感器方向**

在 `applyAppChrome()` 开始阶段设置：

```ts
await this.runWindowOperation('restore automatic orientation', () =>
  currentWindow.setPreferredOrientation(window.Orientation.UNSPECIFIED))
```

在 `exitDisplayMode()` 中把 `PORTRAIT` 改为 `UNSPECIFIED`，保留之后的 `applyAppChrome()`、系统栏恢复、常亮关闭和自动亮度恢复。展示页的 `enterDisplayMode()` 不改动显式 `LANDSCAPE` / `PORTRAIT` 选择。

- [ ] **Step 3: 运行窗口测试确认最小实现通过**

运行：

```powershell
& .\scripts\test-window-layout.ps1
```

预期：输出 `Window layout contract passed.`。

### Task 3: 统一五个常规页面标题栏

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/TemplatePage.ets`
- Modify: `entry/src/main/ets/pages/HistoryPage.ets`
- Modify: `entry/src/main/ets/pages/CounterPage.ets`
- Modify: `entry/src/main/ets/pages/ColorPickerPage.ets`

- [ ] **Step 1: 统一标题栏高度与横向边距**

将五个 `buildHeader` 的根 `Row` 统一为：

```ts
.height(AppTheme.HEADER_HEIGHT)
.padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING })
```

返回按钮统一使用 40vp 宽、48vp 高；普通页标题与返回按钮间距统一为 8vp。首页保留现有品牌字样的字号层级，只校准标题栏高度、左右内边距和右侧入口位置；其他页面保留已有右侧操作。

- [ ] **Step 2: 统一正文内容的横向起始线**

将首页、模板、历史、计数器和自定义颜色页的滚动容器或列表左右 padding 改用 `AppTheme.PAGE_PADDING`；保留各自已有最大宽度和页面专属内容。

- [ ] **Step 3: 编译相关 ArkTS 文件**

运行：

```powershell
& .\scripts\test-arkts-compile.ps1
```

预期：编译脚本通过，且没有新增 ArkTS 错误。

### Task 4: 修复底部导航基准线并增加首页间距

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: 固定导航图标和文字槽位**

在 `buildBottomNav()` 中让每个入口保持 25% 宽度、`AppTheme.BOTTOM_NAV_HEIGHT` 高度；图标容器使用 `AppTheme.NAV_ICON_SLOT_HEIGHT`，图标字体约 26vp，文字字体 11vp，图标与文字间距 4vp。选中状态只切换颜色和字重，不再为首页使用不同字号。

- [ ] **Step 2: 让导航底色与系统安全区复用主题颜色**

把底部导航 `.backgroundColor('#020A14')` 改为 `.backgroundColor(AppTheme.SYSTEM_NAVIGATION_BAR)`，并使用 `AppTheme.BOTTOM_NAV_HEIGHT`，使内容区与系统导航区无色带。

- [ ] **Step 3: 增加首页模块与选项间距**

使用 `AppTheme.PAGE_SECTION_GAP` 增大预览、输入、模式、颜色和其他设置的区块 margin；模式 Grid 的行列间距至少为 10vp，颜色 Grid 的行间距至少为 10vp；开始区域顶部和底部留白随页面骨架常量调整。所有内容继续在现有 `Scroll` 中，确保小屏可滚动。

- [ ] **Step 4: 运行响应式布局契约**

运行：

```powershell
& .\scripts\test-responsive-layout.ps1
```

预期：输出 `Responsive layout contract passed.`。

### Task 5: 调整功能页卡片和列表间距

**Files:**
- Modify: `entry/src/main/ets/pages/TemplatePage.ets`
- Modify: `entry/src/main/ets/pages/HistoryPage.ets`
- Modify: `entry/src/main/ets/pages/CounterPage.ets`
- Modify: `entry/src/main/ets/pages/ColorPickerPage.ets`

- [ ] **Step 1: 增大模板页分类和卡片网格间距**

把分类条的左右 padding、Grid 的列间距和行间距改用 `AppTheme.CARD_GAP` 或不小于 14vp 的固定值，保留现有 2/3/4 列断点。

- [ ] **Step 2: 增大历史列表和计数器操作区留白**

把历史列表的 `List({ space: 11 })` 改为 `AppTheme.CARD_GAP`，保持卡片左右安全边距；将计数器面板顶部 margin 从 42vp 调整为 48vp，将底部操作区 padding-bottom 从 44vp 调整为 36vp，保持既有最大尺寸，不改变计数逻辑。

- [ ] **Step 3: 统一自定义颜色页的区块间距**

将颜色预览、HSV/RGB 控件、最近颜色和确认按钮之间的主要 margin 使用 `AppTheme.PAGE_SECTION_GAP`，继续保留滚动容器。

### Task 6: 接入标准检查并回填项目文档

**Files:**
- Modify: `scripts/check-standard.ps1`
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`
- Modify: `tasks.md`

- [ ] **Step 1: 将响应式布局契约纳入标准检查**

在窗口契约检查之后调用：

```powershell
& (Join-Path $PSScriptRoot 'test-responsive-layout.ps1')
```

脚本失败时让标准检查返回非零。

- [ ] **Step 2: 回填设计与变更记录**

在 `design.md` 增加统一页面骨架、导航槽位、安全区颜色和普通页面自动方向；在 `changes.md` 记录实际修改；在 `design-qa.md` 记录静态契约、ArkTS 编译、构建和设备验证结果；将本任务清单更新为实际状态。

### Task 7: 全量验证

**Files:**
- Verify only; no source changes unless a command exposes a concrete regression.

- [ ] **Step 1: 运行全部静态和业务回归**

```powershell
& .\scripts\test-responsive-layout.ps1
& .\scripts\test-window-layout.ps1
& .\scripts\test-ui-contract.ps1
& .\scripts\test-business-contract.ps1
& .\scripts\test-arkts-compile.ps1
& .\scripts\check-standard.ps1
```

Expected: every command exits 0.

- [ ] **Step 2: 构建 debug HAP**

```powershell
& .\scripts\build-harmony.ps1 -BuildMode debug
```

Expected: exit 0 and `entry/build/default/outputs/default/entry-default-unsigned.hap` exists.

- [ ] **Step 3: 记录设备限制**

用可用设备验证常规页面旋转、统一标题栏、底部导航图标槽位和安全区色彩；若设备被其他任务独占，明确记录为 waiting，不把旧截图当作本轮修复后的证据。
