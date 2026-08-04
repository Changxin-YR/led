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
      $failures.Add("$RelativePath is missing UI contract: $pattern")
    }
  }
}

Assert-FileContains 'entry/src/main/ets/common/Theme.ets' @(
  'export class AppTheme',
  "ACCENT: string = '#00E5FF'",
  "PAGE_BG: string = '#030A16'"
)
Assert-FileContains 'entry/src/main/ets/components/LedPanel.ets' @(
  'export struct LedPanel',
  'dotColor',
  'textShadow'
)
Assert-FileContains 'entry/src/main/ets/pages/Index.ets' @(
  "import { LedPanel }",
  'buildPreview',
  'buildColorSelector',
  'buildStartButton'
)
Assert-FileContains 'entry/src/main/ets/pages/ColorPickerPage.ets' @(
  'buildColorPreview',
  'buildRecentColors',
  'buildConfirmButton'
)
Assert-FileContains 'entry/src/main/ets/pages/TemplatePage.ets' @(
  'buildCategoryTabs',
  'buildTemplateCard'
)
Assert-FileContains 'entry/src/main/ets/pages/HistoryPage.ets' @(
  'buildHistoryList',
  'buildHistoryCard'
)
Assert-FileContains 'entry/src/main/ets/pages/CounterPage.ets' @(
  'buildCounterButton',
  'buildCounterPanel'
)

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "UI contract failed with $($failures.Count) issue(s)."
}

Write-Host 'UI restoration contract passed.' -ForegroundColor Green
