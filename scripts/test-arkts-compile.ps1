$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $projectRoot 'scripts\build-harmony.ps1') -BuildMode debug
if ($LASTEXITCODE -ne 0) {
  throw 'Debug build must compile all ArkTS sources and produce a HAP artifact.'
}

Write-Host 'ArkTS compilation regression check passed.' -ForegroundColor Green
