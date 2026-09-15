$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]

function Get-Source {
  param([string]$RelativePath)
  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("Missing file: $RelativePath")
    return ''
  }
  return Get-Content -Encoding UTF8 -Raw -LiteralPath $path
}

function Assert-Contains {
  param([string]$Content, [string]$Label, [string]$Pattern)
  if ($Content -notmatch $Pattern) { $failures.Add("$Label is missing: $Pattern") }
}

function ConvertTo-LinearSrgb {
  param([int]$Channel)
  $value = $Channel / 255.0
  if ($value -le 0.04045) { return $value / 12.92 }
  return [Math]::Pow(($value + 0.055) / 1.055, 2.4)
}

function Get-Contrast {
  param([string]$Foreground, [string]$Background)
  $luminance = {
    param([string]$Color)
    $r = ConvertTo-LinearSrgb ([Convert]::ToInt32($Color.Substring(1, 2), 16))
    $g = ConvertTo-LinearSrgb ([Convert]::ToInt32($Color.Substring(3, 2), 16))
    $b = ConvertTo-LinearSrgb ([Convert]::ToInt32($Color.Substring(5, 2), 16))
    return 0.2126 * $r + 0.7152 * $g + 0.0722 * $b
  }
  $first = & $luminance $Foreground
  $second = & $luminance $Background
  return ([Math]::Max($first, $second) + 0.05) / ([Math]::Min($first, $second) + 0.05)
}

foreach ($background in @('#000000', '#777777', '#FFFFFF', '#FF0000', '#00FF00', '#0000FF')) {
  if ([Math]::Max((Get-Contrast '#000000' $background), (Get-Contrast '#FFFFFF' $background)) -lt 4.5) {
    $failures.Add("The black/white fallback cannot protect $background at 4.5:1.")
  }
}

$utils = Get-Source 'entry/src/main/ets/common/Utils.ets'
Assert-Contains $utils 'Utils.ets' 'static ensureTextContrast\(requestedColor: string, backgroundColor: string\): string'
Assert-Contains $utils 'Utils.ets' 'static getContrastRatio\(foreground: string, background: string\): number'
Assert-Contains $utils 'Utils.ets' 'return blackContrast >= whiteContrast \? ["'']#000000["''] : ["'']#FFFFFF["'']'

$panel = Get-Source 'entry/src/main/ets/components/LedPanel.ets'
Assert-Contains $panel 'LedPanel.ets' "Utils.ensureTextContrast\(this.color, '#01060C'\)"

$display = Get-Source 'entry/src/main/ets/pages/DisplayPage.ets'
Assert-Contains $display 'DisplayPage.ets' 'Utils.ensureTextContrast\(textColor, this.config.backgroundColor\)'
Assert-Contains $display 'DisplayPage.ets' '@State textScale: number = 1.0'
Assert-Contains $display 'DisplayPage.ets' 'this.textScale = 1.0 - \(step / steps\) \* 0.06'
if ($display.IndexOf('this.startAnimation()') -lt 0 -or
    $display.IndexOf('await window.getLastWindow') -lt 0 -or
    $display.IndexOf('this.startAnimation()') -gt $display.IndexOf('await window.getLastWindow')) {
  $failures.Add('DisplayPage must render the first display content before awaiting window setup operations.')
}
if ($display -match 'textOpacity|\.opacity\(0\.9\)|entryFadeDistance') {
  $failures.Add('DisplayPage must not fade visible LED text below full opacity.')
}

$storage = Get-Source 'entry/src/main/ets/services/StorageService.ets'
Assert-Contains $storage 'StorageService.ets' 'async saveDisplayConfig\(config: BannerConfig\): Promise<void>'
Assert-Contains $storage 'StorageService.ets' 'await store.put\(KEY_LAST_CONFIG, JSON.stringify\(config\)\)'
Assert-Contains $storage 'StorageService.ets' 'await store.put\(KEY_HISTORY, JSON.stringify\(this.mergeHistory\(records, config\)\)\)'
Assert-Contains $storage 'StorageService.ets' 'private isValidColor\(value: Object, allowRainbow: boolean = false\): boolean'

foreach ($path in @('entry/src/main/ets/pages/Index.ets', 'entry/src/main/ets/pages/TemplatePage.ets', 'entry/src/main/ets/pages/HistoryPage.ets')) {
  $content = Get-Source $path
  Assert-Contains $content $path 'private persistDisplayConfig\(config: BannerConfig\): void'
  $routeIndex = $content.IndexOf("await UiContextHelper.pushUrl(this.getUIContext(), 'pages/DisplayPage'")
  $persistIndex = $content.IndexOf('this.persistDisplayConfig(config)')
  if ($routeIndex -lt 0 -or $persistIndex -le $routeIndex) {
    $failures.Add("$path must start background display persistence only after DisplayPage navigation.")
  }
}

$index = Get-Source 'entry/src/main/ets/pages/Index.ets'
Assert-Contains $index 'Index.ets' 'textColor: Utils.ensureTextContrast\(this.textColor, this.bannerBackgroundColor\)'
if ($index -match 'await this\.ensureStorageReady\(\)') { $failures.Add('Index.ets start action must not wait for storage initialization.') }

$template = Get-Source 'entry/src/main/ets/pages/TemplatePage.ets'
Assert-Contains $template 'TemplatePage.ets' 'textColor: Utils.ensureTextContrast\(this.editTemplate.textColor, this.editTemplate.backgroundColor\)'

$color = Get-Source 'entry/src/main/ets/pages/ColorPickerPage.ets'
Assert-Contains $color 'ColorPickerPage.ets' 'private persistCustomColor\(color: string\): void'
Assert-Contains $color 'ColorPickerPage.ets' 'AppStorage.setOrCreate<string>\(''customColorResult'', this.currentColor\)'

$history = Get-Source 'entry/src/main/ets/pages/HistoryPage.ets'
Assert-Contains $history 'HistoryPage.ets' 'textColor: Utils.ensureTextContrast\(record.config.textColor, record.config.backgroundColor\)'
Assert-Contains $history 'HistoryPage.ets' 'private persistHistoryChange\(operation: \(\) => Promise<void>, message: string\): void'
Assert-Contains $history 'HistoryPage.ets' 'this.records = this.records.filter'
Assert-Contains $history 'HistoryPage.ets' 'this.records = \[\]'

$counter = Get-Source 'entry/src/main/ets/pages/CounterPage.ets'
Assert-Contains $counter 'CounterPage.ets' 'private persistCount\(\): void'
Assert-Contains $counter 'CounterPage.ets' 'this.count \+= delta'
Assert-Contains $counter 'CounterPage.ets' 'this.persistCount\(\)'
Assert-Contains $counter 'CounterPage.ets' 'if \(!this.hasLocalChange\) this.count = 0'

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "Display safety and click response contract failed with $($failures.Count) issue(s)."
}

Write-Host 'Display safety and click response contract passed.' -ForegroundColor Green
