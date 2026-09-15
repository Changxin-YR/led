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

function Get-MethodContent {
  param(
    [string]$Content,
    [string]$MethodName
  )

  $declarationPattern = '(?m)^[ \t]*(?:(?:public|private|protected|static|async|override)\s+)*' +
    [regex]::Escape($MethodName) + '\s*\([^\r\n]*\)[^{\r\n]*\{'
  $declaration = [regex]::Match($Content, $declarationPattern)
  if (-not $declaration.Success) {
    return $null
  }

  $openingBrace = $declaration.Index + $declaration.Length - 1
  $depth = 0
  $quoteCode = 0
  $escapedCharacter = $false
  $inLineComment = $false
  $inBlockComment = $false

  for ($index = $openingBrace; $index -lt $Content.Length; $index += 1) {
    $characterCode = [int][char]$Content[$index]
    $nextCharacterCode = if ($index + 1 -lt $Content.Length) {
      [int][char]$Content[$index + 1]
    } else {
      -1
    }

    if ($inLineComment) {
      if ($characterCode -eq 10) {
        $inLineComment = $false
      }
      continue
    }
    if ($inBlockComment) {
      if ($characterCode -eq 42 -and $nextCharacterCode -eq 47) {
        $inBlockComment = $false
        $index += 1
      }
      continue
    }
    if ($quoteCode -ne 0) {
      if ($escapedCharacter) {
        $escapedCharacter = $false
      } elseif ($characterCode -eq 92) {
        $escapedCharacter = $true
      } elseif ($characterCode -eq $quoteCode) {
        $quoteCode = 0
      }
      continue
    }

    if ($characterCode -eq 47 -and $nextCharacterCode -eq 47) {
      $inLineComment = $true
      $index += 1
      continue
    }
    if ($characterCode -eq 47 -and $nextCharacterCode -eq 42) {
      $inBlockComment = $true
      $index += 1
      continue
    }
    if ($characterCode -eq 39 -or $characterCode -eq 34 -or $characterCode -eq 96) {
      $quoteCode = $characterCode
      continue
    }
    if ($characterCode -eq 123) {
      $depth += 1
      continue
    }
    if ($characterCode -eq 125) {
      $depth -= 1
      if ($depth -eq 0) {
        return $Content.Substring($declaration.Index, $index - $declaration.Index + 1)
      }
    }
  }

  return $null
}

function Assert-MethodContains {
  param(
    [string]$RelativePath,
    [string]$MethodName,
    [string[]]$Patterns
  )

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("Missing file: $RelativePath")
    return
  }

  $content = Get-Content -Encoding UTF8 -Raw -LiteralPath $path
  $methodContent = Get-MethodContent $content $MethodName
  if ($null -eq $methodContent) {
    $failures.Add("$RelativePath is missing method declaration: $MethodName")
    return
  }

  foreach ($pattern in $Patterns) {
    if ($methodContent -notmatch [regex]::Escape($pattern)) {
      $failures.Add("$RelativePath.$MethodName is missing window contract: $pattern")
    }
  }
}

function Assert-ThemeColorsEqual {
  param(
    [string]$RelativePath,
    [string]$FirstName,
    [string]$SecondName
  )

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("Missing file: $RelativePath")
    return
  }

  $content = Get-Content -Encoding UTF8 -Raw -LiteralPath $path
  $values = @{}
  foreach ($name in @($FirstName, $SecondName)) {
    $pattern = "(?m)^[ \t]*static readonly " + [regex]::Escape($name) + ": string = '(#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?)'[ \t]*$"
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) {
      $failures.Add("$RelativePath is missing literal theme color: $name")
      return
    }
    $values[$name] = $match.Groups[1].Value.ToUpperInvariant()
  }

  if ($values[$FirstName] -ne $values[$SecondName]) {
    $failures.Add("$RelativePath theme colors must match: $FirstName=$($values[$FirstName]), $SecondName=$($values[$SecondName])")
  }
}

$scopeFixture = @'
class ScopeFixture {
  async target(): Promise<void> {
    const closingBrace: string = '}'
    if (closingBrace.length > 0) {
      consume(closingBrace)
    }
  }

  private static helper(): void {
    followingMethodOnly()
  }
}
'@
$targetFixtureMethod = Get-MethodContent $scopeFixture 'target'
if ($null -eq $targetFixtureMethod -or $targetFixtureMethod -match [regex]::Escape('followingMethodOnly()')) {
  $failures.Add('Method scope extractor absorbed content from a following private static synchronous method.')
}
$helperFixtureMethod = Get-MethodContent $scopeFixture 'helper'
if ($null -eq $helperFixtureMethod -or $helperFixtureMethod -notmatch [regex]::Escape('followingMethodOnly()')) {
  $failures.Add('Method scope extractor did not recognize a private static synchronous method declaration.')
}

Assert-FileContains 'entry/src/main/ets/common/Theme.ets' @(
  "static readonly SYSTEM_STATUS_BAR: string = '#030A16'",
  'SYSTEM_NAVIGATION_BAR'
)
Assert-ThemeColorsEqual 'entry/src/main/ets/common/Theme.ets' 'SYSTEM_STATUS_BAR' 'PAGE_BG'
Assert-ThemeColorsEqual 'entry/src/main/ets/common/Theme.ets' 'SYSTEM_NAVIGATION_BAR' 'PAGE_BG'
Assert-FileContains 'entry/src/main/ets/services/ScreenService.ets' @(
  'applyAppChrome',
  'enterDisplayMode',
  'exitDisplayMode',
  'setWindowSystemBarProperties',
  'window.Orientation.UNSPECIFIED'
)
Assert-MethodContains 'entry/src/main/ets/services/ScreenService.ets' 'applyAppChrome' @(
  'setWindowBackgroundColor(AppTheme.PAGE_BG)',
  'setWindowLayoutFullScreen(false)',
  "setWindowSystemBarEnable(['status', 'navigation'])",
  'setWindowSystemBarProperties({',
  'statusBarColor: AppTheme.PAGE_BG',
  'navigationBarColor: AppTheme.SYSTEM_NAVIGATION_BAR',
  'statusBarContentColor: AppTheme.TEXT_PRIMARY',
  'isStatusBarLightIcon: true',
  'navigationBarContentColor: AppTheme.TEXT_PRIMARY',
  'isNavigationBarLightIcon: true'
)
Assert-MethodContains 'entry/src/main/ets/services/ScreenService.ets' 'enterDisplayMode' @(
  'setWindowLayoutFullScreen(true)',
  'setWindowSystemBarEnable([])'
)
Assert-MethodContains 'entry/src/main/ets/services/ScreenService.ets' 'exitDisplayMode' @(
  'applyAppChrome()'
)
Assert-FileContains 'entry/src/main/ets/entryability/EntryAbility.ets' @(
  'getMainWindow()',
  'applyAppChrome()'
)
$entryAbilityContent = Get-Content -Encoding UTF8 -Raw -LiteralPath (Join-Path $projectRoot 'entry/src/main/ets/entryability/EntryAbility.ets')
$loadContentCallback = [regex]::Match($entryAbilityContent, '(?s)windowStage\.loadContent\(.*?\r?\n\s*\}\)')
if (-not $loadContentCallback.Success -or $loadContentCallback.Value -notmatch 'this\.screenService\.applyAppChrome\(\)') {
  $failures.Add('EntryAbility must reapply themed system-bar properties after ordinary page content loads.')
}
Assert-FileContains 'entry/src/main/ets/pages/DisplayPage.ets' @(
  'enterDisplayMode(this.config?.isLandscape === true)',
  'exitDisplayMode()',
  'updateDisplaySize()'
)
$normalPages = @(
  'entry/src/main/ets/pages/Index.ets',
  'entry/src/main/ets/pages/TemplatePage.ets',
  'entry/src/main/ets/pages/HistoryPage.ets',
  'entry/src/main/ets/pages/ColorPickerPage.ets',
  'entry/src/main/ets/pages/CounterPage.ets'
)
foreach ($normalPage in $normalPages) {
  Assert-MethodContains $normalPage 'build' @(
    '.backgroundColor(AppTheme.PAGE_BG)',
    '.padding({ top: AppTheme.SYSTEM_TOP_PADDING, bottom: AppTheme.SYSTEM_BOTTOM_PADDING })'
  )
}
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
