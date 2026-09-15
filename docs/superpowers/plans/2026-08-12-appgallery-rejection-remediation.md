# AppGallery Rejection Remediation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve all six findings in the 2026-08-12 AppGallery rejection report with a focused empty-history fix, a compliant store-icon artifact, identity contracts, a rebuilt package, and runtime performance evidence.

**Architecture:** Keep the installed identity and existing optimistic interaction paths unchanged, because they already use `光迹字幕` and move persistence after visible UI completion. Add one focused AppGallery remediation contract, conditionally build the history clear action, and extend the deterministic layered-icon generator to compose a separate fully opaque store PNG from the same layers. Treat AGC field saves, package upload, and resubmission as a separate confirmation-gated handoff.

**Tech Stack:** ArkTS, ArkUI, PowerShell 7/Windows PowerShell, System.Drawing, Hvigor, HarmonyOS HDC/AppAnalyzer or DevEco Testing.

---

## File Ownership And Safety

- Create `scripts/test-appgallery-remediation-contract.ps1`: focused source/document contract for the six rejection findings.
- Modify `scripts/check-standard.ps1`: register the focused contract.
- Modify `entry/src/main/ets/pages/HistoryPage.ets`: hide the clear control in the empty state while preserving a stable 48vp header slot.
- Modify `scripts/generate-layered-icon.ps1`: compose a store PNG from the existing app background and foreground layers.
- Modify `scripts/test-icon-assets.ps1`: verify store-icon dimensions, complete opacity, corners, visual content, and generator wiring.
- Create `docs/release/appgallery-icon.png`: deterministic 1024x1024 store upload artifact.
- Modify `docs/release/appgallery-submission-checklist.md`: add the rejection-specific AGC handoff and performance retest rows.
- Modify `tasks.md`, `design.md`, `changes.md`, and `design-qa.md`: record actual results only after verification.
- Do not read, edit, stage, or normalize `build-profile.json5`. Do not change `bundleName`, version metadata, signing, app ID, or AGC metadata during local implementation.
- The worktree already contains overlapping uncommitted changes. Before every commit, inspect `git diff --cached --name-only` and `git diff --cached`; do not stage an entire pre-modified file if that would include unrelated hunks.

### Task 1: Add A Focused Failing Remediation Contract

**Files:**
- Create: `scripts/test-appgallery-remediation-contract.ps1`
- Modify: `scripts/check-standard.ps1`
- Test: `scripts/test-appgallery-remediation-contract.ps1`

- [ ] **Step 1: Create the source/document contract**

Create `scripts/test-appgallery-remediation-contract.ps1` with the following content:

```powershell
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]
$expectedName = -join [char[]](20809, 36857, 23383, 24149)

function Read-RequiredFile {
  param([string]$RelativePath)

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    $failures.Add("Missing required remediation file: $RelativePath")
    return ''
  }
  return Get-Content -Raw -Encoding UTF8 -LiteralPath $path
}

$history = Read-RequiredFile 'entry/src/main/ets/pages/HistoryPage.ets'
$conditionalClear = [regex]::Match(
  $history,
  "(?s)if\s*\(\s*this\.records\.length\s*>\s*0\s*\)\s*\{\s*Text\('清空'\).*?\.onClick\(\(\)\s*=>\s*this\.clearAll\(\)\).*?\}"
)
if (-not $conditionalClear.Success) {
  $failures.Add('HistoryPage must build the clear action only when records.length > 0.')
}
if ($history -match "(?s)Text\('清空'\).*?\.opacity\(") {
  $failures.Add('HistoryPage must not represent the empty clear action with reduced opacity.')
}
if ($history -notmatch "Blank\(\)\s*\.width\(48\)\s*\.height\(48\)") {
  $failures.Add('HistoryPage empty header must retain a stable 48vp trailing slot.')
}

$identityFiles = @(
  'AppScope/resources/base/element/string.json',
  'entry/src/main/resources/base/element/string.json',
  'entry/src/main/ets/pages/Index.ets',
  'docs/release/privacy-policy.md',
  'docs/release/user-agreement.md'
)
foreach ($relativePath in $identityFiles) {
  $content = Read-RequiredFile $relativePath
  if (-not $content.Contains($expectedName)) {
    $failures.Add("$relativePath must identify the application as $expectedName.")
  }
}

$generator = Read-RequiredFile 'scripts/generate-layered-icon.ps1'
if (-not $generator.Contains('$storeIconPath') -or
    -not $generator.Contains('New-StoreIcon') -or
    -not $generator.Contains('-BackgroundPath $appBackgroundPath') -or
    -not $generator.Contains('-ForegroundPath $appForegroundPath') -or
    -not $generator.Contains('-OutputPath $storeIconPath')) {
  $failures.Add('The store icon must be composed from the same generated AppScope background and foreground layers.')
}

$submissionChecklist = Read-RequiredFile 'docs/release/appgallery-submission-checklist.md'
foreach ($requiredText in @($expectedName, 'appgallery-icon.png', '900ms', '重新提审前确认')) {
  if (-not $submissionChecklist.Contains($requiredText)) {
    $failures.Add("AppGallery submission checklist is missing rejection handoff text: $requiredText")
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "AppGallery remediation contract failed with $($failures.Count) issue(s)."
}

Write-Host 'AppGallery remediation contract passed.' -ForegroundColor Green
```

- [ ] **Step 2: Run the contract and confirm RED**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-appgallery-remediation-contract.ps1
```

Expected: non-zero exit with failures for conditional history clear, missing store-icon generator wiring, and missing rejection handoff text.

- [ ] **Step 3: Register the contract in the standard check**

Insert this block after the existing display-safety contract in `scripts/check-standard.ps1`:

```powershell
Write-Host "`n[AppGallery rejection remediation contract]" -ForegroundColor White
try {
  & (Join-Path $PSScriptRoot 'test-appgallery-remediation-contract.ps1')
} catch {
  Write-Host "  [FAIL] AppGallery rejection remediation contract failed" -ForegroundColor Red
  $script:ErrorCount++
}
```

- [ ] **Step 4: Review the task-only diff**

Run:

```powershell
git diff -- scripts/test-appgallery-remediation-contract.ps1 scripts/check-standard.ps1
```

Expected: only the new focused contract and one standard-check invocation; no signing or metadata edits.

### Task 2: Hide The Empty-State Clear Action

**Files:**
- Modify: `entry/src/main/ets/pages/HistoryPage.ets:43`
- Test: `scripts/test-appgallery-remediation-contract.ps1`
- Test: `scripts/test-accessibility-contract.ps1`

- [ ] **Step 1: Replace the always-rendered clear text with conditional construction**

Replace the trailing clear action in `buildHeader()` with:

```typescript
      if (this.records.length > 0) {
        Text('清空')
          .fontSize(AppTheme.uiFontSize(15))
          .fontColor(AppTheme.DANGER)
          .fontWeight(AppTheme.UI_FONT_WEIGHT)
          .width(48)
          .height(48)
          .textAlign(TextAlign.Center)
          .onClick(() => this.clearAll())
      } else {
        Blank()
          .width(48)
          .height(48)
      }
```

Delete the old `.padding(...)`, `.opacity(...)`, and guarded click body. This leaves no disabled text in the accessibility tree, gives the enabled command a stable 48vp hit target, and keeps the title-bar geometry stable.

- [ ] **Step 2: Run focused and accessibility contracts**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-appgallery-remediation-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-accessibility-contract.ps1
```

Expected: the remediation contract still fails only for store-icon/checklist work; the accessibility contract prints `Accessibility contract passed.`

- [ ] **Step 3: Review the scoped diff**

Run:

```powershell
git diff -- entry/src/main/ets/pages/HistoryPage.ets
```

Expected: no change to history loading, deletion, confirmation, persistence, route behavior, or error handling.

### Task 3: Generate A Fully Opaque Store Icon From The Runtime Layers

**Files:**
- Modify: `scripts/generate-layered-icon.ps1`
- Modify: `scripts/test-icon-assets.ps1`
- Create: `docs/release/appgallery-icon.png`
- Test: `scripts/test-icon-assets.ps1`

- [ ] **Step 1: Extend the icon contract before generating the file**

After the `$layerAssets` loop in `scripts/test-icon-assets.ps1`, add:

```powershell
$storeIconPath = 'docs/release/appgallery-icon.png'
$storeMetrics = Get-IconMetrics $storeIconPath
Test-ExactDimensions $storeIconPath $storeMetrics
Test-BackgroundLayer $storeIconPath $storeMetrics
```

The existing `Test-BackgroundLayer` requires zero non-opaque pixels, all four corners opaque, and a non-placeholder textured image.

- [ ] **Step 2: Run the icon contract and confirm RED**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-icon-assets.ps1
```

Expected: non-zero exit with `Missing layered icon asset: docs/release/appgallery-icon.png`.

- [ ] **Step 3: Add the store icon path and composition function**

Near the existing path declarations in `scripts/generate-layered-icon.ps1`, add:

```powershell
$releaseDirectory = Join-Path $projectRoot 'docs/release'
$storeIconPath = Join-Path $releaseDirectory 'appgallery-icon.png'
```

Before the final generation calls, add:

```powershell
function New-StoreIcon {
  param(
    [string]$BackgroundPath,
    [string]$ForegroundPath,
    [string]$OutputPath
  )

  [System.Drawing.Bitmap]$background = $null
  [System.Drawing.Bitmap]$foreground = $null
  [System.Drawing.Bitmap]$storeIcon = $null
  [System.Drawing.Graphics]$graphics = $null
  try {
    $background = [System.Drawing.Bitmap]::new($BackgroundPath)
    $foreground = [System.Drawing.Bitmap]::new($ForegroundPath)
    $storeIcon = [System.Drawing.Bitmap]::new(
      1024,
      1024,
      [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($storeIcon)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.DrawImageUnscaled($background, 0, 0)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $graphics.DrawImageUnscaled($foreground, 0, 0)
    $storeIcon.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally {
    if ($null -ne $graphics) { $graphics.Dispose() }
    if ($null -ne $storeIcon) { $storeIcon.Dispose() }
    if ($null -ne $foreground) { $foreground.Dispose() }
    if ($null -ne $background) { $background.Dispose() }
  }
}
```

- [ ] **Step 4: Wire the deterministic store artifact generation**

Replace the existing directory creation line and add the composition call so the tail reads:

```powershell
New-Item -ItemType Directory -Force -Path $appMediaDirectory, $entryMediaDirectory, $releaseDirectory | Out-Null
New-BackgroundLayer $appBackgroundPath
New-ForegroundLayer $appForegroundPath
Copy-Item -LiteralPath $appBackgroundPath -Destination $entryBackgroundPath -Force
Copy-Item -LiteralPath $appForegroundPath -Destination $entryForegroundPath -Force
New-StoreIcon `
  -BackgroundPath $appBackgroundPath `
  -ForegroundPath $appForegroundPath `
  -OutputPath $storeIconPath
```

Keep the obsolete-icon path guard and removal behavior unchanged.

- [ ] **Step 5: Generate the artifact and verify GREEN**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\generate-layered-icon.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-icon-assets.ps1
```

Expected: generator reports deterministic 1024x1024 assets and the test prints `Icon asset contract passed.`

- [ ] **Step 6: Verify deterministic output**

Run:

```powershell
$before = (Get-FileHash -Algorithm SHA256 -LiteralPath '.\docs\release\appgallery-icon.png').Hash
powershell -ExecutionPolicy Bypass -File .\scripts\generate-layered-icon.ps1
$after = (Get-FileHash -Algorithm SHA256 -LiteralPath '.\docs\release\appgallery-icon.png').Hash
if ($before -cne $after) { throw 'Store icon generation is not deterministic.' }
Write-Host "Store icon SHA-256: $after"
```

Expected: one SHA-256 value and exit code 0.

### Task 4: Lock Identity And External Submission Handoff

**Files:**
- Modify: `docs/release/appgallery-submission-checklist.md`
- Verify only: `AppScope/resources/base/element/string.json`
- Verify only: `entry/src/main/resources/base/element/string.json`
- Verify only: `entry/src/main/ets/pages/Index.ets`
- Verify only: `docs/release/privacy-policy.md`
- Verify only: `docs/release/user-agreement.md`
- Test: `scripts/test-appgallery-remediation-contract.ps1`

- [ ] **Step 1: Add the rejection-specific checklist section**

Append this section before `## 三、提交产物留档`:

```markdown
## 三、本次驳回专项复核

- [x] 包内 AppScope、EntryAbility、首页、隐私政策和用户协议统一使用 `光迹字幕`。
- [x] 商店图标产物为 `docs/release/appgallery-icon.png`，1024x1024、全画布不透明、无预切圆角，并与包内图标使用同一分层源。
- [ ] AGC 商品名、简介、详细介绍、隐私资料和软件资质统一为 `光迹字幕`；开发者名称使用当前 AGC 主体的准确名称。
- [ ] 上传包含即时点击响应修复的最新正式包，并使用 AppAnalyzer 或 DevEco Testing 复测点击完成时延，`T2-T1 <= 900ms`。
- [ ] 核对新包安装后启动器、最近任务、隐私模块与 AGC 的名称和图标完全一致。
- [ ] AGC 保存、包上传和重新提审前确认具体字段、文件与账号，未经确认不产生外部写入。
```

Renumber the existing artifact archive heading from `## 三` to `## 四`.

- [ ] **Step 2: Run the focused contract and confirm GREEN**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-appgallery-remediation-contract.ps1
```

Expected: `AppGallery remediation contract passed.`

- [ ] **Step 3: Re-run existing identity and click contracts**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-display-safety-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-appgallery-acceptance.ps1
```

Expected: display-safety passes. AppGallery acceptance either passes or reports only the pre-existing `build-profile.json5` signing-material blocker; do not modify that file to force GREEN.

### Task 5: Compile, Build, And Inspect The New Package

**Files:**
- Generated only: `entry/build/default/outputs/default/*`
- Modify after results: `design-qa.md`

- [ ] **Step 1: Run focused contracts**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-appgallery-remediation-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-icon-assets.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-accessibility-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-display-safety-contract.ps1
```

Expected: all four commands exit 0.

- [ ] **Step 2: Run the project standard check**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
```

Expected: all task-owned contracts pass. If the command remains non-zero only because of pre-existing tracked signing material, record that exact blocker and leave the signing file untouched.

- [ ] **Step 3: Compile ArkTS and build**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-arkts-compile.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1
```

Expected: ArkTS compilation exits 0 and Hvigor prints `BUILD SUCCESSFUL`.

- [ ] **Step 4: Record the actual artifact without guessing its filename**

Run:

```powershell
$artifact = Get-ChildItem -LiteralPath '.\entry\build\default\outputs\default' -File |
  Where-Object { $_.Extension -in @('.hap', '.app') } |
  Sort-Object LastWriteTimeUtc -Descending |
  Select-Object -First 1
if ($null -eq $artifact) { throw 'No HAP or APP artifact was produced.' }
$hash = (Get-FileHash -LiteralPath $artifact.FullName -Algorithm SHA256).Hash
[PSCustomObject]@{
  File = $artifact.FullName
  Bytes = $artifact.Length
  SHA256 = $hash
  BuiltAt = $artifact.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
}
```

Expected: one newest artifact record with non-zero size and SHA-256.

### Task 6: Available-Device And Performance Verification

**Files:**
- Create when available: `docs/qa/2026-08-12-appgallery-remediation-<device>-history-empty.*`
- Create when available: `docs/qa/2026-08-12-appgallery-remediation-<device>-history-filled.*`
- Create when available: `docs/qa/2026-08-12-appgallery-remediation-click-latency.md`
- Modify after results: `design-qa.md`

- [ ] **Step 1: Discover available device classes**

Run:

```powershell
$hdc = Get-Command hdc -ErrorAction SilentlyContinue
if ($null -eq $hdc) {
  Write-Host 'HDC unavailable: phone/tablet/2in1 runtime verification remains unverified.'
} else {
  & $hdc.Source list targets
}
```

Expected: connected targets are listed. Any unavailable phone/tablet/2in1 class is recorded as `unverified`, never `pass`.

- [ ] **Step 2: Verify the history header on each available class**

For each connected phone/tablet/2in1:

1. Install and launch the newest built package using the repository's established HDC/DevEco flow.
2. Open History with no records and capture layout/screenshot evidence; assert that `清空` is absent.
3. Create one display history record, reopen History, and capture evidence; assert that `清空` is present, readable, and opens the confirmation dialog.
4. Cancel once, then confirm once; assert the list becomes empty immediately and the clear action disappears.

Expected: no low-contrast clear text in empty state; populated state retains the full confirmation workflow.

- [ ] **Step 3: Measure click completion with Huawei's T2-T1 definition**

Using AppAnalyzer or DevEco Testing on an available supported device:

1. Start a trace before tapping `开始显示`.
2. Mark T1 at the input event received by the application.
3. Mark T2 at the first fully rendered `DisplayPage` result frame.
4. Record `T2-T1` for at least three runs and keep the worst value.
5. Repeat one immediate local-state action such as counter increment to guard against persistence regression.

Expected: worst display-entry click completion is `<=900ms`. If the tool or device is unavailable, verdict is `unverified`; source order or build success cannot be reported as a runtime pass.

### Task 7: Complete Project Records And Prepare The AGC Handoff

**Files:**
- Modify: `tasks.md`
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`

- [ ] **Step 1: Record design-visible behavior**

Append to `design.md` that the History header omits the clear command for empty data, preserves a 48vp trailing slot, and uses a 48vp enabled hit target. Record that `docs/release/appgallery-icon.png` is the store artifact while runtime icons remain layered resources.

- [ ] **Step 2: Record implementation changes**

Append to `changes.md` the exact local files changed, store-icon SHA-256, package path/size/hash, and the fact that AGC was not modified.

- [ ] **Step 3: Record requirement-level QA verdicts**

Add six rows to `design-qa.md`, one per report finding, using only `pass`, `fail`, `partial`, `not applicable`, or `unverified`. Cite source files, contract outputs, artifact hashes, device class/OS, screenshots, and measured milliseconds. Keep external AGC rows `unverified` until the user authorizes and verifies actual saves.

- [ ] **Step 4: Close the registered task only to the verified level**

In `tasks.md`, mark local implementation/build/documentation checklist items complete. Keep device classes or AGC handoffs unchecked when unavailable or unauthorized. Set `T-20260812-003` to `done` only when all user-requested local work is complete and every remaining external item is explicitly documented as a handoff rather than silently treated as passed.

- [ ] **Step 5: Review final scope and staged content**

Run:

```powershell
git diff --check
git status --short
git diff -- entry/src/main/ets/pages/HistoryPage.ets scripts/generate-layered-icon.ps1 scripts/test-icon-assets.ps1 scripts/test-appgallery-remediation-contract.ps1 scripts/check-standard.ps1 docs/release/appgallery-submission-checklist.md tasks.md design.md changes.md design-qa.md
git diff --cached --name-only
```

Expected: no whitespace errors; no edits to signing, bundle, version, app ID, or unrelated source. Do not commit until the staged diff contains only reviewed task changes.

## External AGC Confirmation Gate

After all local tasks pass, stop and report the exact package artifact, store icon, proposed AGC name `光迹字幕`, metadata fields, privacy/qualification implications, and unresolved device verdicts. Ask for action-time confirmation before saving AGC fields, uploading either file, or clicking resubmit. Confirmation to implement this plan does not authorize those external actions.
