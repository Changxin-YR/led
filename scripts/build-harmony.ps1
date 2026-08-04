# LED滚动字幕 - HarmonyOS 构建脚本
param(
  [ValidateSet('debug', 'release')]
  [string]$BuildMode = 'debug'
)

$ErrorActionPreference = 'Stop'

Write-Host "`n=== LED滚动字幕 构建 ($BuildMode) ===`n" -ForegroundColor Cyan

# 查找 hvigorw.bat
$hvigorw = $null
if (Test-Path ".\hvigorw.bat") {
  $hvigorw = ".\hvigorw.bat"
} elseif (Test-Path ".\hvigorw") {
  $hvigorw = ".\hvigorw"
} else {
  $found = Get-Command hvigorw.bat -ErrorAction SilentlyContinue
  if ($found) {
    $hvigorw = $found.Source
  }
}

if (-not $hvigorw) {
  Write-Host "[ERROR] 未找到 hvigorw.bat。请安装 DevEco Studio 或将 Hvigor bin 添加到 PATH。" -ForegroundColor Red
  exit 1
}

Write-Host "使用构建工具: $hvigorw" -ForegroundColor Gray
Write-Host "构建模式: $BuildMode" -ForegroundColor Gray

# 执行构建
$buildArgs = @(
  'assembleHap',
  '--no-daemon',
  '--mode',
  'module',
  '-p',
  'product=default',
  '-p',
  "buildMode=$BuildMode"
)
$buildArgsText = $buildArgs -join ' '
Write-Host "`n执行: $hvigorw $buildArgsText`n" -ForegroundColor Gray

# 直接调用以避免 Start-Process 在大小写重复的 Path/PATH 环境变量下创建子进程失败。
& $hvigorw @buildArgs
$hvigorExitCode = $LASTEXITCODE

if ($hvigorExitCode -ne 0) {
  Write-Host "`n[ERROR] 构建失败，退出码: $hvigorExitCode" -ForegroundColor Red
  exit $hvigorExitCode
}

# 查找构建产物
$hapFiles = Get-ChildItem -Path "entry\build" -Filter "*.hap" -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending

if ($hapFiles.Count -eq 0) {
  Write-Host "`n[ERROR] 构建成功但未找到 .hap 文件" -ForegroundColor Red
  exit 1
}

$artifact = $hapFiles[0]
Write-Host "`n=== 构建成功 ===" -ForegroundColor Green
Write-Host "产物路径: $($artifact.FullName)" -ForegroundColor White
Write-Host "产物大小: $($artifact.Length) bytes" -ForegroundColor White
exit 0
