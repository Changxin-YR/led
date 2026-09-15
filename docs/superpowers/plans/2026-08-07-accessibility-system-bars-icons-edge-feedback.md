# Accessibility, System Bars, Layered Icons, and Edge Feedback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the HarmonyOS app satisfy the audit requirements for UI contrast, immersive status bars, layered 1024x1024 icons, and scroll-boundary feedback.

**Architecture:** Keep policy in shared contracts: colors remain in `AppTheme`, window state remains in `ScreenService`, and regression rules remain in PowerShell scripts. Pages only consume compliant shared colors and opt their real scrolling containers into ArkUI spring edge effects. Launcher artwork becomes a standard HarmonyOS `layered-image` resource while the splash icon remains a bitmap.

**Tech Stack:** HarmonyOS Stage model, ArkTS/ArkUI, HarmonyOS media resources, PowerShell regression scripts, DevEco/Hvigor build.

---

### Task 1: Add a failing accessibility contrast contract

**Files:**
- Create: `scripts/test-accessibility-contract.ps1`
- Modify: `scripts/check-standard.ps1`
- Modify later in this task: `entry/src/main/ets/common/Theme.ets`
- Modify later in this task: `entry/src/main/ets/pages/Index.ets`
- Modify later in this task: `entry/src/main/ets/pages/TemplatePage.ets`
- Modify later in this task: `entry/src/main/ets/pages/ColorPickerPage.ets`
- Modify later in this task: `entry/src/main/ets/pages/CounterPage.ets`

- [ ] **Step 1: Write the contrast test before changing colors**

Create a PowerShell test that parses the hex constants from `Theme.ets`, implements WCAG sRGB relative luminance, and asserts these pairs:

```powershell
Assert-Contrast 'TEXT_PRIMARY on PAGE_BG' $theme.TEXT_PRIMARY $theme.PAGE_BG 4.5
Assert-Contrast 'TEXT_SECONDARY on SURFACE_RAISED' $theme.TEXT_SECONDARY $theme.SURFACE_RAISED 4.5
Assert-Contrast 'TEXT_MUTED on SURFACE_RAISED' $theme.TEXT_MUTED $theme.SURFACE_RAISED 4.5
Assert-Contrast 'ON_ACCENT on ACCENT' $theme.ON_ACCENT $theme.ACCENT 4.5
Assert-Contrast 'ON_ACCENT on ACCENT_BLUE' $theme.ON_ACCENT $theme.ACCENT_BLUE 4.5
Assert-Contrast 'ON_ACCENT on DANGER' $theme.ON_ACCENT $theme.DANGER 4.5
Assert-Contrast 'ON_ACCENT on SUCCESS' $theme.ON_ACCENT $theme.SUCCESS 4.5
```

Also assert that fixed UI controls no longer use `#FFFFFF` on `AppTheme.ACCENT`, `ACCENT_BLUE`, `DANGER`, `SUCCESS`, `#05BDEB`, `#05BFE7`, or `#04BCEB`.

- [ ] **Step 2: Run the test and verify RED**

Run:

```powershell
.\scripts\test-accessibility-contract.ps1
```

Expected: FAIL because `ON_ACCENT` is absent, `TEXT_MUTED` is only 3.60:1 on `SURFACE_RAISED`, and bright buttons/selected controls use white foregrounds.

- [ ] **Step 3: Implement the minimal shared color fix**

Update `AppTheme`:

```typescript
static readonly TEXT_MUTED: string = '#8793A8'
static readonly ON_ACCENT: string = '#00131A'
```

Use `AppTheme.ON_ACCENT` for the selected mode label, start button, selected template category, template start button, color confirmation button, and counter plus/minus symbols. Preserve white text where the background is dark or opaque black.

- [ ] **Step 4: Register and run the test to verify GREEN**

Add the test to `scripts/check-standard.ps1`, then run:

```powershell
.\scripts\test-accessibility-contract.ps1
.\scripts\test-ui-contract.ps1
```

Expected: both scripts pass.

### Task 2: Tighten the immersive status-bar contract

**Files:**
- Modify: `scripts/test-window-layout.ps1`
- Modify: `entry/src/main/ets/common/Theme.ets`
- Modify: `entry/src/main/ets/services/ScreenService.ets`

- [ ] **Step 1: Add failing window assertions**

Require the common theme and window service to contain:

```text
SYSTEM_STATUS_BAR: string = '#00000000'
setWindowLayoutFullScreen(true)
statusBarContentColor: AppTheme.TEXT_PRIMARY
isStatusBarLightIcon: true
navigationBarContentColor: AppTheme.TEXT_PRIMARY
isNavigationBarLightIcon: true
```

Keep the existing assertion that normal page roots expand a single `PAGE_BG` through top and bottom system safe areas, and keep `DisplayPage` fullscreen behavior.

- [ ] **Step 2: Run the window test and verify RED**

Run:

```powershell
.\scripts\test-window-layout.ps1
```

Expected: FAIL because the current status bar color is opaque `#030A16` and the test does not yet prove all content-color fields.

- [ ] **Step 3: Make the status bar transparent over the uniform page background**

Set:

```typescript
static readonly SYSTEM_STATUS_BAR: string = '#00000000'
```

Keep the navigation bar equal to `PAGE_BG`, preserve the existing light icon/content properties, and do not change `enterDisplayMode()` system-bar hiding.

- [ ] **Step 4: Run the window test and verify GREEN**

Run:

```powershell
.\scripts\test-window-layout.ps1
```

Expected: PASS.

### Task 3: Add spring feedback to every real scroll boundary

**Files:**
- Modify: `scripts/test-ui-contract.ps1`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/TemplatePage.ets`
- Modify: `entry/src/main/ets/pages/HistoryPage.ets`
- Modify: `entry/src/main/ets/pages/ColorPickerPage.ets`

- [ ] **Step 1: Add failing per-container UI assertions**

For the five actual scrolling containers, require this modifier after the existing scrollbar modifier:

```typescript
.edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
```

The five containers are `Index` main `Scroll`, `ColorPickerPage` main `Scroll`, `TemplatePage` horizontal category `Scroll`, `TemplatePage` template `Grid`, and `HistoryPage` record `List`. Do not require it on the two non-scrolling option grids nested inside the home page scroll.

- [ ] **Step 2: Run the UI contract and verify RED**

Run:

```powershell
.\scripts\test-ui-contract.ps1
```

Expected: FAIL with one message for each missing scrolling-container edge effect.

- [ ] **Step 3: Add the ArkUI spring modifiers**

Add the exact modifier to each of the five containers without changing sizes, data flow, or scroll direction.

- [ ] **Step 4: Run the UI contract and ArkTS compile to verify GREEN**

Run:

```powershell
.\scripts\test-ui-contract.ps1
.\scripts\test-arkts-compile.ps1
```

Expected: both pass, confirming the modifier signature is accepted by the configured SDK.

### Task 4: Replace the launcher icon with standard layered resources

**Files:**
- Modify: `scripts/test-icon-assets.ps1`
- Create: `scripts/generate-layered-icon.ps1`
- Delete: `AppScope/resources/base/media/app_icon.png`
- Create: `AppScope/resources/base/media/app_icon.json`
- Create: `AppScope/resources/base/media/app_icon_background.png`
- Create: `AppScope/resources/base/media/app_icon_foreground.png`
- Create: `entry/src/main/resources/base/media/layered_image.json`
- Create: `entry/src/main/resources/base/media/icon_background.png`
- Create: `entry/src/main/resources/base/media/icon_foreground.png`
- Modify: `entry/src/main/module.json5`
- Preserve: `entry/src/main/resources/base/media/startIcon.png`

- [ ] **Step 1: Rewrite the icon contract before changing resources**

Require exact 1024x1024 dimensions for all four layer PNGs. Require transparent pixels in each foreground, opaque corner pixels in each background, and at least 16 sampled colors per layer. Require these JSON structures:

```json
{
  "layered-image": {
    "background": "$media:app_icon_background",
    "foreground": "$media:app_icon_foreground"
  }
}
```

```json
{
  "layered-image": {
    "background": "$media:icon_background",
    "foreground": "$media:icon_foreground"
  }
}
```

Require `AppScope/app.json5` to retain `$media:app_icon`, require the Ability `icon` to reference `$media:layered_image`, and require `startWindowIcon` to remain `$media:startIcon`.

- [ ] **Step 2: Run the icon test and verify RED**

Run:

```powershell
.\scripts\test-icon-assets.ps1
```

Expected: FAIL because the layered JSON and layer PNG files do not exist and the Ability still references the flat splash bitmap.

- [ ] **Step 3: Generate the two source layers reproducibly**

The built-in image generator is unavailable in this session and the CLI fallback requires separate credentials, so use a local `System.Drawing` generator instead of a network fallback. The script must render original 1024x1024 bitmap layers that preserve the current dark blue/cyan LED identity:

```text
Background: full-bleed square deep navy-to-black field, subtle cyan glow and fine dot-matrix texture, no rounded-square frame, no logo text, no transparent corners, no margin.
Foreground: transparent 1024x1024 canvas, large cyan LED dot-matrix word LED with minimal display accents extending across the canvas, no rounded-square container, no opaque background, no pre-masked corner, and no padding added for system masking.
```

The script must write the AppScope layer files, then copy identical pixels to the entry resource names. It must dispose all drawing objects and replace resources deterministically when re-run.

- [ ] **Step 4: Add standard HarmonyOS layered-image descriptors and update the Ability icon**

Create the two JSON resources exactly as shown in Step 1. Change only the Ability icon line in `module.json5`:

```json5
"icon": "$media:layered_image",
```

Do not alter bundle name, app ID, version, signing, or start-window settings.

- [ ] **Step 5: Run icon, standard, and build checks to verify GREEN**

Run:

```powershell
.\scripts\test-icon-assets.ps1
.\scripts\check-standard.ps1
.\scripts\build-harmony.ps1
```

Expected: all pass and the HAP contains the layered media resource.

### Task 5: Update design records and perform full verification

**Files:**
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`
- Modify: `tasks.md`
- Create only when device verification succeeds: `docs/qa/2026-08-07-*.jpeg`

- [ ] **Step 1: Document the implemented visual and interaction rules**

Append dated sections that record exact color ratios, system-bar behavior, layered resource names, edge-effect coverage, and any device limitations. Do not overwrite earlier audit history.

- [ ] **Step 2: Run the complete fresh verification suite**

Run:

```powershell
.\scripts\check-standard.ps1
.\scripts\build-harmony.ps1
```

Expected: exit code 0 for both.

- [ ] **Step 3: Verify on the available HarmonyOS device**

Install the debug HAP, launch `com.ledscroll.banner/EntryAbility`, and verify:

```text
Home: status region is the same deep background as the page; status text/icons are light and readable.
Home/Color: dragging at top and bottom produces spring feedback.
Templates: dragging category tabs at left/right and grid at top/bottom produces spring feedback.
History with records: dragging at top/bottom produces spring feedback.
Launcher: the layered LED icon renders without source-file rounded corners or double masking.
DisplayPage: system bars remain hidden; returning restores the app chrome.
```

Capture screenshots only if they contain no sensitive information.

- [ ] **Step 4: Close the task records**

Set `T-20260807-001` to `done` only if static checks, build, and available-device verification have evidence. Otherwise mark only the unavailable device rows as `waiting` in `design-qa.md` and report the exact limitation.
