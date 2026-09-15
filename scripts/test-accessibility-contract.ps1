$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]
$themePath = Join-Path $projectRoot 'entry/src/main/ets/common/Theme.ets'

function Get-ThemeColors {
  param([string]$Path)

  $colors = @{}
  $content = Get-Content -Encoding UTF8 -Raw -LiteralPath $Path
  $colorMatches = [regex]::Matches(
    $content,
    "static\s+readonly\s+(?<name>[A-Z][A-Z0-9_]*)\s*:\s*string\s*=\s*'(?<hex>#[0-9A-Fa-f]{6})'"
  )
  foreach ($match in $colorMatches) {
    $colors[$match.Groups['name'].Value] = $match.Groups['hex'].Value.ToUpperInvariant()
  }
  return $colors
}

function ConvertTo-LinearSrgb {
  param([int]$Channel)

  $srgb = $Channel / 255.0
  if ($srgb -le 0.04045) {
    return $srgb / 12.92
  }
  return [Math]::Pow(($srgb + 0.055) / 1.055, 2.4)
}

function Get-RelativeLuminance {
  param([string]$HexColor)

  $red = [Convert]::ToInt32($HexColor.Substring(1, 2), 16)
  $green = [Convert]::ToInt32($HexColor.Substring(3, 2), 16)
  $blue = [Convert]::ToInt32($HexColor.Substring(5, 2), 16)
  return 0.2126 * (ConvertTo-LinearSrgb $red) +
    0.7152 * (ConvertTo-LinearSrgb $green) +
    0.0722 * (ConvertTo-LinearSrgb $blue)
}

function Get-ContrastRatio {
  param([string]$Foreground, [string]$Background)

  $foregroundLuminance = Get-RelativeLuminance $Foreground
  $backgroundLuminance = Get-RelativeLuminance $Background
  $lighter = [Math]::Max($foregroundLuminance, $backgroundLuminance)
  $darker = [Math]::Min($foregroundLuminance, $backgroundLuminance)
  return ($lighter + 0.05) / ($darker + 0.05)
}

function Assert-Contrast {
  param(
    [hashtable]$Colors,
    [string]$ForegroundName,
    [string]$BackgroundName,
    [double]$Minimum
  )

  foreach ($name in @($ForegroundName, $BackgroundName)) {
    if (-not $Colors.ContainsKey($name)) {
      $failures.Add("Theme.ets is missing required hex color constant AppTheme.$name.")
      return
    }
  }

  $ratio = Get-ContrastRatio $Colors[$ForegroundName] $Colors[$BackgroundName]
  if ($ratio -lt $Minimum) {
    $formattedRatio = $ratio.ToString('0.00', [Globalization.CultureInfo]::InvariantCulture)
    $failures.Add(
      "$ForegroundName on $BackgroundName has contrast $formattedRatio`:1; expected at least $Minimum`:1."
    )
  }
}

function Get-SourceContent {
  param([string]$RelativePath)

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("Missing file: $RelativePath")
    return ''
  }
  return Get-Content -Encoding UTF8 -Raw -LiteralPath $path
}

function Get-DelimiterBalanceChange {
  param([string]$Text, [bool]$IncludeBraces = $true)

  $balance = 0
  $quote = 0
  $escaped = $false
  for ($index = 0; $index -lt $Text.Length; $index++) {
    $characterCode = [int]$Text[$index]
    if ($quote -ne 0) {
      if ($escaped) {
        $escaped = $false
      } elseif ($characterCode -eq 92) {
        $escaped = $true
      } elseif ($characterCode -eq $quote) {
        $quote = 0
      }
      continue
    }

    if ($characterCode -eq 39 -or $characterCode -eq 34 -or $characterCode -eq 96) {
      $quote = $characterCode
      continue
    }
    if ($characterCode -eq 47 -and $index + 1 -lt $Text.Length -and [int]$Text[$index + 1] -eq 47) {
      break
    }

    switch ($characterCode) {
      40 { $balance++ }
      41 { $balance-- }
      91 { $balance++ }
      93 { $balance-- }
      123 { if ($IncludeBraces) { $balance++ } }
      125 { if ($IncludeBraces) { $balance-- } }
    }
  }
  return $balance
}

function Test-IgnorableChainLine {
  param([string]$Line)

  $trimmed = $Line.Trim()
  return $trimmed.Length -eq 0 -or $trimmed.StartsWith('//')
}

function Remove-SourceComments {
  param([string]$Content)

  $normalized = New-Object System.Text.StringBuilder
  $quote = 0
  $escaped = $false
  $inLineComment = $false
  $inBlockComment = $false
  for ($index = 0; $index -lt $Content.Length; $index++) {
    $characterCode = [int]$Content[$index]
    $nextCharacterCode = if ($index + 1 -lt $Content.Length) { [int]$Content[$index + 1] } else { -1 }

    if ($inLineComment) {
      if ($characterCode -eq 10 -or $characterCode -eq 13) {
        [void]$normalized.Append($Content[$index])
        if ($characterCode -eq 10) {
          $inLineComment = $false
        }
      } else {
        [void]$normalized.Append(' ')
      }
      continue
    }

    if ($inBlockComment) {
      if ($characterCode -eq 42 -and $nextCharacterCode -eq 47) {
        [void]$normalized.Append('  ')
        $index++
        $inBlockComment = $false
      } elseif ($characterCode -eq 10 -or $characterCode -eq 13) {
        [void]$normalized.Append($Content[$index])
      } else {
        [void]$normalized.Append(' ')
      }
      continue
    }

    if ($quote -ne 0) {
      [void]$normalized.Append($Content[$index])
      if ($escaped) {
        $escaped = $false
      } elseif ($characterCode -eq 92) {
        $escaped = $true
      } elseif ($characterCode -eq $quote) {
        $quote = 0
      }
      continue
    }

    if ($characterCode -eq 39 -or $characterCode -eq 34 -or $characterCode -eq 96) {
      [void]$normalized.Append($Content[$index])
      $quote = $characterCode
    } elseif ($characterCode -eq 47 -and $nextCharacterCode -eq 47) {
      [void]$normalized.Append('  ')
      $index++
      $inLineComment = $true
    } elseif ($characterCode -eq 47 -and $nextCharacterCode -eq 42) {
      [void]$normalized.Append('  ')
      $index++
      $inBlockComment = $true
    } else {
      [void]$normalized.Append($Content[$index])
    }
  }
  return $normalized.ToString()
}

function Get-ComponentModifierChains {
  param([string]$Content, [string]$RelativePath)

  $chains = @()
  $normalizedContent = Remove-SourceComments $Content
  $lines = [regex]::Split($normalizedContent, '\r?\n')
  for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
    $declarationMatch = [regex]::Match(
      $lines[$lineIndex],
      '^(?<indent>[ \t]*)(?<component>[A-Z][A-Za-z0-9_]*)\s*\('
    )
    if (-not $declarationMatch.Success) {
      continue
    }

    $baseIndent = $declarationMatch.Groups['indent'].Value.Length
    $declarationLines = @()
    $cursor = $lineIndex
    $declarationBalance = 0
    do {
      $declarationLines += $lines[$cursor].Trim()
      $declarationBalance += Get-DelimiterBalanceChange -Text $lines[$cursor] -IncludeBraces $false
      $cursor++
    } while ($cursor -lt $lines.Count -and $declarationBalance -gt 0)
    if ($declarationBalance -gt 0) {
      continue
    }

    while ($cursor -lt $lines.Count -and (Test-IgnorableChainLine $lines[$cursor])) {
      $cursor++
    }
    if ($cursor -ge $lines.Count) {
      continue
    }

    $firstModifierMatch = [regex]::Match($lines[$cursor], '^(?<indent>[ \t]+)\.[A-Za-z][A-Za-z0-9_]*\s*\(')
    if (-not $firstModifierMatch.Success) {
      continue
    }
    $modifierIndent = $firstModifierMatch.Groups['indent'].Value.Length
    if ($modifierIndent -le $baseIndent) {
      continue
    }

    $statements = @()
    while ($cursor -lt $lines.Count) {
      while ($cursor -lt $lines.Count -and (Test-IgnorableChainLine $lines[$cursor])) {
        $cursor++
      }
      if ($cursor -ge $lines.Count) {
        break
      }

      $modifierMatch = [regex]::Match($lines[$cursor], '^(?<indent>[ \t]*)\.[A-Za-z][A-Za-z0-9_]*\s*\(')
      if (-not $modifierMatch.Success -or $modifierMatch.Groups['indent'].Value.Length -ne $modifierIndent) {
        break
      }

      $statementLines = @()
      $balance = 0
      do {
        $statementLines += $lines[$cursor].Trim()
        $balance += Get-DelimiterBalanceChange $lines[$cursor]
        $cursor++
      } while ($cursor -lt $lines.Count -and $balance -gt 0)
      $statements += ($statementLines -join "`n")
    }

    $chains += [PSCustomObject]@{
      RelativePath = $RelativePath
      Line = $lineIndex + 1
      Component = $declarationMatch.Groups['component'].Value
      Declaration = $declarationLines -join "`n"
      Statements = [string[]]$statements
    }
  }
  return $chains
}

function Test-ChainHasStatement {
  param([PSCustomObject]$Chain, [string]$Pattern)

  foreach ($statement in $Chain.Statements) {
    if ($statement -match $Pattern) {
      return $true
    }
  }
  return $false
}

function Get-ChainsMatching {
  param([object[]]$Chains, [string[]]$Patterns)

  $matchingChains = @()
  foreach ($chain in $Chains) {
    $chainText = $chain.Declaration + "`n" + ($chain.Statements -join "`n")
    $matchesAll = $true
    foreach ($pattern in $Patterns) {
      if ($chainText -notmatch $pattern) {
        $matchesAll = $false
        break
      }
    }
    if ($matchesAll) {
      $matchingChains += $chain
    }
  }
  return $matchingChains
}

function Assert-ControlChainContract {
  param(
    [string]$Content,
    [string]$RelativePath,
    [string]$Control,
    [string[]]$IdentityPatterns,
    [string[]]$RequiredStatementPatterns
  )

  $chains = @(Get-ComponentModifierChains $Content $RelativePath)
  $matchingChains = @(Get-ChainsMatching $chains $IdentityPatterns)
  if ($matchingChains.Count -ne 1) {
    $failures.Add("$RelativePath $Control must resolve to exactly one modifier chain; found $($matchingChains.Count).")
    return
  }
  foreach ($pattern in $RequiredStatementPatterns) {
    if (-not (Test-ChainHasStatement $matchingChains[0] $pattern)) {
      $failures.Add("$RelativePath $Control is missing required same-control modifier: $pattern")
    }
  }
}

function Get-DeclarationBlockContent {
  param(
    [string]$Content,
    [string]$DeclarationPattern
  )

  $lines = [regex]::Split($Content, '\r?\n')
  $matchingLineIndexes = @()
  for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
    if ($lines[$lineIndex] -match $declarationPattern) {
      $matchingLineIndexes += $lineIndex
    }
  }
  if ($matchingLineIndexes.Count -ne 1) {
    return $null
  }

  $blockLines = @()
  $balance = 0
  for ($cursor = $matchingLineIndexes[0]; $cursor -lt $lines.Count; $cursor++) {
    $blockLines += $lines[$cursor]
    $balance += Get-DelimiterBalanceChange $lines[$cursor]
    if ($balance -eq 0) {
      return $blockLines -join "`n"
    }
  }
  return $null
}

function Get-ConditionalBlockContent {
  param(
    [string]$Content,
    [string]$ConditionPattern
  )

  $declarationPattern = '^\s*if\s*\(\s*' + $ConditionPattern + '\s*\)\s*\{'
  return Get-DeclarationBlockContent $Content $declarationPattern
}

function Test-BoundedControlChainContract {
  param(
    [string]$Content,
    [string[]]$IdentityPatterns,
    [string[]]$RequiredStatementPatterns
  )

  $chains = @(Get-ComponentModifierChains $Content 'bounded-overlay-contract.ets')
  $matchingChains = @(Get-ChainsMatching $chains $IdentityPatterns)
  if ($matchingChains.Count -ne 1) {
    return $false
  }
  foreach ($pattern in $RequiredStatementPatterns) {
    if (-not (Test-ChainHasStatement $matchingChains[0] $pattern)) {
      return $false
    }
  }
  return $true
}

function Get-BoundedContainerChainContent {
  param(
    [string]$Content,
    [string]$DeclarationPattern,
    [string]$SyntheticDeclaration
  )

  $lines = [regex]::Split($Content, '\r?\n')
  $matchingLineIndexes = @()
  for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
    if ($lines[$lineIndex] -match $DeclarationPattern) {
      $matchingLineIndexes += $lineIndex
    }
  }
  if ($matchingLineIndexes.Count -ne 1) {
    return $null
  }

  $balance = 0
  $closeLineIndex = -1
  for ($cursor = $matchingLineIndexes[0]; $cursor -lt $lines.Count; $cursor++) {
    $balance += Get-DelimiterBalanceChange $lines[$cursor]
    if ($cursor -gt $matchingLineIndexes[0] -and $balance -eq 0) {
      $closeLineIndex = $cursor
      break
    }
  }
  if ($closeLineIndex -lt 0 -or $closeLineIndex + 1 -ge $lines.Count) {
    return $null
  }

  $modifierLines = $lines[($closeLineIndex + 1)..($lines.Count - 1)]
  return $SyntheticDeclaration + "`n" + ($modifierLines -join "`n")
}

function Get-DisplayOverlayContractIssues {
  param([string]$Content)

  $issues = @()
  $sharedForegroundPattern = '^\.fontColor\(\s*AppTheme\.DISPLAY_OVERLAY_FG\s*\)$'
  $sharedBackgroundPattern = '^\.backgroundColor\(\s*AppTheme\.DISPLAY_OVERLAY_BG\s*\)$'
  $legacyOverlayColorPattern = '(?i)#(?:FFFFFF80|00000060|00000090)'
  $buildBlock = Get-DeclarationBlockContent $Content '^\s*build\s*\(\s*\)\s*\{'
  if ($null -eq $buildBlock) {
    return @('display overlays must resolve within exactly one bounded build method.')
  }

  $pausedBlock = Get-ConditionalBlockContent $buildBlock 'this\.isPaused'
  if ($null -eq $pausedBlock) {
    $issues += 'paused overlay must resolve to exactly one bounded conditional block.'
  } else {
    if ($pausedBlock -match $legacyOverlayColorPattern) {
      $issues += 'paused overlay must not use a legacy translucent foreground or background.'
    }
    if (-not (Test-BoundedControlChainContract $pausedBlock @("^Text\('\u5DF2\u6682\u505C'\)") @(
      $sharedForegroundPattern,
      $sharedBackgroundPattern,
      '^\.padding\(',
      '^\.borderRadius\('
    ))) {
      $issues += 'paused label must keep its opaque foreground and shared opaque background on its own Text chain.'
    }
  }

  $guideBlock = Get-ConditionalBlockContent $buildBlock 'this\.showGuide'
  if ($null -eq $guideBlock) {
    $issues += 'guide overlay must resolve to exactly one bounded conditional block.'
  } else {
    if ($guideBlock -match $legacyOverlayColorPattern) {
      $issues += 'guide overlay must not use a legacy translucent background.'
    }
    $guideSurfaceChain = Get-BoundedContainerChainContent $guideBlock '^\s*Column\s*\(\s*\)\s*\{' 'Column()'
    if ($null -eq $guideSurfaceChain -or -not (Test-BoundedControlChainContract $guideSurfaceChain @(
      '^Column\(\)'
    ) @(
      $sharedBackgroundPattern
    ))) {
      $issues += 'guide surface must use the shared opaque overlay background on its own Column chain.'
    }
    foreach ($guideText in @(
      @{ Label = 'tap instruction'; Pattern = "^Text\('\u5355\u51FB\uFF1A\u663E\u793A\u9000\u51FA\u6309\u94AE'\)" },
      @{ Label = 'double-tap instruction'; Pattern = "^Text\('\u53CC\u51FB\uFF1A\u6682\u505C/\u7EE7\u7EED\u52A8\u753B'\)" }
    )) {
      if (-not (Test-BoundedControlChainContract $guideBlock @($guideText.Pattern) @(
        $sharedForegroundPattern
      ))) {
        $issues += "guide $($guideText.Label) must use the opaque overlay foreground in the guide block."
      }
    }
  }

  $exitBlock = Get-ConditionalBlockContent $buildBlock 'this\.showExitBtn'
  if ($null -eq $exitBlock) {
    $issues += 'exit overlay must resolve to exactly one bounded conditional block.'
  } else {
    if ($exitBlock -match $legacyOverlayColorPattern) {
      $issues += 'exit overlay must not use a legacy translucent background.'
    }
    if (-not (Test-BoundedControlChainContract $exitBlock @("^Text\('\u00D7'\)") @(
      $sharedForegroundPattern,
      $sharedBackgroundPattern
    ))) {
      $issues += 'exit glyph must keep its opaque foreground and shared opaque background on its own Text chain.'
    }
  }

  return $issues
}

function Assert-DisplayOverlayContract {
  param(
    [string]$Content,
    [string]$RelativePath
  )

  foreach ($issue in @(Get-DisplayOverlayContractIssues $Content)) {
    $failures.Add("$RelativePath $issue")
  }
}

function ConvertTo-FlexibleExpressionPattern {
  param([string]$Expression)

  $tokens = [regex]::Split($Expression.Trim(), '\s+')
  return ($tokens | ForEach-Object { [regex]::Escape($_) }) -join '\s*'
}

function Test-SelectedControlContract {
  param(
    [string]$Content,
    [string]$SelectorExpression,
    [string]$SelectedBackground,
    [string]$UnselectedForeground,
    [string]$UnselectedBackground
  )

  $selectorPattern = ConvertTo-FlexibleExpressionPattern $SelectorExpression
  $chains = @(Get-ComponentModifierChains $Content 'selected-control-contract.ets')
  $matchingChains = @(Get-ChainsMatching $chains @($selectorPattern, '\.fontColor\(', '\.backgroundColor\('))
  if ($matchingChains.Count -ne 1) {
    return $false
  }

  $fontPattern = '^\.fontColor\(\s*' + $selectorPattern + '\s*\?\s*AppTheme\.ON_ACCENT\s*:\s*' +
    [regex]::Escape($UnselectedForeground) + '\s*\)$'
  $backgroundPattern = '^\.backgroundColor\(\s*' + $selectorPattern + '\s*\?\s*' +
    [regex]::Escape($SelectedBackground) + '\s*:\s*' + [regex]::Escape($UnselectedBackground) + '\s*\)$'
  return (Test-ChainHasStatement $matchingChains[0] $fontPattern) -and
    (Test-ChainHasStatement $matchingChains[0] $backgroundPattern)
}

function Assert-SelectedControlContract {
  param(
    [string]$Content,
    [string]$RelativePath,
    [string]$Control,
    [string]$SelectorExpression,
    [string]$SelectedBackground,
    [string]$UnselectedForeground,
    [string]$UnselectedBackground
  )

  $contract = @{
    Content = $Content
    SelectorExpression = $SelectorExpression
    SelectedBackground = $SelectedBackground
    UnselectedForeground = $UnselectedForeground
    UnselectedBackground = $UnselectedBackground
  }
  if (-not (Test-SelectedControlContract @contract)) {
    $failures.Add("$RelativePath $Control must keep its selected foreground and background on one control chain.")
  }
}

function Get-ModifierExpression {
  param(
    [string]$Statement,
    [string]$ModifierName
  )

  $pattern = '(?s)^\.' + [regex]::Escape($ModifierName) + '\(\s*(?<expression>.*?)\s*\)$'
  $match = [regex]::Match($Statement, $pattern)
  if (-not $match.Success) {
    return $null
  }
  return $match.Groups['expression'].Value.Trim()
}

function Get-SimpleTernaryExpression {
  param([string]$Expression)

  $quote = 0
  $escaped = $false
  $delimiterDepth = 0
  $questionIndex = -1
  $colonIndex = -1
  for ($index = 0; $index -lt $Expression.Length; $index++) {
    $characterCode = [int]$Expression[$index]
    if ($quote -ne 0) {
      if ($escaped) {
        $escaped = $false
      } elseif ($characterCode -eq 92) {
        $escaped = $true
      } elseif ($characterCode -eq $quote) {
        $quote = 0
      }
      continue
    }

    if ($characterCode -eq 39 -or $characterCode -eq 34 -or $characterCode -eq 96) {
      $quote = $characterCode
      continue
    }
    if ($characterCode -eq 40 -or $characterCode -eq 91 -or $characterCode -eq 123) {
      $delimiterDepth++
      continue
    }
    if ($characterCode -eq 41 -or $characterCode -eq 93 -or $characterCode -eq 125) {
      $delimiterDepth--
      continue
    }
    if ($delimiterDepth -ne 0) {
      continue
    }

    if ($characterCode -eq 63) {
      if ($questionIndex -ge 0) {
        return $null
      }
      $questionIndex = $index
    } elseif ($characterCode -eq 58) {
      if ($questionIndex -lt 0 -or $colonIndex -ge 0) {
        return $null
      }
      $colonIndex = $index
    }
  }
  if ($questionIndex -lt 1 -or $colonIndex -le $questionIndex + 1 -or $colonIndex -ge $Expression.Length - 1) {
    return $null
  }

  return [PSCustomObject]@{
    Condition = (($Expression.Substring(0, $questionIndex).Trim()) -replace '\s+', ' ')
    TrueValue = $Expression.Substring($questionIndex + 1, $colonIndex - $questionIndex - 1).Trim()
    FalseValue = $Expression.Substring($colonIndex + 1).Trim()
  }
}

function Test-WhiteCanCoincideWithBrightBackground {
  param(
    [string]$ForegroundStatement,
    [string]$BackgroundStatement,
    [string]$BrightPattern
  )

  $foregroundExpression = Get-ModifierExpression $ForegroundStatement 'fontColor'
  $backgroundExpression = Get-ModifierExpression $BackgroundStatement 'backgroundColor'
  if ($null -ne $foregroundExpression -and $null -ne $backgroundExpression) {
    $foregroundTernary = Get-SimpleTernaryExpression $foregroundExpression
    $backgroundTernary = Get-SimpleTernaryExpression $backgroundExpression
    if ($null -ne $foregroundTernary -and $null -ne $backgroundTernary -and
        $foregroundTernary.Condition -eq $backgroundTernary.Condition) {
      $whitePattern = '(?i)^["'']#FFFFFF["'']$'
      return (($foregroundTernary.TrueValue -match $whitePattern) -and
          ($backgroundTernary.TrueValue -match $BrightPattern)) -or
        (($foregroundTernary.FalseValue -match $whitePattern) -and
          ($backgroundTernary.FalseValue -match $BrightPattern))
    }
  }

  return $ForegroundStatement -match '(?is)["'']#FFFFFF["'']' -and
    $BackgroundStatement -match $BrightPattern
}

function Get-WhiteOnBrightViolations {
  param([string]$Content, [string]$RelativePath)

  $brightColors = @(
    @{ Label = 'AppTheme.ACCENT'; Pattern = 'AppTheme\.ACCENT\b' },
    @{ Label = 'AppTheme.ACCENT_BLUE'; Pattern = 'AppTheme\.ACCENT_BLUE\b' },
    @{ Label = 'AppTheme.DANGER'; Pattern = 'AppTheme\.DANGER\b' },
    @{ Label = 'AppTheme.SUCCESS'; Pattern = 'AppTheme\.SUCCESS\b' },
    @{ Label = '#05BDEB'; Pattern = '(?i)[\"'']#05BDEB[\"'']' },
    @{ Label = '#05BFE7'; Pattern = '(?i)[\"'']#05BFE7[\"'']' },
    @{ Label = '#04BCEB'; Pattern = '(?i)[\"'']#04BCEB[\"'']' }
  )
  $violations = @()
  $chains = @(Get-ComponentModifierChains $Content $RelativePath)
  foreach ($chain in $chains) {
    $foregroundStatement = $null
    foreach ($statement in $chain.Statements) {
      if ($statement -match '(?is)^\.fontColor\(.*[\"'']#FFFFFF[\"''].*\)$') {
        $foregroundStatement = $statement
        break
      }
    }
    if ($null -eq $foregroundStatement) {
      continue
    }

    $chainViolationFound = $false
    foreach ($statement in $chain.Statements) {
      if ($statement -notmatch '(?s)^\.(?:backgroundColor|linearGradient)\(') {
        continue
      }
      foreach ($brightColor in $brightColors) {
        if (Test-WhiteCanCoincideWithBrightBackground `
            $foregroundStatement `
            $statement `
            $brightColor.Pattern) {
          $violations += (
            "$RelativePath`:$($chain.Line) $($chain.Component) uses #FFFFFF with $($brightColor.Label) on one control chain."
          )
          $chainViolationFound = $true
          break
        }
      }
      if ($chainViolationFound) {
        break
      }
    }
  }
  return $violations
}

function Assert-AccessibilityContractSelfTests {
  $newWhiteOnBrightControlTemplate = @'
@Builder
buildFutureControl() {
  Button('Future action')
    .fontColor('#FFFFFF')
    .backgroundColor(BRIGHT_BACKGROUND)
}
'@
  foreach ($brightBackground in @(
    'AppTheme.ACCENT',
    'AppTheme.ACCENT_BLUE',
    'AppTheme.DANGER',
    'AppTheme.SUCCESS',
    "'#05BDEB'",
    "'#05BFE7'",
    "'#04BCEB'"
  )) {
    $newWhiteOnBrightControl = $newWhiteOnBrightControlTemplate.Replace('BRIGHT_BACKGROUND', $brightBackground)
    $newControlViolations = @(Get-WhiteOnBrightViolations $newWhiteOnBrightControl 'mutation-new-control.ets')
    if ($newControlViolations.Count -ne 1) {
      $failures.Add(
        "Accessibility contract self-test did not reject a newly introduced #FFFFFF control on $brightBackground."
      )
    }
  }

  $newWhiteOnBrightGradient = @'
@Builder
buildFutureGradientControl() {
  Button('Future gradient action')
    .fontColor('#FFFFFF')
    .linearGradient({ angle: 90, colors: [[AppTheme.ACCENT, 0.0], [AppTheme.ACCENT_BLUE, 1.0]] })
}
'@
  $gradientViolations = @(Get-WhiteOnBrightViolations $newWhiteOnBrightGradient 'mutation-new-gradient.ets')
  if ($gradientViolations.Count -ne 1) {
    $failures.Add('Accessibility contract self-test did not reject a newly introduced white-on-bright gradient button.')
  }

  $multilineComponentDeclaration = @'
@Builder
buildMultilineControl() {
  Button(
    'Multiline action'
  )
    .fontColor('#FFFFFF')
    .backgroundColor(AppTheme.ACCENT)
}
'@
  $multilineViolations = @(
    Get-WhiteOnBrightViolations $multilineComponentDeclaration 'mutation-multiline-component.ets'
  )
  if ($multilineViolations.Count -ne 1) {
    $failures.Add('Accessibility contract self-test missed a multiline component declaration.')
  }

  $spacedModifierChain = @'
@Builder
buildSpacedControl() {
  Button('Spaced action')

    // Keep the foreground attached to this button.
    .fontColor('#FFFFFF')

    // Keep the background attached to the same button.
    .backgroundColor(AppTheme.ACCENT)
}
'@
  $spacedViolations = @(Get-WhiteOnBrightViolations $spacedModifierChain 'mutation-spaced-modifiers.ets')
  if ($spacedViolations.Count -ne 1) {
    $failures.Add('Accessibility contract self-test missed a spaced or commented modifier chain.')
  }

  $inlineCommentModifierChain = @'
@Builder
buildInlineCommentControl() {
  Button('Inline comment action')
    .fontColor('#FFFFFF') // Keep this comment outside the modifier call.
    .backgroundColor(AppTheme.ACCENT)
}
'@
  $inlineCommentViolations = @(
    Get-WhiteOnBrightViolations $inlineCommentModifierChain 'mutation-inline-comment.ets'
  )
  if ($inlineCommentViolations.Count -ne 1) {
    $failures.Add('Accessibility contract self-test missed an inline comment after a modifier.')
  }

  $blockCommentModifierChain = @'
@Builder
buildBlockCommentControl() {
  Button('Block comment action')
    .fontColor('#FFFFFF')
    /* Keep the modifier chain attached across this block comment. */
    .backgroundColor(AppTheme.ACCENT)
}
'@
  $blockCommentViolations = @(
    Get-WhiteOnBrightViolations $blockCommentModifierChain 'mutation-block-comment.ets'
  )
  if ($blockCommentViolations.Count -ne 1) {
    $failures.Add('Accessibility contract self-test missed a block comment between modifiers.')
  }

  $mutuallyExclusiveColors = @'
@Builder
buildMutuallyExclusiveControl() {
  Button('Safe conditional action')
    .fontColor(this.isSelected ? '#FFFFFF' : AppTheme.ON_ACCENT)
    .backgroundColor(this.isSelected ? AppTheme.PAGE_BG : AppTheme.ACCENT)
}
'@
  $mutuallyExclusiveViolations = @(
    Get-WhiteOnBrightViolations $mutuallyExclusiveColors 'mutation-mutually-exclusive-colors.ets'
  )
  if ($mutuallyExclusiveViolations.Count -ne 0) {
    $failures.Add('Accessibility contract self-test falsely rejected mutually exclusive safe ternary color branches.')
  }

  $adjacentControls = @'
@Builder
buildAdjacentControls() {
  Button('White on dark')
    .fontColor('#FFFFFF')
    .backgroundColor(AppTheme.PAGE_BG)
  Button('Dark on bright')
    .fontColor(AppTheme.ON_ACCENT)
    .backgroundColor(AppTheme.SUCCESS)
}
'@
  $adjacentViolations = @(Get-WhiteOnBrightViolations $adjacentControls 'mutation-adjacent-controls.ets')
  if ($adjacentViolations.Count -ne 0) {
    $failures.Add('Accessibility contract self-test paired foreground and background from adjacent controls.')
  }

  $changedSelectedBackground = @'
@Builder
buildSelectedControl() {
  Text(item.label)
    .fontColor(this.selectedModeIndex === index ? AppTheme.ON_ACCENT : AppTheme.TEXT_PRIMARY)
    .backgroundColor(this.selectedModeIndex === index ? '#123456' : AppTheme.SURFACE_SOFT)
}
'@
  $selectedContract = @{
    Content = $changedSelectedBackground
    SelectorExpression = 'this.selectedModeIndex === index'
    SelectedBackground = "'#04BCEB'"
    UnselectedForeground = 'AppTheme.TEXT_PRIMARY'
    UnselectedBackground = 'AppTheme.SURFACE_SOFT'
  }
  $changedBackgroundPassed = Test-SelectedControlContract @selectedContract
  if ($changedBackgroundPassed) {
    $failures.Add('Accessibility contract self-test did not reject an independently changed selected background.')
  }

  $selectedContract.Content = $changedSelectedBackground.Replace("'#123456'", "'#04BCEB'")
  if (-not (Test-SelectedControlContract @selectedContract)) {
    $failures.Add('Accessibility contract self-test rejected a valid same-control selected color pair.')
  }

  $boundedOverlayChains = @'
if (this.firstOverlay) {
  Text('first')
    .fontColor(AppTheme.DISPLAY_OVERLAY_FG)
    .backgroundColor(AppTheme.DISPLAY_OVERLAY_BG)
}
if (this.secondOverlay) {
  Text('second')
    .fontColor(AppTheme.DISPLAY_OVERLAY_FG)
    .backgroundColor(AppTheme.DISPLAY_OVERLAY_BG)
}
'@
  $firstOverlayBlock = Get-ConditionalBlockContent $boundedOverlayChains 'this\.firstOverlay'
  if ($null -eq $firstOverlayBlock -or -not (Test-BoundedControlChainContract $firstOverlayBlock @(
    "^Text\('first'\)"
  ) @(
    '^\.backgroundColor\(\s*AppTheme\.DISPLAY_OVERLAY_BG\s*\)$'
  ))) {
    $failures.Add('Accessibility contract self-test rejected a valid bounded overlay chain.')
  }

  $misboundOverlayChains = @'
if (this.firstOverlay) {
  Text('first')
    .fontColor(AppTheme.DISPLAY_OVERLAY_FG)
}
if (this.secondOverlay) {
  Text('second')
    .fontColor(AppTheme.DISPLAY_OVERLAY_FG)
    .backgroundColor(AppTheme.DISPLAY_OVERLAY_BG)
}
'@
  $misboundFirstBlock = Get-ConditionalBlockContent $misboundOverlayChains 'this\.firstOverlay'
  if ($null -eq $misboundFirstBlock -or (Test-BoundedControlChainContract $misboundFirstBlock @(
    "^Text\('first'\)"
  ) @(
    '^\.backgroundColor\(\s*AppTheme\.DISPLAY_OVERLAY_BG\s*\)$'
  ))) {
    $failures.Add('Accessibility contract self-test allowed a neighboring overlay to satisfy a bounded chain.')
  }
}

Assert-AccessibilityContractSelfTests

if (-not (Test-Path -LiteralPath $themePath)) {
  $failures.Add('Missing file: entry/src/main/ets/common/Theme.ets')
  $themeColors = @{}
} else {
  $themeColors = Get-ThemeColors $themePath
}

Assert-Contrast $themeColors 'TEXT_PRIMARY' 'PAGE_BG' 4.5
Assert-Contrast $themeColors 'TEXT_SECONDARY' 'SURFACE_RAISED' 4.5
Assert-Contrast $themeColors 'TEXT_MUTED' 'SURFACE_RAISED' 4.5
Assert-Contrast $themeColors 'ON_ACCENT' 'ACCENT' 4.5
Assert-Contrast $themeColors 'ON_ACCENT' 'ACCENT_BLUE' 4.5
Assert-Contrast $themeColors 'ON_ACCENT' 'DANGER' 4.5
Assert-Contrast $themeColors 'ON_ACCENT' 'SUCCESS' 4.5
Assert-Contrast $themeColors 'DISPLAY_OVERLAY_FG' 'DISPLAY_OVERLAY_BG' 4.5
Assert-Contrast $themeColors 'TOGGLE_OFF_TRACK' 'SETTING_PANEL_BG' 3.0
Assert-Contrast $themeColors 'TOGGLE_THUMB' 'TOGGLE_OFF_TRACK' 3.0
Assert-Contrast $themeColors 'TOGGLE_THUMB' 'ACCENT' 3.0
Assert-Contrast $themeColors 'LED_MATRIX_DOT_COLOR' 'PAGE_BG' 4.5

$ledPanelPath = 'entry/src/main/ets/components/LedPanel.ets'
$ledPanelContent = Get-SourceContent $ledPanelPath
if (-not $ledPanelContent.Contains('.fontColor(AppTheme.LED_MATRIX_DOT_COLOR)')) {
  $failures.Add("$ledPanelPath dot-matrix text must use the accessible shared LED_MATRIX_DOT_COLOR token.")
}
$themeContent = Get-Content -Encoding UTF8 -Raw -LiteralPath $themePath
$dotOpacityMatch = [regex]::Match($themeContent, 'LED_MATRIX_DOT_OPACITY: number = ([0-9.]+)')
if (-not $dotOpacityMatch.Success -or [double]$dotOpacityMatch.Groups[1].Value -lt 0.85) {
  $failures.Add('Theme.ets LED_MATRIX_DOT_OPACITY must be at least 0.85 so the 10fp dot text remains readable after compositing.')
} elseif (-not $ledPanelContent.Contains('.opacity(AppTheme.LED_MATRIX_DOT_OPACITY)')) {
  $failures.Add("$ledPanelPath dot-matrix text must use the shared LED_MATRIX_DOT_OPACITY token.")
}

$counterPath = 'entry/src/main/ets/pages/CounterPage.ets'
$counterDotContent = Get-SourceContent $counterPath
if (-not $counterDotContent.Contains('.fontColor(AppTheme.LED_MATRIX_DOT_COLOR)') -or
    -not $counterDotContent.Contains('.opacity(AppTheme.LED_MATRIX_DOT_OPACITY)')) {
  $failures.Add("$counterPath counter dot-matrix text must use the same accessible color and opacity tokens.")
}

$displayPath = 'entry/src/main/ets/pages/DisplayPage.ets'
$displayContent = Get-SourceContent $displayPath
Assert-DisplayOverlayContract $displayContent $displayPath

$indexPath = 'entry/src/main/ets/pages/Index.ets'
$indexContent = Get-SourceContent $indexPath
$indexToggleContract = @{
  Content = $indexContent
  RelativePath = $indexPath
  Control = 'settings switch'
  IdentityPatterns = @('(?m)^Toggle\(')
  RequiredStatementPatterns = @(
    '^\.selectedColor\(\s*AppTheme\.ACCENT\s*\)$',
    '(?s)^\.switchStyle\(\s*\{\s*unselectedColor:\s*AppTheme\.TOGGLE_OFF_TRACK,\s*pointColor:\s*AppTheme\.TOGGLE_THUMB\s*\}\s*\)$'
  )
}
Assert-ControlChainContract @indexToggleContract
$indexSelectedContract = @{
  Content = $indexContent
  RelativePath = $indexPath
  Control = 'selected mode'
  SelectorExpression = 'this.selectedModeIndex === index'
  SelectedBackground = "'#04BCEB'"
  UnselectedForeground = 'AppTheme.TEXT_PRIMARY'
  UnselectedBackground = 'AppTheme.SURFACE_SOFT'
}
Assert-SelectedControlContract @indexSelectedContract
$indexStartContract = @{
  Content = $indexContent
  RelativePath = $indexPath
  Control = 'start button'
  IdentityPatterns = @('(?s)\.onClick\(.*this\.startDisplay\(\)')
  RequiredStatementPatterns = @(
    '^\.fontColor\(\s*AppTheme\.ON_ACCENT\s*\)$',
    '(?s)^\.linearGradient\(.*AppTheme\.ACCENT\b.*AppTheme\.ACCENT_BLUE\b.*\)$'
  )
}
Assert-ControlChainContract @indexStartContract

$templatePath = 'entry/src/main/ets/pages/TemplatePage.ets'
$templateContent = Get-SourceContent $templatePath
$templateSelectedContract = @{
  Content = $templateContent
  RelativePath = $templatePath
  Control = 'selected category'
  SelectorExpression = 'this.selectedCategory === category'
  SelectedBackground = "'#05BDEB'"
  UnselectedForeground = 'AppTheme.TEXT_SECONDARY'
  UnselectedBackground = 'AppTheme.SURFACE_SOFT'
}
Assert-SelectedControlContract @templateSelectedContract
$templateStartContract = @{
  Content = $templateContent
  RelativePath = $templatePath
  Control = 'start button'
  IdentityPatterns = @('(?s)\.onClick\(.*this\.confirmTemplate\(\)')
  RequiredStatementPatterns = @(
    '^\.fontColor\(\s*AppTheme\.ON_ACCENT\s*\)$',
    '^\.backgroundColor\(\s*AppTheme\.ACCENT_BLUE\s*\)$'
  )
}
Assert-ControlChainContract @templateStartContract

$colorPath = 'entry/src/main/ets/pages/ColorPickerPage.ets'
$colorContent = Get-SourceContent $colorPath
$colorConfirmContract = @{
  Content = $colorContent
  RelativePath = $colorPath
  Control = 'confirm button'
  IdentityPatterns = @(
    '(?m)^Button\(',
    '(?m)^\.enabled\(\s*!this\.isSaving\s*\)$',
    '(?m)^\.linearGradient\('
  )
  RequiredStatementPatterns = @(
    '^\.fontColor\(\s*AppTheme\.ON_ACCENT\s*\)$',
    '^\.backgroundColor\(\s*AppTheme\.ACCENT\s*\)$',
    '(?s)^\.linearGradient\(.*AppTheme\.ACCENT\b.*AppTheme\.ACCENT_BLUE\b.*\)$'
  )
}
Assert-ControlChainContract @colorConfirmContract

$counterPath = 'entry/src/main/ets/pages/CounterPage.ets'
$counterContent = Get-SourceContent $counterPath
$counterButtonContract = @{
  Content = $counterContent
  RelativePath = $counterPath
  Control = 'increment/decrement button builder'
  IdentityPatterns = @('(?m)^Button\(\s*label\s*\)$')
  RequiredStatementPatterns = @(
    '^\.fontColor\(\s*AppTheme\.ON_ACCENT\s*\)$',
    '^\.backgroundColor\(\s*color\s*\)$'
  )
}
Assert-ControlChainContract @counterButtonContract
foreach ($counterAction in @(
  @{ Label = 'decrement button'; Pattern = '(?m)^\s*this\.buildCounterButton\(\s*[^,\r\n]+,\s*AppTheme\.DANGER\b' },
  @{ Label = 'increment button'; Pattern = '(?m)^\s*this\.buildCounterButton\(\s*[^,\r\n]+,\s*AppTheme\.SUCCESS\b' }
)) {
  if ($counterContent -notmatch $counterAction.Pattern) {
    $failures.Add("$counterPath $($counterAction.Label) must use the shared accessible counter button builder.")
  }
}

$sourceRoot = Join-Path $projectRoot 'entry/src/main/ets'
foreach ($sourceFile in Get-ChildItem -LiteralPath $sourceRoot -Filter '*.ets' -File -Recurse) {
  $relativePath = $sourceFile.FullName.Substring($projectRoot.Length + 1).Replace('\', '/')
  $sourceContent = Get-Content -Encoding UTF8 -Raw -LiteralPath $sourceFile.FullName
  foreach ($violation in @(Get-WhiteOnBrightViolations $sourceContent $relativePath)) {
    $failures.Add($violation)
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "Accessibility contract failed with $($failures.Count) issue(s)."
}

Write-Host 'Accessibility contrast contract passed.' -ForegroundColor Green
