$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $failures.Add($Message)
}

function Get-JsonFile {
  param([string]$RelativePath)

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure "Missing release file: $RelativePath"
    return $null
  }
  try {
    return Get-Content -LiteralPath $path -Encoding UTF8 -Raw | ConvertFrom-Json
  } catch {
    Add-Failure "Invalid JSON release file: $RelativePath"
    return $null
  }
}

$module = Get-JsonFile 'entry/src/main/module.json5'
if ($null -ne $module -and @($module.module.requestPermissions).Count -ne 0) {
  Add-Failure 'module.json5 must keep requestPermissions empty for the offline application.'
}

$backup = Get-JsonFile 'entry/src/main/resources/base/profile/backup_config.json'
if ($null -ne $backup -and $backup.allowToBackupRestore -ne $false) {
  Add-Failure 'backup_config.json must set allowToBackupRestore=false for device-only user data.'
}

$networkPatterns = @(
  '(?i)@kit\.NetworkKit',
  '(?i)ohos\.permission\.INTERNET',
  '(?i)\bhttps?://',
  '(?i)\bWebSocket\b',
  '(?i)\baxios\b'
)
$networkFiles = Get-ChildItem -LiteralPath (Join-Path $projectRoot 'entry/src/main/ets') -Recurse -File -Filter '*.ets'
foreach ($file in $networkFiles) {
  $content = Get-Content -LiteralPath $file.FullName -Encoding UTF8 -Raw
  foreach ($pattern in $networkPatterns) {
    if ($content -match $pattern) {
      Add-Failure "Network reference found in $($file.FullName.Substring($projectRoot.Length + 1)): $pattern"
    }
  }
}

$deprecatedPatterns = @(
  '(?m)^import\s+\{[^\r\n}]*(?:router|promptAction)[^\r\n}]*\}\s+from\s+''@kit\.ArkUI''',
  '\bgetContext\(this\)',
  '(?<!\.)\bpx2vp\(',
  '(?<!\.)\banimateTo\('
)
$pageFiles = Get-ChildItem -LiteralPath (Join-Path $projectRoot 'entry/src/main/ets/pages') -File -Filter '*.ets'
foreach ($file in $pageFiles) {
  $content = Get-Content -LiteralPath $file.FullName -Encoding UTF8 -Raw
  foreach ($pattern in $deprecatedPatterns) {
    if ($content -match $pattern) {
      Add-Failure "Deprecated global ArkUI API remains in $($file.Name): $pattern"
    }
  }
}

$uiHelperPath = Join-Path $projectRoot 'entry/src/main/ets/common/UiContextHelper.ets'
if (-not (Test-Path -LiteralPath $uiHelperPath -PathType Leaf)) {
  Add-Failure 'UiContextHelper.ets must centralize host context, toast, back, and pushUrl access.'
} else {
  $uiHelperContent = Get-Content -LiteralPath $uiHelperPath -Encoding UTF8 -Raw
  foreach ($contract in @('requireHostContext', 'getPromptAction()', 'getRouter().back()', 'getRouter().pushUrl(')) {
    if ($uiHelperContent -notmatch [regex]::Escape($contract)) {
      Add-Failure "UiContextHelper.ets is missing release contract: $contract"
    }
  }
}

$requiredDocuments = @(
  'docs/release/privacy-policy.md',
  'docs/release/user-agreement.md',
  'docs/release/appgallery-submission-checklist.md'
)
foreach ($relativePath in $requiredDocuments) {
  $path = Join-Path $projectRoot $relativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf) -or (Get-Item -LiteralPath $path).Length -lt 500) {
    Add-Failure "$relativePath must exist and contain a substantive release document."
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "Release contract failed with $($failures.Count) issue(s)."
}

Write-Host 'Release contract passed.' -ForegroundColor Green
