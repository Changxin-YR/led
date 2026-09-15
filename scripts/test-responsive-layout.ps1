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
      $failures.Add("$RelativePath is missing responsive layout contract: $pattern")
    }
  }
}

Assert-FileContains 'entry/src/main/ets/common/Theme.ets' @(
  'HEADER_HEIGHT: number = 60',
  'BOTTOM_NAV_HEIGHT: number = 72',
  'NAV_ICON_SLOT_HEIGHT: number = 30',
  'PAGE_SECTION_GAP: number = 14',
  'SYSTEM_TOP_PADDING: number = 28',
  'SYSTEM_BOTTOM_PADDING: number = 28',
  "SYSTEM_NAVIGATION_BAR: string = '#030A16'"
)
Assert-FileContains 'entry/src/main/ets/pages/Index.ets' @(
  'AppTheme.HEADER_HEIGHT',
  'AppTheme.NAV_ICON_SLOT_HEIGHT',
  'AppTheme.PAGE_SECTION_GAP',
  'AppTheme.SYSTEM_NAVIGATION_BAR',
  'padding({ top: AppTheme.SYSTEM_TOP_PADDING, bottom: AppTheme.SYSTEM_BOTTOM_PADDING })'
)
foreach ($page in @('TemplatePage.ets', 'HistoryPage.ets', 'CounterPage.ets', 'ColorPickerPage.ets')) {
  Assert-FileContains "entry/src/main/ets/pages/$page" @(
    'AppTheme.HEADER_HEIGHT',
    'padding({ top: AppTheme.SYSTEM_TOP_PADDING, bottom: AppTheme.SYSTEM_BOTTOM_PADDING })'
  )
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "Responsive layout contract failed with $($failures.Count) issue(s)."
}

Write-Host 'Responsive layout contract passed.' -ForegroundColor Green
