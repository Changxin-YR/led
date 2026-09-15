$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$appMediaDirectory = Join-Path $projectRoot 'AppScope/resources/base/media'
$entryMediaDirectory = Join-Path $projectRoot 'entry/src/main/resources/base/media'
$releaseDirectory = Join-Path $projectRoot 'docs/release'
$appBackgroundPath = Join-Path $appMediaDirectory 'app_icon_background.png'
$appForegroundPath = Join-Path $appMediaDirectory 'app_icon_foreground.png'
$entryBackgroundPath = Join-Path $entryMediaDirectory 'icon_background.png'
$entryForegroundPath = Join-Path $entryMediaDirectory 'icon_foreground.png'
$storeIconPath = Join-Path $releaseDirectory 'appgallery-icon.png'
$obsoleteIconPath = [System.IO.Path]::GetFullPath((Join-Path $appMediaDirectory 'app_icon.png'))
$expectedObsoletePath = [System.IO.Path]::GetFullPath((Join-Path $projectRoot 'AppScope/resources/base/media/app_icon.png'))

function New-BackgroundLayer {
  param([string]$OutputPath)

  [System.Drawing.Bitmap]$bitmap = $null
  [System.Drawing.Graphics]$graphics = $null
  [System.Drawing.Drawing2D.LinearGradientBrush]$gradient = $null
  [System.Drawing.Drawing2D.GraphicsPath]$glowPath = $null
  [System.Drawing.Drawing2D.PathGradientBrush]$glow = $null
  [System.Drawing.SolidBrush[]]$dotBrushes = @()
  [System.Drawing.Pen]$scanPen = $null

  try {
    $bitmap = [System.Drawing.Bitmap]::new(
      1024,
      1024,
      [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::FromArgb(255, 1, 5, 12))
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $gradient = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
      [System.Drawing.Point]::new(0, 0),
      [System.Drawing.Point]::new(1024, 1024),
      [System.Drawing.Color]::FromArgb(255, 7, 24, 39),
      [System.Drawing.Color]::FromArgb(255, 1, 5, 12)
    )
    $graphics.FillRectangle($gradient, 0, 0, 1024, 1024)

    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $glowPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $glowPath.AddEllipse(-170, 72, 1364, 920)
    $glow = [System.Drawing.Drawing2D.PathGradientBrush]::new($glowPath)
    $glow.CenterPoint = [System.Drawing.PointF]::new(520.0, 500.0)
    $glow.CenterColor = [System.Drawing.Color]::FromArgb(52, 0, 219, 255)
    $glow.SurroundColors = [System.Drawing.Color[]]@(
      [System.Drawing.Color]::FromArgb(0, 0, 80, 110)
    )
    $graphics.FillPath($glow, $glowPath)

    $dotBrushes = [System.Drawing.SolidBrush[]]@(
      [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(20, 18, 132, 158)),
      [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(29, 20, 164, 190)),
      [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(38, 26, 196, 220))
    )
    for ([int]$y = 18; $y -lt 1024; $y += 32) {
      for ([int]$x = 18; $x -lt 1024; $x += 32) {
        [int]$gridX = ($x - 18) / 32
        [int]$gridY = ($y - 18) / 32
        [int]$brushIndex = ($gridX + ($gridY * 2)) % $dotBrushes.Count
        [int]$dotSize = 2 + (($gridX + $gridY) % 2)
        $graphics.FillEllipse($dotBrushes[$brushIndex], $x, $y, $dotSize, $dotSize)
      }
    }

    $scanPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(18, 32, 224, 245), 1.0)
    for ([int]$y = 96; $y -lt 1024; $y += 128) {
      $graphics.DrawLine($scanPen, 0, $y, 1023, $y)
    }

    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally {
    if ($null -ne $scanPen) { $scanPen.Dispose() }
    foreach ($brush in $dotBrushes) { $brush.Dispose() }
    if ($null -ne $glow) { $glow.Dispose() }
    if ($null -ne $glowPath) { $glowPath.Dispose() }
    if ($null -ne $gradient) { $gradient.Dispose() }
    if ($null -ne $graphics) { $graphics.Dispose() }
    if ($null -ne $bitmap) { $bitmap.Dispose() }
  }
}

function New-ForegroundLayer {
  param([string]$OutputPath)

  [System.Drawing.Bitmap]$bitmap = $null
  [System.Drawing.Graphics]$graphics = $null
  [System.Drawing.Pen]$traceGlowPen = $null
  [System.Drawing.Pen]$tracePen = $null
  [System.Drawing.SolidBrush]$outerDotBrush = $null
  [System.Drawing.SolidBrush]$middleDotBrush = $null
  [System.Drawing.SolidBrush]$coreDotBrush = $null
  [System.Drawing.SolidBrush]$highlightBrush = $null

  try {
    $bitmap = [System.Drawing.Bitmap]::new(
      1024,
      1024,
      [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $traceGlowPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(45, 0, 224, 255), 14.0)
    $tracePen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(185, 42, 236, 255), 3.0)
    $traceGlowPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $traceGlowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $tracePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $tracePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    [System.Drawing.Point[]]$topTrace = @(
      [System.Drawing.Point]::new(256, 96),
      [System.Drawing.Point]::new(256, 144),
      [System.Drawing.Point]::new(326, 144),
      [System.Drawing.Point]::new(350, 168)
    )
    [System.Drawing.Point[]]$bottomTrace = @(
      [System.Drawing.Point]::new(674, 856),
      [System.Drawing.Point]::new(698, 880),
      [System.Drawing.Point]::new(768, 880),
      [System.Drawing.Point]::new(768, 928)
    )
    [System.Drawing.Point[]]$leftTrace = @(
      [System.Drawing.Point]::new(96, 512),
      [System.Drawing.Point]::new(144, 512),
      [System.Drawing.Point]::new(174, 482)
    )
    [System.Drawing.Point[]]$rightTrace = @(
      [System.Drawing.Point]::new(850, 542),
      [System.Drawing.Point]::new(880, 512),
      [System.Drawing.Point]::new(928, 512)
    )
    foreach ($trace in @($topTrace, $bottomTrace, $leftTrace, $rightTrace)) {
      $graphics.DrawLines($traceGlowPen, $trace)
      $graphics.DrawLines($tracePen, $trace)
    }

    $graphics.DrawLine($traceGlowPen, 96, 210, 928, 210)
    $graphics.DrawLine($tracePen, 96, 210, 928, 210)
    $graphics.DrawLine($traceGlowPen, 96, 814, 928, 814)
    $graphics.DrawLine($tracePen, 96, 814, 928, 814)

    $outerDotBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(36, 0, 222, 255))
    $middleDotBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(92, 0, 225, 255))
    $coreDotBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(238, 37, 235, 255))
    $highlightBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(230, 194, 253, 255))

    $patterns = @{
      L = @('10000', '10000', '10000', '10000', '10000', '10000', '11111')
      E = @('11111', '10000', '10000', '11110', '10000', '10000', '11111')
      D = @('11110', '10001', '10001', '10001', '10001', '10001', '11110')
    }
    [string[]]$word = @('L', 'E', 'D')
    [int]$originX = 150
    [int]$originY = 315
    [int]$stepX = 44
    [int]$stepY = 62
    [int]$characterPitch = 260

    for ([int]$characterIndex = 0; $characterIndex -lt $word.Count; $characterIndex++) {
      [string[]]$pattern = $patterns[$word[$characterIndex]]
      for ([int]$row = 0; $row -lt $pattern.Count; $row++) {
        for ([int]$column = 0; $column -lt 5; $column++) {
          if ($pattern[$row][$column] -ne '1') {
            continue
          }

          [int]$centerX = $originX + ($characterIndex * $characterPitch) + ($column * $stepX)
          [int]$centerY = $originY + ($row * $stepY)
          $graphics.FillEllipse($outerDotBrush, $centerX - 34, $centerY - 34, 68, 68)
          $graphics.FillEllipse($middleDotBrush, $centerX - 26, $centerY - 26, 52, 52)
          $graphics.FillEllipse($coreDotBrush, $centerX - 18, $centerY - 18, 36, 36)
          $graphics.FillEllipse($highlightBrush, $centerX - 8, $centerY - 10, 11, 11)
        }
      }
    }

    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally {
    if ($null -ne $highlightBrush) { $highlightBrush.Dispose() }
    if ($null -ne $coreDotBrush) { $coreDotBrush.Dispose() }
    if ($null -ne $middleDotBrush) { $middleDotBrush.Dispose() }
    if ($null -ne $outerDotBrush) { $outerDotBrush.Dispose() }
    if ($null -ne $tracePen) { $tracePen.Dispose() }
    if ($null -ne $traceGlowPen) { $traceGlowPen.Dispose() }
    if ($null -ne $graphics) { $graphics.Dispose() }
    if ($null -ne $bitmap) { $bitmap.Dispose() }
  }
}

function New-StoreIcon {
  param(
    [string]$BackgroundPath,
    [string]$ForegroundPath,
    [string]$OutputPath
  )

  [System.Drawing.Bitmap]$background = $null
  [System.Drawing.Bitmap]$foreground = $null
  [System.Drawing.Bitmap]$bitmap = $null
  [System.Drawing.Graphics]$graphics = $null

  try {
    $background = [System.Drawing.Bitmap]::new($BackgroundPath)
    $foreground = [System.Drawing.Bitmap]::new($ForegroundPath)
    $bitmap = [System.Drawing.Bitmap]::new(
      1024,
      1024,
      [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.DrawImageUnscaled($background, 0, 0)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $graphics.DrawImageUnscaled($foreground, 0, 0)
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally {
    if ($null -ne $graphics) { $graphics.Dispose() }
    if ($null -ne $bitmap) { $bitmap.Dispose() }
    if ($null -ne $foreground) { $foreground.Dispose() }
    if ($null -ne $background) { $background.Dispose() }
  }
}

New-Item -ItemType Directory -Force -Path $appMediaDirectory, $entryMediaDirectory, $releaseDirectory | Out-Null
New-BackgroundLayer $appBackgroundPath
New-ForegroundLayer $appForegroundPath
Copy-Item -LiteralPath $appBackgroundPath -Destination $entryBackgroundPath -Force
Copy-Item -LiteralPath $appForegroundPath -Destination $entryForegroundPath -Force
New-StoreIcon `
  -BackgroundPath $appBackgroundPath `
  -ForegroundPath $appForegroundPath `
  -OutputPath $storeIconPath

if ($obsoleteIconPath -cne $expectedObsoletePath) {
  throw "Refusing to remove unexpected obsolete icon path: $obsoleteIconPath"
}
if (Test-Path -LiteralPath $obsoleteIconPath -PathType Leaf) {
  Remove-Item -LiteralPath $obsoleteIconPath -Force
}

Write-Host 'Generated deterministic 1024x1024 layered application icon assets.' -ForegroundColor Green
