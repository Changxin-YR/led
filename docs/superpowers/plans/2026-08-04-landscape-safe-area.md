# LED 展示横屏与安全区实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让常规页面保持系统安全区和深黑蓝系统栏，并使 LED 展示页按配置可靠进入横屏全屏、退出后恢复窗口状态。

**Architecture:** `ScreenService` 统一管理三种窗口状态：常规应用框架、展示进入和展示退出。`EntryAbility` 在窗口创建时应用常规框架；`DisplayPage` 只切换展示状态并在方向改变后重新读取显示尺寸；计数器页不再自行进入全屏。

**Tech Stack:** ArkTS、ArkUI `window` / `display` API、PowerShell 静态回归脚本、Hvigor debug HAP 构建。

---

### Task 1: 建立窗口状态回归检查

**Files:**

- Create: `scripts/test-window-layout.ps1`
- Modify: `scripts/check-standard.ps1`

- [ ] **Step 1: 写入失败的窗口状态合同测试**

```powershell
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]

function Assert-FileContains {
  param([string]$RelativePath, [string[]]$Patterns)
  $path = Join-Path $projectRoot $RelativePath
  $content = Get-Content -Encoding UTF8 -Raw -LiteralPath $path
  foreach ($pattern in $Patterns) {
    if ($content -notmatch [regex]::Escape($pattern)) {
      $failures.Add("$RelativePath is missing window contract: $pattern")
    }
  }
}

function Assert-FileNotContains {
  param([string]$RelativePath, [string[]]$Patterns)
  $content = Get-Content -Encoding UTF8 -Raw -LiteralPath (Join-Path $projectRoot $RelativePath)
  foreach ($pattern in $Patterns) {
    if ($content -match [regex]::Escape($pattern)) {
      $failures.Add("$RelativePath must not contain window contract: $pattern")
    }
  }
}

Assert-FileContains 'entry/src/main/ets/common/Theme.ets' @('SYSTEM_STATUS_BAR', 'SYSTEM_NAVIGATION_BAR')
Assert-FileContains 'entry/src/main/ets/services/ScreenService.ets' @('applyAppChrome', 'enterDisplayMode', 'exitDisplayMode', 'setWindowSystemBarProperties')
Assert-FileContains 'entry/src/main/ets/entryability/EntryAbility.ets' @('getMainWindow()', 'applyAppChrome()')
Assert-FileContains 'entry/src/main/ets/pages/DisplayPage.ets' @('enterDisplayMode(this.config?.isLandscape === true)', 'exitDisplayMode()', 'updateDisplaySize()')
Assert-FileNotContains 'entry/src/main/ets/pages/CounterPage.ets' @('ScreenService', 'enterFullScreen', 'setKeepScreenOn')

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "Window layout contract failed with $($failures.Count) issue(s)."
}
Write-Host 'Window layout contract passed.' -ForegroundColor Green
```

- [ ] **Step 2: 运行测试，确认它因为窗口能力尚未实现而失败**

Run: `& .\scripts\test-window-layout.ps1`

Expected: FAIL，包含 `ScreenService.ets is missing window contract: applyAppChrome`。

- [ ] **Step 3: 将该回归脚本加入标准检查**

在 `scripts/check-standard.ps1` 的现有文档和配置检查之后调用：

```powershell
& (Join-Path $PSScriptRoot 'test-window-layout.ps1')
```

使 `check-standard.ps1` 在窗口状态合同缺失时返回非零。

### Task 2: 集中实现窗口与系统栏状态

**Files:**

- Modify: `entry/src/main/ets/common/Theme.ets`
- Modify: `entry/src/main/ets/services/ScreenService.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`

- [ ] **Step 1: 在主题中声明系统栏颜色**

在 `AppTheme` 中新增：

```ts
static readonly SYSTEM_STATUS_BAR: string = '#030A16'
static readonly SYSTEM_NAVIGATION_BAR: string = '#01050D'
```

- [ ] **Step 2: 将 `ScreenService` 重构为确定的窗口状态转换**

保留 `init(windowInstance)`；使用 `setWindowSystemBarProperties` 为常规页面设置深色背景和浅色图标，并实现以下方法：

```ts
async applyAppChrome(): Promise<void> {
  if (!this.win) return
  await this.win.setWindowLayoutFullScreen(false)
  await this.win.setWindowSystemBarEnable(['status', 'navigation'])
  await this.win.setWindowSystemBarProperties({
    statusBarColor: AppTheme.SYSTEM_STATUS_BAR,
    navigationBarColor: AppTheme.SYSTEM_NAVIGATION_BAR,
    statusBarContentColor: AppTheme.TEXT_PRIMARY,
    navigationBarContentColor: AppTheme.TEXT_PRIMARY,
    isStatusBarLightIcon: true,
    isNavigationBarLightIcon: true
  })
}

async enterDisplayMode(landscape: boolean): Promise<void> {
  if (!this.win) return
  await this.win.setPreferredOrientation(
    landscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT
  )
  await this.win.setWindowLayoutFullScreen(true)
  await this.win.setWindowSystemBarEnable([])
  await this.win.setWindowKeepScreenOn(true)
  await this.win.setWindowBrightness(1.0)
}

async exitDisplayMode(): Promise<void> {
  if (!this.win) return
  await this.win.setPreferredOrientation(window.Orientation.PORTRAIT)
  await this.applyAppChrome()
  await this.win.setWindowKeepScreenOn(false)
  await this.win.setWindowBrightness(-1)
}
```

将每个可能抛出异常的窗口操作包裹为单独的 `try/catch`，记录调用名称后继续剩余恢复操作。删除由这三个方法替代的 `enterFullScreen`、`exitFullScreen`、亮度和方向的公开拆分调用，防止页面重新拼接不完整状态。

- [ ] **Step 3: 在 `EntryAbility` 中初始化窗口服务并应用常规页框架**

在 `onWindowStageCreate` 调用 `windowStage.getMainWindow()`。得到窗口后依次调用 `ScreenService.getInstance().init(windowInstance)` 和 `applyAppChrome()`，并保留 `loadContent('pages/Index', ...)` 的现有错误处理。

- [ ] **Step 4: 运行合同测试，确认页面连接项仍然失败**

Run: `& .\scripts\test-window-layout.ps1`

Expected: FAIL，只剩 `DisplayPage.ets` 和 `CounterPage.ets` 的合同项。

### Task 3: 连接 LED 展示与普通页面生命周期

**Files:**

- Modify: `entry/src/main/ets/pages/DisplayPage.ets`
- Modify: `entry/src/main/ets/pages/CounterPage.ets`

- [ ] **Step 1: 让展示页只调用展示状态转换**

在 `DisplayPage.initScreen()` 中，在取得窗口并初始化服务后替换四个分散调用：

```ts
await this.screenService.enterDisplayMode(this.config?.isLandscape === true)
this.updateDisplaySize()
```

新增以下尺寸方法，并在窗口状态切换完成后调用它，再开始动画：

```ts
private updateDisplaySize(): void {
  const displayInfo = display.getDefaultDisplaySync()
  this.screenWidth = px2vp(displayInfo.width)
  this.screenHeight = px2vp(displayInfo.height)
}
```

在 `cleanup()` 中以单次调用替换系统栏、常亮、亮度和方向的分散恢复：

```ts
await this.screenService.exitDisplayMode()
```

- [ ] **Step 2: 让计数器页使用常规页面窗口状态**

从 `CounterPage.ets` 删除 `window` 与 `ScreenService` 导入、`screenService` 字段、`aboutToAppear()`、`initScreen()` 和 `aboutToDisappear()`。保留计数器界面、返回按钮和数据状态不变。

- [ ] **Step 3: 运行合同测试，确认它通过**

Run: `& .\scripts\test-window-layout.ps1`

Expected: `Window layout contract passed.`

- [ ] **Step 4: 提交实现**

```powershell
git add scripts/test-window-layout.ps1 scripts/check-standard.ps1 entry/src/main/ets/common/Theme.ets entry/src/main/ets/services/ScreenService.ets entry/src/main/ets/entryability/EntryAbility.ets entry/src/main/ets/pages/DisplayPage.ets entry/src/main/ets/pages/CounterPage.ets
git commit -m "feat: add landscape display and safe app chrome"
```

### Task 4: 回归验证、设备验证与记录

**Files:**

- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`
- Modify: `tasks.md`

- [ ] **Step 1: 运行所有静态与构建验证**

```powershell
& .\scripts\test-window-layout.ps1
& .\scripts\check-standard.ps1
& .\scripts\build-harmony.ps1
```

Expected: 三个命令退出码均为 0，且 debug HAP 位于 `entry/build/default/outputs/default/entry-default-unsigned.hap`。

- [ ] **Step 2: 在可用设备或模拟器验证两个展示方向与系统栏恢复**

验证序列：启动首页并确认深色状态栏/导航栏和安全区；打开“横屏显示”后进入 LED 页并确认横屏全屏；返回首页确认竖屏和系统栏恢复；关闭开关后重复并确认 LED 页为竖屏全屏。

- [ ] **Step 3: 更新设计和 QA 记录**

在 `design.md` 说明常规页系统栏配色与展示页全屏边界；在 `changes.md` 记录窗口状态调整；在 `design-qa.md` 写入实际设备/模拟器、两个方向和返回恢复的结果。将 `T-20260804-002` 的检查清单全部标为 `done`。

- [ ] **Step 4: 运行最终检查并提交文档**

```powershell
& .\scripts\check-standard.ps1
& .\scripts\build-harmony.ps1
git add design.md changes.md design-qa.md tasks.md
git commit -m "docs: record landscape safe-area verification"
```
