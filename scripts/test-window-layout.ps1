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
      $failures.Add("$RelativePath is missing window contract: $pattern")
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
      $failures.Add("$RelativePath must not contain window contract: $pattern")
    }
  }
}

Assert-FileContains 'entry/src/main/ets/common/Theme.ets' @(
  'SYSTEM_STATUS_BAR',
  'SYSTEM_NAVIGATION_BAR'
)
Assert-FileContains 'entry/src/main/ets/services/ScreenService.ets' @(
  'applyAppChrome',
  'enterDisplayMode',
  'exitDisplayMode',
  'setWindowSystemBarProperties'
)
Assert-FileContains 'entry/src/main/ets/entryability/EntryAbility.ets' @(
  'getMainWindow()',
  'applyAppChrome()'
)
Assert-FileContains 'entry/src/main/ets/pages/DisplayPage.ets' @(
  'enterDisplayMode(this.config?.isLandscape === true)',
  'exitDisplayMode()',
  'updateDisplaySize()'
)
Assert-FileNotContains 'entry/src/main/ets/pages/CounterPage.ets' @(
  'ScreenService',
  'enterFullScreen',
  'setKeepScreenOn'
)

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "Window layout contract failed with $($failures.Count) issue(s)."
}

Write-Host 'Window layout contract passed.' -ForegroundColor Green
