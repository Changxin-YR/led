$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]

function Read-ProjectFile {
  param([string]$RelativePath)

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    $failures.Add("Missing required file: $RelativePath")
    return ""
  }
  return Get-Content -Encoding UTF8 -Raw -LiteralPath $path
}

function Get-StringResourceValue {
  param([string]$RelativePath, [string]$Name)

  try {
    $resource = Read-ProjectFile $RelativePath | ConvertFrom-Json
    $matches = @($resource.string | Where-Object { $_.name -ceq $Name })
    if ($matches.Count -ne 1) {
      $failures.Add("$RelativePath must contain exactly one string resource named $Name.")
      return ""
    }
    return [string]$matches[0].value
  } catch {
    $failures.Add("Unable to parse $RelativePath as JSON: $($_.Exception.Message)")
    return ""
  }
}

function Assert-Equal {
  param([string]$Actual, [string]$Expected, [string]$Label)

  if ($Actual -cne $Expected) {
    $failures.Add($Label + " must be " + $Expected + "; found " + $Actual + ".")
  }
}

$appName = Get-StringResourceValue "AppScope/resources/base/element/string.json" "app_name"
$entryLabel = Get-StringResourceValue "entry/src/main/resources/base/element/string.json" "EntryAbility_label"
$entryDescription = Get-StringResourceValue "entry/src/main/resources/base/element/string.json" "EntryAbility_desc"
$moduleDescription = Get-StringResourceValue "entry/src/main/resources/base/element/string.json" "module_desc"
$appManifest = Read-ProjectFile "AppScope/app.json5" | ConvertFrom-Json
$buildProfile = Read-ProjectFile "build-profile.json5"
$expectedDisplayName = -join [char[]](20809, 36857, 23383, 24149)
Assert-Equal $appName $expectedDisplayName "AppScope app_name"
Assert-Equal $entryLabel $expectedDisplayName "EntryAbility_label"
Assert-Equal $entryDescription $expectedDisplayName "EntryAbility_desc"
$expectedModuleDescription = $expectedDisplayName + (-join [char[]](20027, 27169, 22359))
Assert-Equal $moduleDescription $expectedModuleDescription "module_desc"
$indexPage = Read-ProjectFile "entry/src/main/ets/pages/Index.ets"
$titleAccent = $expectedDisplayName.Substring(0, 2)
$titlePrimary = $expectedDisplayName.Substring(2)
if (-not $indexPage.Contains(("Text('" + $titleAccent + "')")) -or
    -not $indexPage.Contains(("Text('" + $titlePrimary + "')"))) {
  $failures.Add('Index title must render the approved app name.')
}
Assert-Equal ([string]$appManifest.app.bundleName) "com.ledscroll.banner" "bundleName"
Assert-Equal ([string]$appManifest.app.versionCode) "1000000" "versionCode"
Assert-Equal ([string]$appManifest.app.versionName) "1.0.0" "versionName"
if (-not $buildProfile.Contains('"signingConfigs": []')) {
  $failures.Add('build-profile.json5 must retain the baseline empty signingConfigs array.')
}
try {
  $buildProfileManifest = $buildProfile | ConvertFrom-Json
  if (@($buildProfileManifest.app.signingConfigs).Count -ne 0) {
    $failures.Add('build-profile.json5 must not contain tracked signing configurations.')
  }
} catch {
  $failures.Add("Unable to parse build-profile.json5 as JSON: $($_.Exception.Message)")
}
foreach ($signingMaterialField in @('"storeFile"', '"storePassword"', '"keyAlias"', '"keyPassword"', '"profile"', '"certpath"')) {
  if ($buildProfile.Contains($signingMaterialField)) {
    $failures.Add('build-profile.json5 must not contain tracked signing material.')
    break
  }
}

$theme = Read-ProjectFile "entry/src/main/ets/common/Theme.ets"
$screenService = Read-ProjectFile "entry/src/main/ets/services/ScreenService.ets"
$appChrome = [regex]::Match($screenService,
  '(?s)async applyAppChrome\(\): Promise<void> \{.*?(?=\r?\n  async enterDisplayMode)').Value
$displayMode = [regex]::Match($screenService,
  '(?s)async enterDisplayMode\([^\r\n]*\)\: Promise<void> \{.*?(?=\r?\n  async exitDisplayMode)').Value
$statusLine = @($theme -split "`r?`n" | Where-Object { $_ -match "SYSTEM_STATUS_BAR" }) | Select-Object -First 1
$pageBackgroundLine = @($theme -split "`r?`n" | Where-Object { $_ -match "PAGE_BG: string" }) | Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($statusLine) -or [string]::IsNullOrWhiteSpace($pageBackgroundLine)) {
  $failures.Add("Theme.ets must define both SYSTEM_STATUS_BAR and PAGE_BG literal colors.")
} else {
  $statusBar = ($statusLine -split [char]39)[1]
  $pageBackground = ($pageBackgroundLine -split [char]39)[1]
  Assert-Equal $statusBar $pageBackground "SYSTEM_STATUS_BAR"
}
if ([string]::IsNullOrWhiteSpace($appChrome) -or -not $appChrome.Contains("setWindowLayoutFullScreen(false)")) {
  $failures.Add('ScreenService applyAppChrome must use non-fullscreen ordinary window layout.')
}
if ([string]::IsNullOrWhiteSpace($appChrome) -or -not $appChrome.Contains("statusBarColor: AppTheme.PAGE_BG")) {
  $failures.Add('ScreenService applyAppChrome must use PAGE_BG for the ordinary status bar.')
}
if ([string]::IsNullOrWhiteSpace($displayMode) -or -not $displayMode.Contains("setWindowLayoutFullScreen(true)")) {
  $failures.Add('ScreenService enterDisplayMode must keep fullscreen display mode.')
}

$normalPages = @(
  "entry/src/main/ets/pages/Index.ets",
  "entry/src/main/ets/pages/TemplatePage.ets",
  "entry/src/main/ets/pages/HistoryPage.ets",
  "entry/src/main/ets/pages/ColorPickerPage.ets",
  "entry/src/main/ets/pages/CounterPage.ets"
)
$ledPanel = Read-ProjectFile "entry/src/main/ets/components/LedPanel.ets"
$dotFontMatch = [regex]::Match($theme, 'LED_MATRIX_DOT_FONT_SIZE: number = ([0-9]+)')
if (-not $dotFontMatch.Success -or [int]$dotFontMatch.Groups[1].Value -lt 10) {
  $failures.Add('Theme.ets must define LED_MATRIX_DOT_FONT_SIZE at or above the 10fp PC minimum.')
}
if (-not $ledPanel.Contains('.fontSize(AppTheme.LED_MATRIX_DOT_FONT_SIZE)') -or $ledPanel.Contains('.fontSize(8)')) {
  $failures.Add('LedPanel dot-matrix text must use the shared minimum-size font token instead of 8fp.')
}
foreach ($relativePath in $normalPages) {
  $content = Read-ProjectFile $relativePath
  if ($content.Contains(".expandSafeArea([SafeAreaType.SYSTEM]")) {
    $failures.Add([string]::Concat($relativePath, ' must leave system-bar safe-area reservation to the ordinary window layout.'))
  }
  if ($content.Contains("uiFontSize(10)") -or $content.Contains("uiFontSize(11)") -or
      $content.Contains(".fontSize(10)") -or $content.Contains(".fontSize(11)")) {
    $failures.Add([string]::Concat($relativePath, ' contains a fixed UI font size below 12fp.'))
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "AppGallery acceptance contract failed with $($failures.Count) issue(s)."
}

Write-Host "AppGallery acceptance contract passed." -ForegroundColor Green
