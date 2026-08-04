$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$packagePath = Join-Path $projectRoot 'oh-package.json5'
$modulePackagePath = Join-Path $projectRoot 'entry\oh-package.json5'
$appConfigPath = Join-Path $projectRoot 'AppScope\app.json5'
$configPath = Join-Path $projectRoot 'hvigor\hvigor-config.json5'
$requiredPaths = @(
  'hvigorw',
  'hvigorw.bat',
  'hvigor\hvigor-config.json5',
  'entry\build-profile.json5'
)

$missingPaths = @($requiredPaths | Where-Object { -not (Test-Path (Join-Path $projectRoot $_)) })
if ($missingPaths.Count -gt 0) {
  throw "Missing build bootstrap files: $($missingPaths -join ', ')"
}

$package = Get-Content -Raw $packagePath | ConvertFrom-Json
$config = Get-Content -Raw $configPath | ConvertFrom-Json
if ($config.modelVersion -ne $package.modelVersion) {
  throw "Hvigor modelVersion '$($config.modelVersion)' must match oh-package modelVersion '$($package.modelVersion)'"
}

$modulePackage = Get-Content -Raw $modulePackagePath | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace([string]$modulePackage.version)) {
  throw 'entry/oh-package.json5 must define a non-empty string version.'
}

$appConfig = Get-Content -Raw $appConfigPath | ConvertFrom-Json
if ([string]$appConfig.app.apiReleaseType -notmatch '^(Canary[1-9]\d*)|(Beta[1-9]\d*)|(Release[1-9]\d*)$') {
  throw 'AppScope/app.json5 apiReleaseType must use a numbered Canary, Beta, or Release channel.'
}

Write-Host 'Build bootstrap regression check passed.' -ForegroundColor Green
