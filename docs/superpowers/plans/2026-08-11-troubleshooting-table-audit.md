# HarmonyOS Troubleshooting Table Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Audit all 11 findings in `C:\Users\27363\Desktop\鸿蒙问题排查表.md`, fix every finding that applies to the LED banner and still exists, and document reproducible evidence for applicable and inapplicable findings.

**Architecture:** Keep the application on its existing fixed dark visual system and non-fullscreen ordinary-page window model. Strengthen the two remaining acceptance boundaries at their sources: reserve at least 28vp beneath ordinary-page controls and give switches explicit state colors that do not depend on the device light/dark theme. Reuse the existing static contracts for app identity, layered icons, system bars, responsive layout, minimum typography, contrast, business behavior, and package metadata.

**Tech Stack:** HarmonyOS Stage model, ArkTS/ArkUI, PowerShell regression contracts, Hvigor, HDC device validation.

---

## File Structure

- Modify `scripts/test-responsive-layout.ps1`: make the 28vp bottom-clearance requirement executable.
- Modify `scripts/test-accessibility-contract.ps1`: verify switch track/thumb contrast and the modifier chain applied to the real home-page switch.
- Modify `entry/src/main/ets/common/Theme.ets`: centralize the settings-panel and explicit switch colors; raise shared bottom padding to 28vp.
- Modify `entry/src/main/ets/pages/Index.ets`: consume shared settings-panel and switch colors.
- Create `docs/qa/2026-08-11-troubleshooting-table-audit.md`: record verdict, evidence, fix, and limitations for all 11 source findings.
- Modify `design.md`, `changes.md`, `design-qa.md`, and `tasks.md`: complete the project-required design, change, QA, and task records.

The repository already contains user-owned uncommitted changes. This plan does not create commits, so it cannot accidentally bundle or rewrite unrelated work.

---

### Task 1: Reproduce the remaining bottom-clearance and switch-theme gaps

**Files:**
- Modify: `scripts/test-responsive-layout.ps1`
- Modify: `scripts/test-accessibility-contract.ps1`

- [x] **Step 1: Raise the responsive contract from 24vp to the reported 28vp minimum**

Change the shared constant assertion to:

```powershell
'SYSTEM_BOTTOM_PADDING: number = 28'
```

- [x] **Step 2: Add switch color and real-control-chain assertions**

Add these contrast checks after the existing display overlay assertion:

```powershell
Assert-Contrast $themeColors 'TOGGLE_OFF_TRACK' 'SETTING_PANEL_BG' 3.0
Assert-Contrast $themeColors 'TOGGLE_THUMB' 'TOGGLE_OFF_TRACK' 3.0
Assert-Contrast $themeColors 'TOGGLE_THUMB' 'ACCENT' 3.0
```

Add this contract after `Index.ets` is loaded:

```powershell
$indexToggleContract = @{
  Content = $indexContent
  RelativePath = $indexPath
  Control = 'settings switch'
  IdentityPatterns = @('(?m)^Toggle\(')
  RequiredStatementPatterns = @(
    '^\.selectedColor\(\s*AppTheme\.ACCENT\s*\)$',
    '(?s)^\.switchStyle\(\s*\{\s*unselectedColor:\s*AppTheme\.TOGGLE_OFF_TRACK,\s*pointColor:\s*AppTheme\.TOGGLE_THUMB\s*\}\s*\)$'
  )
}
Assert-ControlChainContract @indexToggleContract
```

- [x] **Step 3: Run the two contracts and verify RED**

Run:

```powershell
.\scripts\test-responsive-layout.ps1
.\scripts\test-accessibility-contract.ps1
```

Expected: responsive layout fails because `SYSTEM_BOTTOM_PADDING` is still 24; accessibility fails because the switch theme constants and `switchStyle` modifier are absent.

---

### Task 2: Apply the minimum root-cause fixes

**Files:**
- Modify: `entry/src/main/ets/common/Theme.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [x] **Step 1: Centralize settings and switch colors and raise the clearance**

Add the color constants beside the other surface/control colors and update the padding:

```typescript
static readonly SETTING_PANEL_BG: string = '#091426'
static readonly TOGGLE_OFF_TRACK: string = '#8793A8'
static readonly TOGGLE_THUMB: string = '#00131A'
static readonly SYSTEM_BOTTOM_PADDING: number = 28
```

The contrast targets are 5.94:1 for the off track against the panel, 6.11:1 for the thumb against the off track, and 12.32:1 for the thumb against the selected accent track.

- [x] **Step 2: Apply the explicit switch style on the real home-page control**

Replace the hard-coded settings panel background and extend the existing Toggle chain:

```typescript
.backgroundColor(AppTheme.SETTING_PANEL_BG)
```

```typescript
Toggle({ type: ToggleType.Switch, isOn: enabled })
  .width(42)
  .height(24)
  .selectedColor(AppTheme.ACCENT)
  .switchStyle({ unselectedColor: AppTheme.TOGGLE_OFF_TRACK, pointColor: AppTheme.TOGGLE_THUMB })
  .onChange((value: boolean) => change(value))
```

- [x] **Step 3: Run the focused contracts and verify GREEN**

Run:

```powershell
.\scripts\test-responsive-layout.ps1
.\scripts\test-accessibility-contract.ps1
.\scripts\test-arkts-compile.ps1
```

Expected: both contracts pass and ArkTS debug compilation finishes successfully without source warnings.

---

### Task 3: Record all 11 audit verdicts

**Files:**
- Create: `docs/qa/2026-08-11-troubleshooting-table-audit.md`
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`
- Modify: `tasks.md`

- [x] **Step 1: Write the complete finding matrix**

The QA report must contain one row for every numbered finding with one of these explicit verdicts:

```text
1: Applicable, remaining 24vp clearance fixed to 28vp.
2: Applicable category, current fixed palette and switch colors verified in light mode.
3: Not applicable; the app has no reminder/proxy reminder feature.
4: Applicable, already resolved; AppScope and EntryAbility layered icon descriptors and PNG layers match.
5: Applicable, already resolved; AppScope, EntryAbility, and home title all use 光迹字幕.
6: Applicable, already resolved; ordinary pages are non-fullscreen and display mode alone is fullscreen.
7: Applicable, already resolved; fixed operational UI text is at least 12fp.
8: Applicable category, already resolved; pages use relative/full widths, shared padding, max-width constraints, and scroll containment.
9: Applicable, already resolved; fixed dark palette passes the contrast contract.
10: Not applicable; there are no default list/grid, calendar event, holiday, billing, or statistics features.
11: Partly applicable category; focus/clock/white-noise examples are absent, while the app's own switches receive explicit light/dark-independent colors.
```

- [x] **Step 2: Update required project records**

Add dated sections describing the 28vp change, explicit switch state colors, applicability boundary, contract results, build result, device target(s), and any unavailable tablet/2in1 evidence. Mark `T-20260811-002` done only after all verification commands finish successfully.

---

### Task 4: Full verification and device evidence

**Files:**
- Verify: `entry/build/default/outputs/default/entry-default-unsigned.hap`
- Optionally create evidence under `docs/qa/` only when a connected target is available.

- [x] **Step 1: Run every local acceptance gate**

Run:

```powershell
.\scripts\check-standard.ps1
.\scripts\test-arkts-compile.ps1
.\scripts\test-parse.ps1
.\scripts\test-ui-contract.ps1
.\scripts\test-business-contract.ps1
.\scripts\build-harmony.ps1
```

Expected: all commands exit 0; Hvigor reports `BUILD SUCCESSFUL`; the only permitted build notice is that tracked signing configuration is intentionally absent.

- [x] **Step 2: Install and inspect on every available target**

Run for each result from `hdc list targets`:

```powershell
hdc -t <target> install -r entry/build/default/outputs/default/entry-default-unsigned.hap
hdc -t <target> shell aa start -a EntryAbility -b com.ledscroll.banner
hdc -t <target> shell uiautomator dump
```

Verify that ordinary-page bounds do not enter the status/navigation system regions, bottom navigation remains visible above the system navigation region, the home switch is visually distinguishable off and on, and no content is clipped at the left or right edge. Enter `pages/DisplayPage`, verify full-screen bounds, then go Back and verify ordinary-page chrome restoration.

- [x] **Step 3: Re-read the source table and close the task**

Compare all 11 source findings with the completed matrix, confirm there is exactly one verdict per number, then update `T-20260811-002` to `done` with fresh command outputs and device limitations.
