param([switch]$SelfTest)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]
$expectedName = -join [char[]](20809, 36857, 23383, 24149)
$clearText = -join [char[]](28165, 31354)

function Read-RequiredFile {
  param([string]$RelativePath)

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    $failures.Add("Missing required file: $RelativePath")
    return ''
  }

  return Get-Content -Encoding UTF8 -Raw -LiteralPath $path
}

function Remove-SourceComments {
  param(
    [string]$Content,
    [switch]$MaskLiterals
  )

  $clean = New-Object System.Text.StringBuilder
  $mode = 'Code'
  $escaped = $false

  for ($index = 0; $index -lt $Content.Length; $index++) {
    $character = $Content[$index]
    $nextCharacter = if ($index + 1 -lt $Content.Length) { $Content[$index + 1] } else { [char]0 }

    if ($mode -eq 'LineComment') {
      if ($character -eq "`r" -or $character -eq "`n") {
        [void]$clean.Append($character)
        $mode = 'Code'
      } else {
        [void]$clean.Append(' ')
      }
      continue
    }
    if ($mode -eq 'BlockComment') {
      if ($character -eq '*' -and $nextCharacter -eq '/') {
        [void]$clean.Append('  ')
        $index++
        $mode = 'Code'
      } elseif ($character -eq "`r" -or $character -eq "`n") {
        [void]$clean.Append($character)
      } else {
        [void]$clean.Append(' ')
      }
      continue
    }
    if ($mode -eq 'Code' -and $character -eq '/' -and $nextCharacter -eq '/') {
      [void]$clean.Append('  ')
      $index++
      $mode = 'LineComment'
      continue
    }
    if ($mode -eq 'Code' -and $character -eq '/' -and $nextCharacter -eq '*') {
      [void]$clean.Append('  ')
      $index++
      $mode = 'BlockComment'
      continue
    }

    if ($MaskLiterals -and $mode -in @('SingleQuote', 'DoubleQuote', 'TemplateLiteral')) {
      if ($character -eq "`r" -or $character -eq "`n") {
        [void]$clean.Append($character)
      } else {
        [void]$clean.Append(' ')
      }
    } else {
      [void]$clean.Append($character)
    }
    if ($mode -eq 'Code' -and $character -eq "'") {
      $mode = 'SingleQuote'
      $escaped = $false
      if ($MaskLiterals) { $clean[$clean.Length - 1] = ' ' }
    } elseif ($mode -eq 'Code' -and $character -eq '"') {
      $mode = 'DoubleQuote'
      $escaped = $false
      if ($MaskLiterals) { $clean[$clean.Length - 1] = ' ' }
    } elseif ($mode -eq 'Code' -and $character -eq '`') {
      $mode = 'TemplateLiteral'
      $escaped = $false
      if ($MaskLiterals) { $clean[$clean.Length - 1] = ' ' }
    } elseif ($mode -eq 'SingleQuote' -and -not $escaped -and $character -eq "'") {
      $mode = 'Code'
    } elseif ($mode -eq 'DoubleQuote' -and -not $escaped -and $character -eq '"') {
      $mode = 'Code'
    } elseif ($mode -eq 'TemplateLiteral' -and -not $escaped -and $character -eq '`') {
      $mode = 'Code'
    }

    if ($mode -in @('SingleQuote', 'DoubleQuote', 'TemplateLiteral')) {
      $escaped = (-not $escaped -and $character -eq [char]92)
    }
  }

  return $clean.ToString()
}

function Find-MatchingDelimiter {
  param([string]$Content, [int]$OpenIndex, [char]$OpenCharacter, [char]$CloseCharacter)

  $depth = 0
  $inSingleQuote = $false
  $inDoubleQuote = $false
  $inLineComment = $false
  $inBlockComment = $false
  $escaped = $false

  for ($index = $OpenIndex; $index -lt $Content.Length; $index++) {
    $character = $Content[$index]
    $nextCharacter = if ($index + 1 -lt $Content.Length) { $Content[$index + 1] } else { [char]0 }

    if ($inLineComment) {
      if ($character -eq "`n") { $inLineComment = $false }
      continue
    }
    if ($inBlockComment) {
      if ($character -eq '*' -and $nextCharacter -eq '/') {
        $inBlockComment = $false
        $index++
      }
      continue
    }
    if ($inSingleQuote) {
      if (-not $escaped -and $character -eq "'") { $inSingleQuote = $false }
      $escaped = (-not $escaped -and $character -eq [char]92)
      continue
    }
    if ($inDoubleQuote) {
      if (-not $escaped -and $character -eq '"') { $inDoubleQuote = $false }
      $escaped = (-not $escaped -and $character -eq [char]92)
      continue
    }
    if ($character -eq '/' -and $nextCharacter -eq '/') {
      $inLineComment = $true
      $index++
      continue
    }
    if ($character -eq '/' -and $nextCharacter -eq '*') {
      $inBlockComment = $true
      $index++
      continue
    }
    if ($character -eq "'") {
      $inSingleQuote = $true
      $escaped = $false
      continue
    }
    if ($character -eq '"') {
      $inDoubleQuote = $true
      $escaped = $false
      continue
    }
    if ($character -eq $OpenCharacter) { $depth++ }
    if ($character -eq $CloseCharacter) {
      $depth--
      if ($depth -eq 0) { return $index }
    }
  }

  return -1
}

function Skip-Whitespace {
  param([string]$Content, [int]$StartIndex)

  $index = $StartIndex
  while ($index -lt $Content.Length) {
    if ([char]::IsWhiteSpace($Content[$index])) {
      $index++
      continue
    }
    break
  }
  return $index
}

function Get-HistoryHeaderBranches {
  param([string]$Content)

  $condition = [regex]::Match($Content, 'if\s*\(\s*this\.records\.length\s*>\s*0\s*\)')
  if (-not $condition.Success) { return $null }
  $thenOpen = $Content.IndexOf('{', $condition.Index + $condition.Length)
  if ($thenOpen -lt 0) { return $null }
  $thenClose = Find-MatchingDelimiter $Content $thenOpen '{' '}'
  if ($thenClose -lt 0) { return $null }

  $elseStart = Skip-Whitespace $Content ($thenClose + 1)
  $elseMatch = [regex]::Match($Content.Substring($elseStart), '^else\b')
  if (-not $elseMatch.Success) { return $null }
  $elseOpen = Skip-Whitespace $Content ($elseStart + $elseMatch.Length)
  if ($elseOpen -ge $Content.Length -or $Content[$elseOpen] -ne '{') { return $null }
  $elseClose = Find-MatchingDelimiter $Content $elseOpen '{' '}'
  if ($elseClose -lt 0) { return $null }

  return [PSCustomObject]@{
    Then = $Content.Substring($thenOpen + 1, $thenClose - $thenOpen - 1)
    Else = $Content.Substring($elseOpen + 1, $elseClose - $elseOpen - 1)
    ThenStart = $thenOpen + 1
    ThenEnd = $thenClose
    ElseStart = $elseOpen + 1
    ElseEnd = $elseClose
  }
}

function Get-TextModifierChain {
  param([string]$Source, [string]$CodeMask, [string]$Text)

  foreach ($textMatch in [regex]::Matches($CodeMask, '\bText\s*\(')) {
    $openParenthesis = $CodeMask.IndexOf('(', $textMatch.Index)
    $argumentStart = Skip-Whitespace $Source ($openParenthesis + 1)
    if ($argumentStart -ge $Source.Length -or $Source[$argumentStart] -ne "'") { continue }
    $argumentEnd = $Source.IndexOf("'", $argumentStart + 1)
    if ($argumentEnd -lt 0 -or $Source.Substring($argumentStart + 1, $argumentEnd - $argumentStart - 1) -cne $Text) { continue }

    $textEnd = Find-MatchingDelimiter $CodeMask $openParenthesis '(' ')'
    if ($textEnd -lt 0) { return '' }
    $position = $textEnd + 1
    while ($position -lt $CodeMask.Length) {
      $position = Skip-Whitespace $CodeMask $position
      if ($position -ge $CodeMask.Length -or $CodeMask[$position] -ne '.') { break }
      $modifier = [regex]::Match($CodeMask.Substring($position), '^\.[A-Za-z_][A-Za-z0-9_]*\s*\(')
      if (-not $modifier.Success) { break }
      $modifierOpen = $position + $modifier.Value.LastIndexOf('(')
      $modifierClose = Find-MatchingDelimiter $CodeMask $modifierOpen '(' ')'
      if ($modifierClose -lt 0) { return '' }
      $position = $modifierClose + 1
    }
    return $CodeMask.Substring($textMatch.Index, $position - $textMatch.Index)
  }

  return ''
}

function Get-ArkUiTextLiteralValues {
  param([string]$Source)

  $codeMask = Remove-SourceComments $Source -MaskLiterals
  $values = New-Object System.Collections.Generic.List[string]
  foreach ($textMatch in [regex]::Matches($codeMask, '\bText\s*\(')) {
    $openParenthesis = $codeMask.IndexOf('(', $textMatch.Index)
    $valueStart = Skip-Whitespace $Source ($openParenthesis + 1)
    if ($valueStart -ge $Source.Length -or $Source[$valueStart] -ne "'") { continue }
    $valueEnd = $Source.IndexOf("'", $valueStart + 1)
    if ($valueEnd -lt 0) { continue }
    $values.Add($Source.Substring($valueStart + 1, $valueEnd - $valueStart - 1))
  }
  return $values
}

function Get-UniqueStringResourceValue {
  param([string]$Content, [string]$Name)

  try {
    $resource = $Content | ConvertFrom-Json
    $matches = @($resource.string | Where-Object { $_.name -ceq $Name })
    if ($matches.Count -ne 1) { return $null }
    return [string]$matches[0].value
  } catch {
    return $null
  }
}

function Test-ReleaseDocumentIdentity {
  param([string]$Content, [string]$Title)

  $effectiveDatePrefix = -join [char[]](29983, 25928, 26085, 26399, 65306)
  $withoutHtmlComments = [regex]::Replace($Content, '(?s)<!--.*?-->', '')
  $lines = @($withoutHtmlComments -split "`r?`n")
  $firstContentIndex = -1
  for ($index = 0; $index -lt $lines.Count; $index++) {
    if (-not [string]::IsNullOrWhiteSpace($lines[$index])) {
      $firstContentIndex = $index
      break
    }
  }
  if ($firstContentIndex -lt 0 -or $lines[$firstContentIndex].Trim() -cne "# $Title") {
    return $false
  }
  for ($index = $firstContentIndex + 1; $index -lt $lines.Count; $index++) {
    $line = $lines[$index].Trim()
    if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#') -or $line.StartsWith($effectiveDatePrefix)) { continue }
    return $line.Contains($expectedName)
  }
  return $false
}

function Get-HistoryClearControl {
  param([string]$Source, [string]$Text)

  $codeMask = Remove-SourceComments $Source -MaskLiterals
  $branches = Get-HistoryHeaderBranches $codeMask
  if ($null -eq $branches) { return $null }

  $thenLength = $branches.ThenEnd - $branches.ThenStart
  $thenSource = $Source.Substring($branches.ThenStart, $thenLength)
  $thenMask = $codeMask.Substring($branches.ThenStart, $thenLength)
  return [PSCustomObject]@{
    ClearChain = Get-TextModifierChain $thenSource $thenMask $Text
    ElseCode = $Source.Substring($branches.ElseStart, $branches.ElseEnd - $branches.ElseStart)
    ElseMask = $branches.Else
  }
}

function Get-HistoryClearControlFailures {
  param([object]$HistoryControl, [string]$Text)

  $result = New-Object System.Collections.Generic.List[string]
  if ($null -eq $HistoryControl) {
    $result.Add('HistoryPage.ets must conditionally construct the clear action when records.length > 0.')
    return $result
  }

  $clearChain = $HistoryControl.ClearChain
  if ([string]::IsNullOrWhiteSpace($clearChain) -or $clearChain -notmatch '\.onClick\(\(\)\s*=>\s*this\.clearAll\(\)\)') {
    $result.Add("HistoryPage.ets records branch must construct Text('$Text') with .onClick(() => this.clearAll()).")
  }
  if ($clearChain -notmatch '\.width\(48\)' -or $clearChain -notmatch '\.height\(48\)') {
    $result.Add("HistoryPage.ets records branch Text('$Text') must provide a 48x48 target with .width(48) and .height(48).")
  }
  if ($clearChain -match '\.opacity\(') {
    $result.Add("HistoryPage.ets Text('$Text') modifier chain must not contain .opacity().")
  }
  if ($HistoryControl.ElseMask -notmatch 'Blank\(\)\s*\.width\(48\)\s*\.height\(48\)') {
    $result.Add('HistoryPage.ets empty header branch must contain Blank().width(48).height(48).')
  }
  if (@(Get-ArkUiTextLiteralValues -Source $HistoryControl.ElseCode) -contains $Text) {
    $result.Add("HistoryPage.ets empty header branch must not construct Text('$Text').")
  }
  return $result
}

function Test-StoreIconWiring {
  param([string]$Source)

  $tokens = $null
  $parseErrors = $null
  $ast = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref]$tokens, [ref]$parseErrors)
  if ($parseErrors.Count -gt 0) {
    return [PSCustomObject]@{
      HasStoreIconPath = $false
      HasStoreIconFunction = $false
      HasStoreIconInvocation = $false
    }
  }

  $hasStoreIconPath = $false
  $hasStoreIconFunction = $false
  foreach ($statement in $ast.EndBlock.Statements) {
    if (($statement -is [System.Management.Automation.Language.FunctionDefinitionAst]) -and ($statement.Name -ceq 'New-StoreIcon')) {
      $hasStoreIconFunction = $true
    }
    if (($statement -is [System.Management.Automation.Language.AssignmentStatementAst]) -and
        ($statement.Operator -eq [System.Management.Automation.Language.TokenKind]::Equals) -and
        ($statement.Left -is [System.Management.Automation.Language.VariableExpressionAst]) -and
        ($statement.Left.VariablePath.UserPath -ceq 'storeIconPath')) {
      $hasStoreIconPath = $true
    }
  }
  $hasStoreIconInvocation = $false
  foreach ($statement in $ast.EndBlock.Statements) {
    if (($statement -isnot [System.Management.Automation.Language.PipelineAst]) -or ($statement.PipelineElements.Count -ne 1)) { continue }
    $command = $statement.PipelineElements[0]
    if (($command -isnot [System.Management.Automation.Language.CommandAst]) -or ($command.GetCommandName() -cne 'New-StoreIcon')) { continue }

    $parameters = @{}
    for ($index = 1; $index -lt $command.CommandElements.Count - 1; $index++) {
      $element = $command.CommandElements[$index]
      if ($element -isnot [System.Management.Automation.Language.CommandParameterAst]) { continue }
      $argument = $command.CommandElements[$index + 1]
      if ($argument -is [System.Management.Automation.Language.VariableExpressionAst]) {
        $parameters[$element.ParameterName] = $argument.VariablePath.UserPath
      }
    }
    if (($parameters['BackgroundPath'] -ceq 'appBackgroundPath') -and
        ($parameters['ForegroundPath'] -ceq 'appForegroundPath') -and
        ($parameters['OutputPath'] -ceq 'storeIconPath')) {
      $hasStoreIconInvocation = $true
      break
    }
  }

  return [PSCustomObject]@{
    HasStoreIconPath = $hasStoreIconPath
    HasStoreIconFunction = $hasStoreIconFunction
    HasStoreIconInvocation = $hasStoreIconInvocation
  }
}

function Test-ParserFixtures {
  $afterClickOpacity = "if (this.records.length > 0) {`n  Text('$clearText').onClick(() => this.clearAll()).opacity(0)`n} else {`n  Blank().width(48).height(48)`n}"
  $afterClickControl = Get-HistoryClearControl $afterClickOpacity $clearText
  if ($null -eq $afterClickControl -or $afterClickControl.ClearChain -notmatch '\.opacity\(') {
    throw 'Fixture failed: opacity after onClick was not retained in the Text modifier chain.'
  }

  $clearWithoutTargetSize = "if (this.records.length > 0) {`n  Text('$clearText').onClick(() => this.clearAll())`n} else {`n  Blank().width(48).height(48)`n}"
  $clearWithoutTargetSizeControl = Get-HistoryClearControl $clearWithoutTargetSize $clearText
  if (-not (Get-HistoryClearControlFailures $clearWithoutTargetSizeControl $clearText | Where-Object { $_ -match '48x48 target' })) {
    throw 'Fixture failed: records-branch clear Text without a 48x48 target was not rejected.'
  }

  $emptyBranchWithClearText = "if (this.records.length > 0) {`n  Text('$clearText').onClick(() => this.clearAll()).width(48).height(48)`n} else {`n  Text('$clearText')`n  Blank().width(48).height(48)`n}"
  $emptyBranchWithClearTextControl = Get-HistoryClearControl $emptyBranchWithClearText $clearText
  if (-not (Get-HistoryClearControlFailures $emptyBranchWithClearTextControl $clearText | Where-Object { $_ -match 'must not construct' })) {
    throw 'Fixture failed: empty branch clear Text was not rejected.'
  }

  $commentedElse = "if (this.records.length > 0) {`n  Text('$clearText').onClick(() => this.clearAll())`n} /* paired branch comment */ else {`n  Blank().width(48).height(48)`n}"
  $commentedElseControl = Get-HistoryClearControl $commentedElse $clearText
  if ($null -eq $commentedElseControl -or $commentedElseControl.ElseCode -notmatch 'Blank\(\)\s*\.width\(48\)\s*\.height\(48\)') {
    throw 'Fixture failed: paired else after a block comment was not recognized.'
  }

  $multilineBlank = "if (this.records.length > 0) {`n  Text('$clearText').onClick(() => this.clearAll())`n} else {`n  Blank()`n    .width(48)`n    .height(48)`n}"
  $multilineBlankControl = Get-HistoryClearControl $multilineBlank $clearText
  if ($null -eq $multilineBlankControl -or $multilineBlankControl.ElseCode -notmatch 'Blank\(\)\s*\.width\(48\)\s*\.height\(48\)') {
    throw 'Fixture failed: multiline Blank modifier chain was not recognized.'
  }

  $blockCommentOpacity = "Text('$clearText').onClick(() => this.clearAll()) /* modifier comment */ .opacity(0)"
  if ((Get-TextModifierChain $blockCommentOpacity (Remove-SourceComments $blockCommentOpacity -MaskLiterals) $clearText) -notmatch '\.opacity\(') {
    throw 'Fixture failed: block comment between modifiers hid opacity.'
  }

  $lineCommentOpacity = "Text('$clearText').onClick(() => this.clearAll()) // modifier comment`n  .opacity(0)"
  if ((Get-TextModifierChain $lineCommentOpacity (Remove-SourceComments $lineCommentOpacity -MaskLiterals) $clearText) -notmatch '\.opacity\(') {
    throw 'Fixture failed: line comment between modifiers hid opacity.'
  }

  $nextComponentOpacity = "Text('$clearText').onClick(() => this.clearAll())`nText('Other').opacity(0)"
  if ((Get-TextModifierChain $nextComponentOpacity (Remove-SourceComments $nextComponentOpacity -MaskLiterals) $clearText) -match '\.opacity\(') {
    throw 'Fixture failed: next component opacity was incorrectly retained in the clear Text chain.'
  }

  $unrelatedElse = "if (this.records.length > 0) {`n  Text('$clearText').onClick(() => this.clearAll())`n}`nelse {`n  Text('Other')`n}`nif (other) {`n  Text('Elsewhere')`n} else {`n  Blank().width(48).height(48)`n}"
  $unrelatedControl = Get-HistoryClearControl $unrelatedElse $clearText
  if ($null -eq $unrelatedControl -or $unrelatedControl.ElseMask -match 'Blank\(\)\s*\.width\(48\)\s*\.height\(48\)') {
    throw 'Fixture failed: unrelated else branch satisfied the clear-action empty branch.'
  }

  $commentedOpacity = "Text('$clearText').onClick(() => this.clearAll()) // .opacity(0)"
  if ((Get-TextModifierChain $commentedOpacity (Remove-SourceComments $commentedOpacity -MaskLiterals) $clearText) -match '\.opacity\(') {
    throw 'Fixture failed: comment-only opacity was retained in the Text modifier chain.'
  }

  $commentedOnClick = "Text('$clearText') // .onClick(() => this.clearAll())"
  if ((Get-TextModifierChain $commentedOnClick (Remove-SourceComments $commentedOnClick -MaskLiterals) $clearText) -match '\.onClick\(') {
    throw 'Fixture failed: comment-only onClick was retained in the Text modifier chain.'
  }

  $commentedText = "// Text('$clearText').onClick(() => this.clearAll())`nText('Other')"
  if (-not [string]::IsNullOrWhiteSpace((Get-TextModifierChain $commentedText (Remove-SourceComments $commentedText -MaskLiterals) $clearText))) {
    throw 'Fixture failed: comment-only clear Text was selected.'
  }

  $commentedBlank = "if (this.records.length > 0) {`n  Text('$clearText').onClick(() => this.clearAll())`n} else {`n  // Blank().width(48).height(48)`n  Text('Other')`n}"
  $commentedBlankControl = Get-HistoryClearControl $commentedBlank $clearText
  if ($commentedBlankControl.ElseMask -match 'Blank\(\)\s*\.width\(48\)\s*\.height\(48\)') {
    throw 'Fixture failed: comment-only Blank satisfied the empty branch.'
  }

  $stringFakeControl = "const fake = `"Text('$clearText').onClick(() => this.clearAll()).opacity(0)`"`nif (this.records.length > 0) {`n  Text('Other')`n} else {`n  Text('No placeholder')`n}"
  $stringFakeControlResult = Get-HistoryClearControl $stringFakeControl $clearText
  if ($null -eq $stringFakeControlResult -or -not [string]::IsNullOrWhiteSpace($stringFakeControlResult.ClearChain)) {
    throw 'Fixture failed: variable string pseudo Text satisfied the clear control assertion.'
  }
  if ($stringFakeControlResult.ElseMask -match 'Blank\(\)\s*\.width\(48\)\s*\.height\(48\)') {
    throw 'Fixture failed: variable string pseudo Blank satisfied the empty branch assertion.'
  }

  $literalMarkers = "Text('// text').fontColor('/* text */')`nconst template = ``// text /* text */``"
  $cleanLiteralMarkers = Remove-SourceComments $literalMarkers
  if (-not $cleanLiteralMarkers.Contains("'// text'") -or
      -not $cleanLiteralMarkers.Contains("'/* text */'") -or
      -not $cleanLiteralMarkers.Contains('`// text /* text */`')) {
    throw 'Fixture failed: comment-like text inside literals was removed.'
  }

  $identityJson = "{`"string`": [{`"name`": `"app_name`", `"value`": `"$expectedName`"}]}"
  if ((Get-UniqueStringResourceValue $identityJson 'app_name') -cne $expectedName -or $null -ne (Get-UniqueStringResourceValue $identityJson 'EntryAbility_label')) {
    throw 'Fixture failed: JSON identity field lookup accepted a missing or wrong field.'
  }

  $titleAccent = $expectedName.Substring(0, 2)
  $titlePrimary = $expectedName.Substring(2)
  $fakeTitleText = "// Text('$titleAccent')`nconst fake = `"Text('$titlePrimary')`"`nText('Other')"
  $fakeTitleValues = Get-ArkUiTextLiteralValues $fakeTitleText
  if ($fakeTitleValues.Contains($titleAccent) -or $fakeTitleValues.Contains($titlePrimary)) {
    throw 'Fixture failed: commented or string-only Index title Text was recognized.'
  }
  $realTitleValues = Get-ArkUiTextLiteralValues "Text('$titleAccent')`nText('$titlePrimary')"
  if (-not $realTitleValues.Contains($titleAccent) -or -not $realTitleValues.Contains($titlePrimary)) {
    throw 'Fixture failed: real Index title Text literals were not recognized.'
  }

  $policyTitle = $expectedName + (-join [char[]](38544, 31169, 25919, 31574))
  $welcomeName = (-join [char[]](27426, 36814, 20351, 29992)) + $expectedName
  $welcomeGeneric = -join [char[]](27426, 36814, 20351, 29992, 26412, 24212, 29992)
  $incompletePolicyTitle = $titleAccent + (-join [char[]](38544, 31169, 25919, 31574))
  if (-not (Test-ReleaseDocumentIdentity "# $policyTitle`n$welcomeName" $policyTitle) -or
      (Test-ReleaseDocumentIdentity "# $policyTitle`n$welcomeGeneric" $policyTitle) -or
      (Test-ReleaseDocumentIdentity "# $incompletePolicyTitle`n$welcomeName" $policyTitle)) {
    throw 'Fixture failed: release document identity accepted a missing title segment or missing first-paragraph name.'
  }

  $declarationOnly = "function New-StoreIcon {`n  param()`n  `$ignored = `$storeIconPath`n}"
  $declarationOnlyResult = Test-StoreIconWiring $declarationOnly
  if ($declarationOnlyResult.HasStoreIconPath -or -not $declarationOnlyResult.HasStoreIconFunction -or $declarationOnlyResult.HasStoreIconInvocation) {
    throw 'Fixture failed: function-body storeIconPath reference or declaration was treated as top-level wiring.'
  }

  $actualInvocation = "function New-StoreIcon {`n  param()`n}`n`$storeIconPath = 'target'`nNew-StoreIcon ```n  -BackgroundPath `$appBackgroundPath ```n  -ForegroundPath `$appForegroundPath ```n  -OutputPath `$storeIconPath"
  $actualInvocationResult = Test-StoreIconWiring $actualInvocation
  if (-not $actualInvocationResult.HasStoreIconPath -or -not $actualInvocationResult.HasStoreIconFunction -or -not $actualInvocationResult.HasStoreIconInvocation) {
    throw 'Fixture failed: actual New-StoreIcon invocation was not recognized.'
  }

  $wrapperInvocation = "function New-StoreIcon { param() }`nfunction Build-StoreIcon {`n  New-StoreIcon ```n    -BackgroundPath `$appBackgroundPath ```n    -ForegroundPath `$appForegroundPath ```n    -OutputPath `$storeIconPath`n}`n`$storeIconPath = 'target'"
  $wrapperInvocationResult = Test-StoreIconWiring $wrapperInvocation
  if (-not $wrapperInvocationResult.HasStoreIconPath -or -not $wrapperInvocationResult.HasStoreIconFunction -or $wrapperInvocationResult.HasStoreIconInvocation) {
    throw 'Fixture failed: uninvoked wrapper New-StoreIcon call was treated as a top-level invocation.'
  }

  $commentedInvocation = "# New-StoreIcon ```n#   -BackgroundPath `$appBackgroundPath ```n#   -ForegroundPath `$appForegroundPath ```n#   -OutputPath `$storeIconPath"
  $commentedInvocationResult = Test-StoreIconWiring $commentedInvocation
  if ($commentedInvocationResult.HasStoreIconPath -or $commentedInvocationResult.HasStoreIconFunction -or $commentedInvocationResult.HasStoreIconInvocation) {
    throw 'Fixture failed: comment-only New-StoreIcon invocation was recognized.'
  }

  $stringInvocation = '$fake = "New-StoreIcon -BackgroundPath $appBackgroundPath -ForegroundPath $appForegroundPath -OutputPath $storeIconPath"'
  $stringInvocationResult = Test-StoreIconWiring $stringInvocation
  if ($stringInvocationResult.HasStoreIconPath -or $stringInvocationResult.HasStoreIconFunction -or $stringInvocationResult.HasStoreIconInvocation) {
    throw 'Fixture failed: string-only New-StoreIcon invocation was recognized.'
  }

  $blockCommentedInvocation = "<#`n`$storeIconPath = 'fake'`nfunction New-StoreIcon {}`nNew-StoreIcon ```n  -BackgroundPath `$appBackgroundPath ```n  -ForegroundPath `$appForegroundPath ```n  -OutputPath `$storeIconPath`n#>"
  $blockCommentedInvocationResult = Test-StoreIconWiring $blockCommentedInvocation
  if ($blockCommentedInvocationResult.HasStoreIconPath -or $blockCommentedInvocationResult.HasStoreIconFunction -or $blockCommentedInvocationResult.HasStoreIconInvocation) {
    throw 'Fixture failed: PowerShell block comment satisfied the store-icon wiring assertion.'
  }

  Write-Host 'Synthetic parser fixtures passed.' -ForegroundColor Green
}

if ($SelfTest) {
  Test-ParserFixtures
  exit 0
}

$history = Read-RequiredFile 'entry/src/main/ets/pages/HistoryPage.ets'
$historyControl = Get-HistoryClearControl $history $clearText
Get-HistoryClearControlFailures $historyControl $clearText | ForEach-Object { $failures.Add($_) }

$appScopeStrings = Read-RequiredFile 'AppScope/resources/base/element/string.json'
if ((Get-UniqueStringResourceValue $appScopeStrings 'app_name') -cne $expectedName) {
  $failures.Add("AppScope app_name must be exactly $expectedName.")
}

$entryStrings = Read-RequiredFile 'entry/src/main/resources/base/element/string.json'
foreach ($resourceName in @('EntryAbility_label', 'EntryAbility_desc')) {
  if ((Get-UniqueStringResourceValue $entryStrings $resourceName) -cne $expectedName) {
    $failures.Add("Entry string resource $resourceName must be exactly $expectedName.")
  }
}
$expectedModuleDescription = $expectedName + (-join [char[]](20027, 27169, 22359))
if ((Get-UniqueStringResourceValue $entryStrings 'module_desc') -cne $expectedModuleDescription) {
  $failures.Add("Entry string resource module_desc must be exactly $expectedModuleDescription.")
}

$indexTextValues = Get-ArkUiTextLiteralValues (Read-RequiredFile 'entry/src/main/ets/pages/Index.ets')
foreach ($titlePart in @($expectedName.Substring(0, 2), $expectedName.Substring(2))) {
  if (-not $indexTextValues.Contains($titlePart)) {
    $failures.Add("Index.ets must construct a real Text('$titlePart') title component.")
  }
}

$privacyTitle = $expectedName + (-join [char[]](38544, 31169, 25919, 31574))
if (-not (Test-ReleaseDocumentIdentity (Read-RequiredFile 'docs/release/privacy-policy.md') $privacyTitle)) {
  $failures.Add("privacy-policy.md must start with # $privacyTitle and name $expectedName in its first paragraph.")
}
$agreementTitle = $expectedName + (-join [char[]](29992, 25143, 21327, 35758))
if (-not (Test-ReleaseDocumentIdentity (Read-RequiredFile 'docs/release/user-agreement.md') $agreementTitle)) {
  $failures.Add("user-agreement.md must start with # $agreementTitle and name $expectedName in its first paragraph.")
}

$storeIconWiring = Test-StoreIconWiring (Read-RequiredFile 'scripts/generate-layered-icon.ps1')
if (-not $storeIconWiring.HasStoreIconPath) {
  $failures.Add('generate-layered-icon.ps1 must define $storeIconPath.')
}
if (-not $storeIconWiring.HasStoreIconFunction) {
  $failures.Add('generate-layered-icon.ps1 must define New-StoreIcon.')
}
if (-not $storeIconWiring.HasStoreIconInvocation) {
  $failures.Add('generate-layered-icon.ps1 must invoke New-StoreIcon with app background, foreground, and store output paths.')
}

$checklist = Read-RequiredFile 'docs/release/appgallery-submission-checklist.md'
foreach ($requiredText in @($expectedName, 'appgallery-icon.png', '900ms', (-join [char[]](37325, 26032, 25552, 23457, 21069, 30830, 35748)))) {
  if (-not $checklist.Contains($requiredText)) {
    $failures.Add("appgallery-submission-checklist.md is missing: $requiredText")
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "AppGallery remediation contract failed with $($failures.Count) issue(s)."
}

Write-Host 'AppGallery remediation contract passed.' -ForegroundColor Green
