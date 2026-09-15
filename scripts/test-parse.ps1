$a = New-Object System.Collections.Generic.List[string]
$a.Add("foo()")
$s = "x"
function Read-ProjectFile { param([string]$RelativePath); return "x" }
$theme = Read-ProjectFile "entry/src/main/ets/common/Theme.ets"
$screenService = Read-ProjectFile "entry/src/main/ets/services/ScreenService.ets"
$statusLine = @($theme -split "`r?`n" | Where-Object { $_ -match "SYSTEM_STATUS_BAR" }) | Select-Object -First 1
$pageBackgroundLine = @($theme -split "`r?`n" | Where-Object { $_ -match "PAGE_BG: string" }) | Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($statusLine) -or [string]::IsNullOrWhiteSpace($pageBackgroundLine)) {
  $a.Add("Theme.ets must define both SYSTEM_STATUS_BAR and PAGE_BG literal colors.")
} else {
  $statusBar = ($statusLine -split [char]39)[1]
  $pageBackground = ($pageBackgroundLine -split [char]39)[1]
  $a.Add("SYSTEM_STATUS_BAR")
}
if ($s -notmatch "applyAppChrome[\s\S]*?setWindowLayoutFullScreen\(false\)") {
  $a.Add("ScreenService.applyAppChrome() must use non-fullscreen ordinary window layout.")
}
if ($s -match "(?:uiFontSize|fontSize)\(\s*(?:10|11)\s*\)") {
  $a.Add("font")
}
Write-Host "ok"
