$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]

Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public sealed class IconPixelMetrics
{
    public int Width { get; set; }
    public int Height { get; set; }
    public long TransparentPixels { get; set; }
    public long NonOpaquePixels { get; set; }
    public long ColoredPixels { get; set; }
    public int SampledColorCount { get; set; }
    public int MinContentX { get; set; }
    public int MinContentY { get; set; }
    public int MaxContentX { get; set; }
    public int MaxContentY { get; set; }
    public bool CornersOpaque { get; set; }
}

public static class IconPixelInspector
{
    public static IconPixelMetrics Analyze(string path)
    {
        using (var source = new Bitmap(path))
        using (var bitmap = new Bitmap(source.Width, source.Height, PixelFormat.Format32bppArgb))
        {
            using (var graphics = Graphics.FromImage(bitmap))
            {
                graphics.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
                graphics.DrawImageUnscaled(source, 0, 0);
            }

            var result = new IconPixelMetrics
            {
                Width = bitmap.Width,
                Height = bitmap.Height,
                MinContentX = bitmap.Width,
                MinContentY = bitmap.Height,
                MaxContentX = -1,
                MaxContentY = -1
            };
            var sampledColors = new HashSet<int>();
            var rectangle = new Rectangle(0, 0, bitmap.Width, bitmap.Height);
            var data = bitmap.LockBits(rectangle, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            try
            {
                int rowLength = Math.Abs(data.Stride);
                var bytes = new byte[rowLength * bitmap.Height];
                Marshal.Copy(data.Scan0, bytes, 0, bytes.Length);
                int sampleStepX = Math.Max(1, bitmap.Width / 64);
                int sampleStepY = Math.Max(1, bitmap.Height / 64);

                for (int y = 0; y < bitmap.Height; y++)
                {
                    int row = data.Stride >= 0 ? y * rowLength : (bitmap.Height - 1 - y) * rowLength;
                    for (int x = 0; x < bitmap.Width; x++)
                    {
                        int offset = row + (x * 4);
                        int blue = bytes[offset];
                        int green = bytes[offset + 1];
                        int red = bytes[offset + 2];
                        int alpha = bytes[offset + 3];

                        if (alpha == 0)
                        {
                            result.TransparentPixels++;
                        }
                        else
                        {
                            result.MinContentX = Math.Min(result.MinContentX, x);
                            result.MinContentY = Math.Min(result.MinContentY, y);
                            result.MaxContentX = Math.Max(result.MaxContentX, x);
                            result.MaxContentY = Math.Max(result.MaxContentY, y);
                        }
                        if (alpha < 255)
                        {
                            result.NonOpaquePixels++;
                        }

                        if (alpha >= 32 && (green >= red + 12 || blue >= red + 12))
                        {
                            result.ColoredPixels++;
                        }

                        if ((x % sampleStepX) == 0 && (y % sampleStepY) == 0)
                        {
                            sampledColors.Add((alpha << 24) | (red << 16) | (green << 8) | blue);
                        }
                    }
                }

                result.SampledColorCount = sampledColors.Count;
                result.CornersOpaque = AlphaAt(bytes, data.Stride, rowLength, bitmap.Height, 0, 0) == 255
                    && AlphaAt(bytes, data.Stride, rowLength, bitmap.Height, bitmap.Width - 1, 0) == 255
                    && AlphaAt(bytes, data.Stride, rowLength, bitmap.Height, 0, bitmap.Height - 1) == 255
                    && AlphaAt(bytes, data.Stride, rowLength, bitmap.Height, bitmap.Width - 1, bitmap.Height - 1) == 255;
            }
            finally
            {
                bitmap.UnlockBits(data);
            }

            return result;
        }
    }

    public static long CountCompositionDifferences(string backgroundPath, string foregroundPath, string storePath)
    {
        using (var background = new Bitmap(backgroundPath))
        using (var foreground = new Bitmap(foregroundPath))
        using (var store = new Bitmap(storePath))
        using (var expected = new Bitmap(1024, 1024, PixelFormat.Format32bppArgb))
        {
            using (var graphics = Graphics.FromImage(expected))
            {
                graphics.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
                graphics.DrawImageUnscaled(background, 0, 0);
                graphics.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceOver;
                graphics.DrawImageUnscaled(foreground, 0, 0);
            }

            if (store.Width != expected.Width || store.Height != expected.Height)
            {
                return (long)expected.Width * expected.Height;
            }

            using (var actual = new Bitmap(store.Width, store.Height, PixelFormat.Format32bppArgb))
            {
                using (var graphics = Graphics.FromImage(actual))
                {
                    graphics.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
                    graphics.DrawImageUnscaled(store, 0, 0);
                }

                var rectangle = new Rectangle(0, 0, expected.Width, expected.Height);
                BitmapData expectedData = null;
                BitmapData actualData = null;
                try
                {
                    expectedData = expected.LockBits(rectangle, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
                    actualData = actual.LockBits(rectangle, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
                    int expectedRowLength = Math.Abs(expectedData.Stride);
                    int actualRowLength = Math.Abs(actualData.Stride);
                    var expectedBytes = new byte[expectedRowLength * expected.Height];
                    var actualBytes = new byte[actualRowLength * actual.Height];
                    Marshal.Copy(expectedData.Scan0, expectedBytes, 0, expectedBytes.Length);
                    Marshal.Copy(actualData.Scan0, actualBytes, 0, actualBytes.Length);

                    long differences = 0;
                    for (int y = 0; y < expected.Height; y++)
                    {
                        int expectedRow = expectedData.Stride >= 0 ? y * expectedRowLength : (expected.Height - 1 - y) * expectedRowLength;
                        int actualRow = actualData.Stride >= 0 ? y * actualRowLength : (actual.Height - 1 - y) * actualRowLength;
                        for (int x = 0; x < expected.Width; x++)
                        {
                            int expectedOffset = expectedRow + (x * 4);
                            int actualOffset = actualRow + (x * 4);
                            if (expectedBytes[expectedOffset] != actualBytes[actualOffset]
                                || expectedBytes[expectedOffset + 1] != actualBytes[actualOffset + 1]
                                || expectedBytes[expectedOffset + 2] != actualBytes[actualOffset + 2]
                                || expectedBytes[expectedOffset + 3] != actualBytes[actualOffset + 3])
                            {
                                differences++;
                            }
                        }
                    }

                    return differences;
                }
                finally
                {
                    if (actualData != null) actual.UnlockBits(actualData);
                    if (expectedData != null) expected.UnlockBits(expectedData);
                }
            }
        }
    }

    private static int AlphaAt(byte[] bytes, int stride, int rowLength, int height, int x, int y)
    {
        int row = stride >= 0 ? y * rowLength : (height - 1 - y) * rowLength;
        return bytes[row + (x * 4) + 3];
    }
}
'@

function Add-Failure {
  param([string]$Message)
  $failures.Add($Message)
}

function Get-IconMetrics {
  param([string]$RelativePath)

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure "Missing icon asset: $RelativePath"
    return $null
  }

  try {
    return [IconPixelInspector]::Analyze($path)
  } catch {
    Add-Failure "Unable to inspect PNG $RelativePath`: $($_.Exception.Message)"
    return $null
  }
}

function Test-ExactDimensions {
  param([string]$RelativePath, [IconPixelMetrics]$Metrics)

  if ($null -ne $Metrics -and ($Metrics.Width -ne 1024 -or $Metrics.Height -ne 1024)) {
    Add-Failure "$RelativePath must be exactly 1024x1024; found $($Metrics.Width)x$($Metrics.Height)."
  }
}

function Test-ForegroundLayer {
  param([string]$RelativePath, [IconPixelMetrics]$Metrics)

  if ($null -eq $Metrics) {
    return
  }

  $pixelCount = [long]$Metrics.Width * [long]$Metrics.Height
  if ($Metrics.TransparentPixels -lt [long]($pixelCount * 0.50)) {
    Add-Failure "$RelativePath must retain substantial transparency; found $($Metrics.TransparentPixels) fully transparent pixels."
  }
  if ($Metrics.ColoredPixels -lt 1000) {
    Add-Failure "$RelativePath must contain substantial visible colored foreground pixels; found $($Metrics.ColoredPixels)."
  }
  if ($Metrics.SampledColorCount -lt 16) {
    Add-Failure "$RelativePath must contain at least 16 sampled colors; found $($Metrics.SampledColorCount)."
  }
  $safeInset = 80
  if ($Metrics.MinContentX -lt $safeInset -or $Metrics.MinContentY -lt $safeInset -or
      $Metrics.MaxContentX -gt ($Metrics.Width - $safeInset - 1) -or
      $Metrics.MaxContentY -gt ($Metrics.Height - $safeInset - 1)) {
    Add-Failure "$RelativePath alpha-content must stay inside the ${safeInset}px safe inset; found x=$($Metrics.MinContentX)..$($Metrics.MaxContentX), y=$($Metrics.MinContentY)..$($Metrics.MaxContentY)."
  }
}

function Test-BackgroundLayer {
  param([string]$RelativePath, [IconPixelMetrics]$Metrics)

  if ($null -eq $Metrics) {
    return
  }

  if ($Metrics.NonOpaquePixels -ne 0 -or -not $Metrics.CornersOpaque) {
    Add-Failure "$RelativePath must be fully opaque with all four corners covered; found $($Metrics.NonOpaquePixels) non-opaque pixels."
  }
  if ($Metrics.SampledColorCount -lt 32) {
    Add-Failure "$RelativePath must be a full-canvas textured background, not a solid placeholder; sampled $($Metrics.SampledColorCount) colors."
  }
}

function Test-StoreIconComposition {
  param(
    [string]$BackgroundRelativePath,
    [string]$ForegroundRelativePath,
    [string]$StoreRelativePath
  )

  $backgroundPath = Join-Path $projectRoot $BackgroundRelativePath
  $foregroundPath = Join-Path $projectRoot $ForegroundRelativePath
  $storePath = Join-Path $projectRoot $StoreRelativePath
  foreach ($assetPath in @($backgroundPath, $foregroundPath, $storePath)) {
    if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) {
      return
    }
  }

  try {
    $differenceCount = [IconPixelInspector]::CountCompositionDifferences(
      $backgroundPath,
      $foregroundPath,
      $storePath
    )
    if ($differenceCount -ne 0) {
      Add-Failure "$StoreRelativePath must exactly match the composed app icon layers; found $differenceCount differing pixels."
    }
  } catch {
    Add-Failure "Unable to compare store icon composition $StoreRelativePath`: $($_.Exception.Message)"
  }
}

function Test-LayerDescriptor {
  param(
    [string]$RelativePath,
    [string]$ExpectedBackground,
    [string]$ExpectedForeground
  )

  $path = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure "Missing layered icon descriptor: $RelativePath"
    return
  }

  try {
    $descriptor = Get-Content -LiteralPath $path -Encoding UTF8 -Raw | ConvertFrom-Json
    $rootProperties = @($descriptor.PSObject.Properties.Name)
    $layered = $descriptor.'layered-image'
    $layerProperties = @($layered.PSObject.Properties.Name)
    if ($rootProperties.Count -ne 1 -or $rootProperties[0] -ne 'layered-image' -or
        $null -eq $layered -or $layerProperties.Count -ne 2 -or
        $layerProperties -notcontains 'background' -or $layerProperties -notcontains 'foreground' -or
        $layered.background -cne $ExpectedBackground -or $layered.foreground -cne $ExpectedForeground) {
      Add-Failure "$RelativePath must contain only exact layered-image refs background=$ExpectedBackground and foreground=$ExpectedForeground."
    }
  } catch {
    Add-Failure "Invalid layered icon descriptor $RelativePath`: $($_.Exception.Message)"
  }
}

$layerAssets = @(
  @{ Path = 'AppScope/resources/base/media/app_icon_background.png'; Kind = 'background' },
  @{ Path = 'AppScope/resources/base/media/app_icon_foreground.png'; Kind = 'foreground' },
  @{ Path = 'entry/src/main/resources/base/media/icon_background.png'; Kind = 'background' },
  @{ Path = 'entry/src/main/resources/base/media/icon_foreground.png'; Kind = 'foreground' }
)

foreach ($asset in $layerAssets) {
  $metrics = Get-IconMetrics $asset.Path
  Test-ExactDimensions $asset.Path $metrics
  if ($asset.Kind -eq 'background') {
    Test-BackgroundLayer $asset.Path $metrics
  } else {
    Test-ForegroundLayer $asset.Path $metrics
  }
}

$storeIconPath = 'docs/release/appgallery-icon.png'
$storeIconMetrics = Get-IconMetrics $storeIconPath
Test-ExactDimensions $storeIconPath $storeIconMetrics
Test-BackgroundLayer $storeIconPath $storeIconMetrics
Test-StoreIconComposition `
  'AppScope/resources/base/media/app_icon_background.png' `
  'AppScope/resources/base/media/app_icon_foreground.png' `
  $storeIconPath

Test-LayerDescriptor 'AppScope/resources/base/media/app_icon.json' '$media:app_icon_background' '$media:app_icon_foreground'
Test-LayerDescriptor 'entry/src/main/resources/base/media/layered_image.json' '$media:icon_background' '$media:icon_foreground'

$obsoleteIcon = Join-Path $projectRoot 'AppScope/resources/base/media/app_icon.png'
if (Test-Path -LiteralPath $obsoleteIcon) {
  Add-Failure 'AppScope/resources/base/media/app_icon.png must be absent to avoid a duplicate app_icon base resource name.'
}

$appManifestPath = Join-Path $projectRoot 'AppScope/app.json5'
try {
  $appManifest = Get-Content -LiteralPath $appManifestPath -Encoding UTF8 -Raw | ConvertFrom-Json
  if ($appManifest.app.icon -cne '$media:app_icon') {
    Add-Failure 'AppScope/app.json5 must keep icon=$media:app_icon.'
  }
} catch {
  Add-Failure "Unable to validate AppScope/app.json5: $($_.Exception.Message)"
}

$moduleManifestPath = Join-Path $projectRoot 'entry/src/main/module.json5'
try {
  $moduleManifest = Get-Content -LiteralPath $moduleManifestPath -Encoding UTF8 -Raw | ConvertFrom-Json
  $entryAbility = @($moduleManifest.module.abilities | Where-Object { $_.name -ceq 'EntryAbility' })
  if ($entryAbility.Count -ne 1) {
    Add-Failure 'entry/src/main/module.json5 must declare exactly one EntryAbility.'
  } else {
    if ($entryAbility[0].icon -cne '$media:layered_image') {
      Add-Failure 'EntryAbility icon must reference $media:layered_image.'
    }
    if ($entryAbility[0].startWindowIcon -cne '$media:startIcon') {
      Add-Failure 'EntryAbility startWindowIcon must remain $media:startIcon.'
    }
  }
} catch {
  Add-Failure "Unable to validate entry/src/main/module.json5: $($_.Exception.Message)"
}

$startIconMetrics = Get-IconMetrics 'entry/src/main/resources/base/media/startIcon.png'
if ($null -ne $startIconMetrics -and
    ($startIconMetrics.Width -ne 216 -or $startIconMetrics.Height -ne 216)) {
  Add-Failure "entry/src/main/resources/base/media/startIcon.png must match the project startup-icon size 216x216, found $($startIconMetrics.Width)x$($startIconMetrics.Height)."
}

$matchingLayerPairs = @(
  @('AppScope/resources/base/media/app_icon_background.png', 'entry/src/main/resources/base/media/icon_background.png'),
  @('AppScope/resources/base/media/app_icon_foreground.png', 'entry/src/main/resources/base/media/icon_foreground.png')
)
foreach ($pair in $matchingLayerPairs) {
  $firstPath = Join-Path $projectRoot $pair[0]
  $secondPath = Join-Path $projectRoot $pair[1]
  if ((Test-Path -LiteralPath $firstPath -PathType Leaf) -and (Test-Path -LiteralPath $secondPath -PathType Leaf)) {
    $firstHash = (Get-FileHash -LiteralPath $firstPath -Algorithm SHA256).Hash
    $secondHash = (Get-FileHash -LiteralPath $secondPath -Algorithm SHA256).Hash
    if ($firstHash -cne $secondHash) {
      Add-Failure "$($pair[0]) and $($pair[1]) must be pixel-identical (SHA-256 mismatch)."
    }
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  throw "Icon asset contract failed with $($failures.Count) issue(s)."
}

Write-Host 'Icon asset contract passed.' -ForegroundColor Green
