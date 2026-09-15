param(
    [string]$SkillRoot = 'C:\Users\27363\.agents\skills\harmonyos-self-check'
)

$ErrorActionPreference = 'Stop'

$resolvedRoot = (Resolve-Path -LiteralPath $SkillRoot).Path
$skillPath = Join-Path $resolvedRoot 'SKILL.md'
$metadataPath = Join-Path $resolvedRoot 'agents\openai.yaml'
$referencePath = Join-Path $resolvedRoot 'references\release-preflight-cases.md'
$failures = [System.Collections.Generic.List[string]]::new()
$passes = [System.Collections.Generic.List[string]]::new()

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if ($Condition) {
        $script:passes.Add($Message)
    } else {
        $script:failures.Add($Message)
    }
}

function Assert-ContainsAll {
    param(
        [string]$Content,
        [string[]]$Terms,
        [string]$Context
    )

    foreach ($term in $Terms) {
        $containsTerm = $Content.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
        Assert-True -Condition $containsTerm -Message "$Context contains '$term'"
    }
}

Assert-True -Condition (Test-Path -LiteralPath $skillPath -PathType Leaf) -Message 'SKILL.md exists'
Assert-True -Condition (Test-Path -LiteralPath $metadataPath -PathType Leaf) -Message 'agents/openai.yaml exists'
Assert-True -Condition (Test-Path -LiteralPath $referencePath -PathType Leaf) -Message 'references/release-preflight-cases.md exists'

if (Test-Path -LiteralPath $skillPath -PathType Leaf) {
    $skillContent = Get-Content -Raw -Encoding utf8 $skillPath
    Assert-ContainsAll -Content $skillContent -Terms @(
        'release-preflight-cases.md',
        'classification',
        'tags',
        'filing',
        'qualifications',
        'dark mode',
        'status bar',
        'safe area'
    ) -Context 'SKILL.md'
}

if (Test-Path -LiteralPath $metadataPath -PathType Leaf) {
    $metadataContent = Get-Content -Raw -Encoding utf8 $metadataPath
    Assert-ContainsAll -Content $metadataContent -Terms @(
        'display_name:',
        '$harmonyos-self-check',
        'classification',
        'qualifications'
    ) -Context 'agents/openai.yaml'
}

if (Test-Path -LiteralPath $referencePath -PathType Leaf) {
    $referenceContent = Get-Content -Raw -Encoding utf8 $referencePath

    Assert-ContainsAll -Content $referenceContent -Terms @(
        'displacement',
        'clipping',
        'deformation',
        'blur',
        'obscured',
        'blank area',
        'close control',
        'bottom fixed controls',
        'input keyboard',
        'floating action button',
        'scroll content',
        'half-modal',
        'actual system inset',
        '28vp',
        'text',
        'images',
        'component backgrounds',
        'status bar',
        'classification',
        'tags',
        'APP filing',
        'Value-Added Telecommunications Business License',
        'software copyright',
        'Version information > Copyright information',
        'unverified',
        '0204198786161369031',
        '0201210072264559504',
        '0214200865840885234',
        '0214200867142227235',
        'classify-1',
        '/80301'
    ) -Context 'release preflight reference'

    Assert-True -Condition ($referenceContent -match '28vp.{0,160}(FAQ|operational guidance)' -or $referenceContent -match '(FAQ|operational guidance).{0,160}28vp') -Message '28vp is qualified as FAQ operational guidance'
    Assert-True -Condition ($referenceContent -notmatch '(?<![0-9])3:1(?![0-9])') -Message 'reference does not duplicate the existing 3:1 threshold'
    Assert-True -Condition ($referenceContent -notmatch '(?<![0-9])4\.5:1(?![0-9])') -Message 'reference does not duplicate the existing 4.5:1 threshold'
    Assert-True -Condition ($referenceContent -notmatch '\|\s*13\s*\|') -Message 'reference does not duplicate the 13-chapter review table'
}

foreach ($message in $passes) {
    Write-Host "[PASS] $message"
}

foreach ($message in $failures) {
    Write-Error "[FAIL] $message" -ErrorAction Continue
}

if ($failures.Count -gt 0) {
    Write-Host "HarmonyOS self-check skill contract failed: $($failures.Count) assertion(s)."
    exit 1
}

Write-Host "HarmonyOS self-check skill contract passed: $($passes.Count) assertion(s)."
