$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]

function Assert-FileContains {
  param(
    [string]$RelativePath,
    [string[]]$Patterns
  )

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("Missing file: $RelativePath")
    return
  }

  $content = Get-Content -Encoding UTF8 -Raw -LiteralPath $path
  foreach ($pattern in $Patterns) {
    if ($content -notmatch [regex]::Escape($pattern)) {
      $failures.Add("$RelativePath is missing business contract: $pattern")
    }
  }
}

function Assert-FileNotContains {
  param(
    [string]$RelativePath,
    [string[]]$Patterns
  )

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("Missing file: $RelativePath")
    return
  }

  $content = Get-Content -Encoding UTF8 -Raw -LiteralPath $path
  foreach ($pattern in $Patterns) {
    if ($content -match [regex]::Escape($pattern)) {
      $failures.Add("$RelativePath contains forbidden business contract: $pattern")
    }
  }
}

Assert-FileContains 'entry/src/main/ets/services/StorageService.ets' @(
  'private initPromise: Promise<void> | null = null',
  'private isValidBannerConfig(value: Object): boolean',
  'if (!Array.isArray(parsed))',
  'id: config.id',
  'async saveDisplayConfig(config: BannerConfig): Promise<void>',
  'private mergeHistory(records: HistoryRecord[], config: BannerConfig): HistoryRecord[]'
)

Assert-FileContains 'entry/src/main/ets/pages/Index.ets' @(
  'private storageInitPromise: Promise<void> | null = null',
  'private persistDisplayConfig(config: BannerConfig): void',
  'this.persistDisplayConfig(config)'
)
Assert-FileNotContains 'entry/src/main/ets/pages/Index.ets' @('await this.ensureStorageReady()')

Assert-FileContains 'entry/src/main/ets/pages/CounterPage.ets' @(
  'private storageInitPromise: Promise<void> | null = null',
  'private async changeCount(delta: number): Promise<void>',
  'if (this.storageInitPromise === pending) this.storageInitPromise = null',
  '.enabled(!this.isUpdating)'
)

Assert-FileContains 'entry/src/main/ets/pages/DisplayPage.ets' @(
  'private guideTimer: number = -1',
  'onPageHide(): void',
  'onPageShow(): void',
  'if (this.guideTimer >= 0) { clearTimeout(this.guideTimer); this.guideTimer = -1 }',
  'this.barrageOffsets = initialOffsets',
  'const travelLimit = (this.screenHeight + textHeight) / 2',
  'const startPos = isTtb ? -travelLimit : travelLimit',
  'const endPos = isTtb ? travelLimit : -travelLimit',
  '@State textScale: number = 1.0',
  'this.textScale = 1.0 - (step / steps) * 0.06',
  'GestureGroup(GestureMode.Exclusive,'
  'TapGesture({ count: 2 })'
  'this.onDoubleTap()'
  'TapGesture({ count: 1 })'
  'this.onSingleTap()'
)

Assert-FileNotContains 'entry/src/main/ets/pages/DisplayPage.ets' @(
  'const startPos = isTtb ? -textHeight : this.screenHeight',
  'const endPos = isTtb ? this.screenHeight : -textHeight',
  'textOpacity',
  'private tapCount: number',
  'private tapTimer: number',
  'private handleTap(): void'
)

Assert-FileContains 'entry/src/main/ets/pages/HistoryPage.ets' @(
  '(item: HistoryRecord) => `${item.id}-${item.useCount}-${item.lastUsedAt}`',
  'private persistDisplayConfig(config: BannerConfig): void',
  'private persistHistoryChange(operation: () => Promise<void>, message: string): void'
)

$historyPath = Join-Path $projectRoot 'entry/src/main/ets/pages/HistoryPage.ets'
$historyContent = Get-Content -Encoding UTF8 -Raw -LiteralPath $historyPath
$historyUsePattern = '(?s)private async useRecord\(record: HistoryRecord\).*?' +
  'UiContextHelper\.pushUrl.*?persistDisplayConfig\(config\)'
if ($historyContent -notmatch $historyUsePattern) {
  $failures.Add('HistoryPage.useRecord must navigate before beginning background history persistence.')
}

Assert-FileContains 'entry/src/main/ets/pages/TemplatePage.ets' @(
  '@State isStarting: boolean = false',
  'this.isStarting = true',
  'this.isStarting = false'
)

Assert-FileContains 'entry/src/main/ets/pages/ColorPickerPage.ets' @(
  'private persistCustomColor(color: string): void',
  'const isValidInput =',
  'UiContextHelper.showToast(this.getUIContext(),'
)

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "Business contract failed with $($failures.Count) issue(s)."
}

Write-Host 'Business contract passed.' -ForegroundColor Green
