# LED滚动字幕 - 标准检查脚本
# 检查项目结构、配置文件和文档完整性

$ErrorCount = 0
$WarnCount = 0

function Test-FileExists {
  param([string]$Path, [string]$Label, [bool]$Required = $true)
  if (Test-Path $Path) {
    Write-Host "  [OK] $Label" -ForegroundColor Green
  } elseif ($Required) {
    Write-Host "  [FAIL] $Label - 缺失: $Path" -ForegroundColor Red
    $script:ErrorCount++
  } else {
    Write-Host "  [WARN] $Label - 建议添加: $Path" -ForegroundColor Yellow
    $script:WarnCount++
  }
}

function Test-FileContains {
  param([string]$Path, [string]$Pattern, [string]$Label)
  if (Test-Path $Path) {
    $content = Get-Content $Path -Raw -ErrorAction SilentlyContinue
    if ($content -match $Pattern) {
      Write-Host "  [OK] $Label" -ForegroundColor Green
    } else {
      Write-Host "  [FAIL] $Label - 未找到: $Pattern" -ForegroundColor Red
      $script:ErrorCount++
    }
  }
}

Write-Host "`n=== LED滚动字幕 标准检查 ===`n" -ForegroundColor Cyan

# 1. 项目文档
Write-Host "[文档检查]" -ForegroundColor White
Test-FileExists "README.md" "README.md" $false
Test-FileExists "AGENTS.md" "AGENTS.md"
Test-FileExists "tasks.md" "tasks.md"
Test-FileExists "changes.md" "changes.md"
Test-FileExists "design.md" "design.md"
Test-FileExists "design-qa.md" "design-qa.md"
Test-FileExists "docs\qa\README.md" "docs/qa/README.md"

# 2. Stage模型配置
Write-Host "`n[Stage模型配置]" -ForegroundColor White
Test-FileExists "build-profile.json5" "build-profile.json5"
Test-FileExists "oh-package.json5" "oh-package.json5 (root)"
Test-FileExists "hvigorfile.ts" "hvigorfile.ts (root)"
Test-FileExists "entry\hvigorfile.ts" "entry/hvigorfile.ts"
Test-FileExists "entry\oh-package.json5" "entry/oh-package.json5"
Test-FileExists "entry\src\main\module.json5" "module.json5"
Test-FileExists "entry\src\main\resources\base\profile\main_pages.json" "main_pages.json"

# 3. 源代码目录
Write-Host "`n[源代码目录]" -ForegroundColor White
Test-FileExists "entry\src\main\ets" "entry/src/main/ets"
Test-FileExists "entry\src\main\ets\pages" "pages/"
Test-FileExists "entry\src\main\ets\components" "components/"
Test-FileExists "entry\src\main\ets\services" "services/"
Test-FileExists "entry\src\main\ets\models" "models/"
Test-FileExists "entry\src\main\ets\common" "common/"

# 4. 资源目录
Write-Host "`n[资源目录]" -ForegroundColor White
Test-FileExists "entry\src\main\resources" "resources/"
Test-FileExists "entry\src\main\resources\base\element\string.json" "string.json"
Test-FileExists "entry\src\main\resources\base\element\color.json" "color.json"

# 5. module.json5 内容检查
Write-Host "`n[module.json5 内容]" -ForegroundColor White
Test-FileContains "entry\src\main\module.json5" '"type":\s*"entry"' "type: entry"
Test-FileContains "entry\src\main\module.json5" '"mainElement"' "mainElement 声明"
Test-FileContains "entry\src\main\module.json5" '"pages"' "pages 声明"

# 6. main_pages.json 内容检查
Write-Host "`n[main_pages.json 内容]" -ForegroundColor White
Test-FileContains "entry\src\main\resources\base\profile\main_pages.json" '"src"' "src 字段"
Test-FileContains "entry\src\main\resources\base\profile\main_pages.json" 'pages/' "pages/ 路由"

# 7. tasks.md 状态检查
Write-Host "`n[tasks.md 状态]" -ForegroundColor White
if (Test-Path "tasks.md") {
  $tasksContent = Get-Content "tasks.md" -Raw
  $statuses = @('pending', 'in_progress', 'done', 'blocked')
  foreach ($s in $statuses) {
    if ($tasksContent -match $s) {
      Write-Host "  [OK] 包含状态: $s" -ForegroundColor Green
    } else {
      Write-Host "  [WARN] 缺少状态: $s" -ForegroundColor Yellow
      $script:WarnCount++
    }
  }
}

# 8. 窗口与系统栏状态合同
Write-Host "`n[窗口状态合同]" -ForegroundColor White
try {
  & (Join-Path $PSScriptRoot 'test-window-layout.ps1')
} catch {
  Write-Host "  [FAIL] 窗口状态合同未通过" -ForegroundColor Red
  $script:ErrorCount++
}

# 结果
Write-Host "`n=== 检查结果 ===" -ForegroundColor Cyan
if ($ErrorCount -eq 0) {
  Write-Host "通过! 错误: 0, 警告: $WarnCount" -ForegroundColor Green
  exit 0
} else {
  Write-Host "失败! 错误: $ErrorCount, 警告: $WarnCount" -ForegroundColor Red
  exit 1
}
