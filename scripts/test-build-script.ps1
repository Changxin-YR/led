$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$buildScriptPath = Join-Path $projectRoot 'scripts\build-harmony.ps1'
$tokens = $null
$parseErrors = $null
[System.Management.Automation.Language.Parser]::ParseFile($buildScriptPath, [ref]$tokens, [ref]$parseErrors) | Out-Null

if ($parseErrors.Count -gt 0) {
  throw "build-harmony.ps1 must parse in Windows PowerShell: $($parseErrors[0].Message)"
}

$buildScript = Get-Content -Raw $buildScriptPath
if ($buildScript -match '(?m)^\s*(?:\$\w+\s*=\s*)?Start-Process\b') {
  throw 'build-harmony.ps1 must invoke Hvigor directly, not through Start-Process.'
}

if ($buildScript -notmatch '& \$hvigorw') {
  throw 'build-harmony.ps1 must invoke the resolved Hvigor wrapper directly.'
}

Write-Host 'Build runner regression check passed.' -ForegroundColor Green
