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

function Find-MatchingDelimiter {
  param(
    [string]$Content,
    [int]$OpenIndex,
    [char]$OpenDelimiter,
    [char]$CloseDelimiter
  )

  $depth = 0
  $quote = [char]0
  $escaped = $false
  for ($index = $OpenIndex; $index -lt $Content.Length; $index++) {
    $current = $Content[$index]
    if ($quote -ne [char]0) {
      if ($escaped) {
        $escaped = $false
      } elseif ([int]$current -eq 92) {
        $escaped = $true
      } elseif ($current -eq $quote) {
        $quote = [char]0
      }
      continue
    }
    if ($current -eq "'" -or $current -eq '"' -or [int]$current -eq 96) {
      $quote = $current
    } elseif ($current -eq $OpenDelimiter) {
      $depth++
    } elseif ($current -eq $CloseDelimiter) {
      $depth--
      if ($depth -eq 0) {
        return $index
      }
    }
  }
  return -1
}

function Get-CallBlock {
  param(
    [string]$Content,
    [string]$DeclarationPattern,
    [int]$Occurrence = 0
  )

  $declarations = [regex]::Matches($Content, $DeclarationPattern)
  if ($Occurrence -lt 0 -or $Occurrence -ge $declarations.Count) {
    return $null
  }

  $openParenthesis = $Content.IndexOf('(', $declarations[$Occurrence].Index)
  $closeParenthesis = Find-MatchingDelimiter $Content $openParenthesis '(' ')'
  if ($closeParenthesis -lt 0) {
    return $null
  }

  $openBrace = $closeParenthesis + 1
  while ($openBrace -lt $Content.Length -and [char]::IsWhiteSpace($Content[$openBrace])) {
    $openBrace++
  }
  if ($openBrace -ge $Content.Length -or $Content[$openBrace] -ne '{') {
    return $null
  }

  $closeBrace = Find-MatchingDelimiter $Content $openBrace '{' '}'
  if ($closeBrace -lt 0) {
    return $null
  }
  return [PSCustomObject]@{
    Body = $Content.Substring($openBrace + 1, $closeBrace - $openBrace - 1)
    EndIndex = $closeBrace
  }
}

function Get-BuilderContainer {
  param(
    [string]$Content,
    [string]$BuilderName,
    [string]$ContainerType,
    [int]$Occurrence = 0
  )

  $builderPattern = '(?m)^[ \t]*' + [regex]::Escape($BuilderName) + '\s*\('
  $builder = Get-CallBlock $Content $builderPattern
  if ($null -eq $builder) {
    return $null
  }

  $containerPattern = '(?m)^[ \t]*' + [regex]::Escape($ContainerType) + '\s*\('
  $container = Get-CallBlock $builder.Body $containerPattern $Occurrence
  if ($null -eq $container) {
    return $null
  }

  $modifierCalls = New-Object System.Collections.Generic.List[string]
  $cursor = $container.EndIndex + 1
  while ($cursor -lt $builder.Body.Length) {
    while ($cursor -lt $builder.Body.Length -and [char]::IsWhiteSpace($builder.Body[$cursor])) {
      $cursor++
    }
    if ($cursor -ge $builder.Body.Length -or $builder.Body[$cursor] -ne '.') {
      break
    }

    $callStart = $cursor
    $cursor++
    while ($cursor -lt $builder.Body.Length -and
        ([char]::IsLetterOrDigit($builder.Body[$cursor]) -or $builder.Body[$cursor] -eq '_')) {
      $cursor++
    }
    while ($cursor -lt $builder.Body.Length -and [char]::IsWhiteSpace($builder.Body[$cursor])) {
      $cursor++
    }
    if ($cursor -ge $builder.Body.Length -or $builder.Body[$cursor] -ne '(') {
      break
    }

    $callEnd = Find-MatchingDelimiter $builder.Body $cursor '(' ')'
    if ($callEnd -lt 0) {
      break
    }
    [void]$modifierCalls.Add($builder.Body.Substring($callStart, $callEnd - $callStart + 1))
    $cursor = $callEnd + 1
  }

  return [PSCustomObject]@{ ModifierCalls = $modifierCalls.ToArray() }
}

function Test-ContainerHasSpringEdgeEffect {
  param([object]$Container)

  for ($index = 0; $index + 1 -lt $Container.ModifierCalls.Count; $index++) {
    if ($Container.ModifierCalls[$index] -eq '.scrollBar(BarState.Off)' -and
        $Container.ModifierCalls[$index + 1] -eq '.edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })') {
      return $true
    }
  }
  return $false
}

function Assert-BuilderContainerEdgeContract {
  param(
    [string]$RelativePath,
    [string]$BuilderName,
    [string]$ContainerType,
    [string]$ContainerName,
    [bool]$RequiresSpring
  )

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("$ContainerName cannot be checked because $RelativePath is missing.")
    return
  }

  $content = Get-Content -Encoding UTF8 -Raw -LiteralPath $path
  $container = Get-BuilderContainer $content $BuilderName $ContainerType
  if ($null -eq $container) {
    $failures.Add("$ContainerName could not be located for its UI contract.")
    return
  }

  if ($RequiresSpring) {
    if (-not (Test-ContainerHasSpringEdgeEffect $container)) {
      $failures.Add("$ContainerName must apply .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true }) immediately after its scrollBar modifier.")
    }
    return
  }

  foreach ($modifierCall in $container.ModifierCalls) {
    if ($modifierCall.StartsWith('.edgeEffect(')) {
      $failures.Add("$ContainerName is a layout Grid and must not add nested scroll edge feedback.")
      return
    }
  }
}

$siblingMutationFixtures = @(
  [PSCustomObject]@{ Type = 'Scroll'; TargetConstructor = 'Scroll()'; SiblingConstructor = 'Scroll()' },
  [PSCustomObject]@{ Type = 'Grid'; TargetConstructor = 'Grid()'; SiblingConstructor = 'Grid()' },
  [PSCustomObject]@{
    Type = 'List'
    TargetConstructor = "List(`n        { space: 8 }`n      )"
    SiblingConstructor = 'List({ space: 4 })'
  }
)
foreach ($fixture in $siblingMutationFixtures) {
  $fixtureContent = @"
  buildFixture() {
    Column() {
      $($fixture.TargetConstructor) {
        Text('target')
      }
      .scrollBar(BarState.Off)
      $($fixture.SiblingConstructor) {
        Text('sibling')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
  }
"@
  $fixtureTarget = Get-BuilderContainer $fixtureContent 'buildFixture' $fixture.Type
  if ($null -eq $fixtureTarget) {
    $failures.Add("UI contract parser mutation fixture could not locate the target $($fixture.Type) container.")
  } elseif (Test-ContainerHasSpringEdgeEffect $fixtureTarget) {
    $failures.Add("UI contract parser must not use a later sibling $($fixture.Type) edgeEffect for the target container.")
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

$indexPath = Join-Path $projectRoot 'entry/src/main/ets/pages/Index.ets'
$indexContent = Get-Content -Encoding UTF8 -Raw -LiteralPath $indexPath
$tabLabelBlock = [regex]::Match($indexContent, '(?s)@Builder\s+buildBottomNav\(\)\s*\{.*?Text\(item\.label\)(?<label>.*?\.margin\(\{ top: 4 \}\))')
if (-not $tabLabelBlock.Success -or $tabLabelBlock.Groups['label'].Value -notmatch '\.textAlign\(TextAlign\.Center\)') {
  $failures.Add('Index.ets bottom navigation labels must be centered below their icons.')
}

Assert-FileContains 'entry/src/main/ets/common/Theme.ets' @(
  'SETTING_ROW_HEIGHT: number = 38',
  'SETTING_PANEL_VERTICAL_PADDING: number = 6'
)
$settingRowBlock = [regex]::Match($indexContent, '(?s)@Builder\s+buildSettingRow\(.*?\.height\(AppTheme\.SETTING_ROW_HEIGHT\)')
if (-not $settingRowBlock.Success) {
  $failures.Add('Index.ets setting rows must use the shared expanded row height.')
}
if ($indexContent -notmatch [regex]::Escape('.padding({ left: 8, right: 4, top: AppTheme.SETTING_PANEL_VERTICAL_PADDING, bottom: AppTheme.SETTING_PANEL_VERTICAL_PADDING })')) {
  $failures.Add('Index.ets other settings panel must include shared vertical padding.')
}

Assert-FileContains 'entry/src/main/ets/common/Theme.ets' @(
  'UI_FONT_SCALE: number = 1.08',
  'static uiFontSize(baseSize: number): number',
  'UI_FONT_WEIGHT: FontWeight = FontWeight.Medium'
)
foreach ($relativePath in @(
  'entry/src/main/ets/pages/Index.ets',
  'entry/src/main/ets/pages/TemplatePage.ets',
  'entry/src/main/ets/pages/HistoryPage.ets',
  'entry/src/main/ets/pages/ColorPickerPage.ets',
  'entry/src/main/ets/pages/CounterPage.ets',
  'entry/src/main/ets/pages/DisplayPage.ets'
)) {
  Assert-FileContains $relativePath @('AppTheme.uiFontSize(')
  Assert-FileContains $relativePath @('AppTheme.UI_FONT_WEIGHT')
}

Assert-BuilderContainerEdgeContract `
  'entry/src/main/ets/pages/Index.ets' `
  'build' `
  'Scroll' `
  'Index.ets main vertical Scroll' `
  $true
Assert-BuilderContainerEdgeContract `
  'entry/src/main/ets/pages/ColorPickerPage.ets' `
  'build' `
  'Scroll' `
  'ColorPickerPage.ets main vertical Scroll' `
  $true
Assert-BuilderContainerEdgeContract `
  'entry/src/main/ets/pages/TemplatePage.ets' `
  'buildCategoryTabs' `
  'Scroll' `
  'TemplatePage.ets horizontal category Scroll' `
  $true
Assert-BuilderContainerEdgeContract `
  'entry/src/main/ets/pages/TemplatePage.ets' `
  'buildTemplateGrid' `
  'Grid' `
  'TemplatePage.ets vertical template Grid' `
  $true
Assert-BuilderContainerEdgeContract `
  'entry/src/main/ets/pages/HistoryPage.ets' `
  'buildHistoryList' `
  'List' `
  'HistoryPage.ets history List' `
  $true
Assert-BuilderContainerEdgeContract `
  'entry/src/main/ets/pages/Index.ets' `
  'buildModeSelector' `
  'Grid' `
  'Index.ets mode option Grid' `
  $false
Assert-BuilderContainerEdgeContract `
  'entry/src/main/ets/pages/Index.ets' `
  'buildColorSelector' `
  'Grid' `
  'Index.ets color option Grid' `
  $false

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "UI contract failed with $($failures.Count) issue(s)."
}

Write-Host 'UI restoration contract passed.' -ForegroundColor Green
