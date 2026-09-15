# Distinctive App Name Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the generic installed name with the approved distinctive name `光迹字幕` across launcher, Ability/recent task, and visible home title.

**Architecture:** The AppScope name remains the source for the launcher, and the entry resource keeps Ability labels aligned with it. The home title uses two existing `Text` spans for its two-color treatment, so only their literals change and the rendered name contains no space.

**Tech Stack:** HarmonyOS Stage resources, ArkTS/ArkUI, PowerShell acceptance contracts, Hvigor, HDC.

---

### Task 1: Lock the Approved Name

**Files:**
- Modify: `scripts/test-appgallery-acceptance.ps1:31-37`
- Test: `scripts/test-appgallery-acceptance.ps1`

- [x] **Step 1: Write the failing contract**

```powershell
$expectedDisplayName = -join [char[]](20809, 36857, 23383, 24149)
Assert-Equal $appName $expectedDisplayName "AppScope app_name"
Assert-Equal $entryLabel $expectedDisplayName "EntryAbility_label"
Assert-Equal $entryDescription $expectedDisplayName "EntryAbility_desc"
$indexPage = Read-ProjectFile "entry/src/main/ets/pages/Index.ets"
if (-not $indexPage.Contains("Text('光迹')") -or -not $indexPage.Contains("Text('字幕')")) {
  $failures.Add('Index title must render the approved app name as 光迹字幕.')
}
```

- [x] **Step 2: Verify the contract fails**

Run: `powershell -ExecutionPolicy Bypass -File scripts/test-appgallery-acceptance.ps1`

Expected: failure reporting the previous `LED跑马灯` resource values and old Index title.

### Task 2: Apply the Name Consistently

**Files:**
- Modify: `AppScope/resources/base/element/string.json:5`
- Modify: `entry/src/main/resources/base/element/string.json:9-13`
- Modify: `entry/src/main/ets/pages/Index.ets:164-168`
- Test: `scripts/test-appgallery-acceptance.ps1`

- [x] **Step 1: Update user-visible resource values**

```json
{ "name": "app_name", "value": "光迹字幕" }
{ "name": "EntryAbility_desc", "value": "光迹字幕" }
{ "name": "EntryAbility_label", "value": "光迹字幕" }
```

- [x] **Step 2: Update the two home-title spans**

```ts
Text('光迹')
Text('字幕')
```

- [x] **Step 3: Verify the contract passes**

Run: `powershell -ExecutionPolicy Bypass -File scripts/test-appgallery-acceptance.ps1`

Expected: `AppGallery acceptance contract passed.`

### Task 3: Verify and Record the Release Change

**Files:**
- Modify: `tasks.md`
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`

- [x] **Step 1: Record the approved name and validation state**

Document that `光迹字幕` is the launcher, Ability/recent-task, and Index name; note that AppGallery Connect must use the same listing name.

- [x] **Step 2: Run project verification**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-standard.ps1
powershell -ExecutionPolicy Bypass -File scripts/build-harmony.ps1 -BuildMode debug
```

Expected: standard check has zero errors and warnings; Debug HAP builds successfully with the expected unsigned-signing handoff warning.

- [x] **Step 3: Verify on the phone emulator**

Run:

```powershell
hdc -t 127.0.0.1:5555 install -r entry/build/default/outputs/default/entry-default-unsigned.hap
hdc -t 127.0.0.1:5555 shell aa start -b com.ledscroll.banner -a EntryAbility
```

Expected: install and start succeed; the home screen displays `光迹字幕`.
