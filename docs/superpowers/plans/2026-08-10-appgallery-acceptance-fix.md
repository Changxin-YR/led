# AppGallery Acceptance Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the built LED banner app satisfy the current AppGallery rejection findings for name, icon consistency, contrast, status-bar adaptation, and minimum fixed UI text size.

**Architecture:** Keep the existing Stage-model pages, `AppTheme`, `ScreenService`, and layered icon assets. Change only the app-facing labels, ordinary window chrome, undersized fixed text, and regression contracts; the display page remains a separate fullscreen mode and user-configured LED colors remain unchanged.

**Tech Stack:** ArkTS/ArkUI, HarmonyOS Stage model, PowerShell contracts, Hvigor/HAP build, HDC when a target is available.

---

### Task 1: Add the failing AppGallery contract

**Files:**
- Create: `scripts/test-appgallery-acceptance.ps1`
- Modify: `scripts/check-standard.ps1`

- [ ] Add assertions that `app_name`, `EntryAbility_label`, and `EntryAbility_desc` are `LED跑马灯`, ordinary pages do not use `expandSafeArea` for system bars, `ScreenService.applyAppChrome()` uses `setWindowLayoutFullScreen(false)` and `AppTheme.PAGE_BG`, `DisplayPage` still uses fullscreen mode, and ordinary page source contains no `uiFontSize(10)`, `uiFontSize(11)`, or literal 10/11fp text.
- [ ] Run `powershell -ExecutionPolicy Bypass -File scripts/test-appgallery-acceptance.ps1` and confirm it fails on the current old label, transparent/fullscreen ordinary chrome, and undersized text.
- [ ] Call the new contract from `scripts/check-standard.ps1` so a future release cannot bypass it.

### Task 2: Apply the minimum release fixes

**Files:**
- Modify: `AppScope/resources/base/element/string.json`
- Modify: `entry/src/main/resources/base/element/string.json`
- Modify: `entry/src/main/ets/common/Theme.ets`
- Modify: `entry/src/main/ets/services/ScreenService.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/TemplatePage.ets`
- Modify: `entry/src/main/ets/pages/HistoryPage.ets`
- Modify: `entry/src/main/ets/pages/ColorPickerPage.ets`
- Modify: `entry/src/main/ets/pages/CounterPage.ets`

- [ ] Replace only the user-visible app/Ability/module labels with `LED跑马灯`; leave `bundleName`, version fields, signature configuration, routes, and permissions unchanged.
- [ ] Set `SYSTEM_STATUS_BAR` to the same opaque page background as `PAGE_BG`, make `applyAppChrome()` use `setWindowLayoutFullScreen(false)`, and retain enabled system bars with light content icons. Keep `enterDisplayMode()` fullscreen and `exitDisplayMode()` restoring ordinary chrome.
- [ ] Remove ordinary-page `.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])` calls so the system reserves the status/navigation areas; keep existing page padding and layout structure.
- [ ] Change only fixed `uiFontSize(10)` and `uiFontSize(11)` calls to the shared minimum base size `uiFontSize(12)`; leave user-controlled LED display sizes unchanged.
- [ ] Run the new contract and existing icon/accessibility/window contracts; fix only contract failures caused by the intended change.

### Task 3: Verify source and package outputs

**Files:**
- Modify: `tasks.md`
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`

- [ ] Run `scripts/check-standard.ps1` and require zero errors; separately run the icon, accessibility, window, responsive, business, and release contracts that the standard runner invokes.
- [ ] Run `scripts/build-harmony.ps1` and inspect the generated HAP manifest/resources to confirm `LED跑马灯`, unchanged `com.ledscroll.banner`, unchanged version values, both layered icon descriptors, and no new permissions.
- [ ] Install/start the generated HAP on each available phone, tablet, and 2in1 target; capture ordinary-page status-bar screenshots and verify that entering/exiting `DisplayPage` restores the ordinary chrome. Record any unavailable device honestly.
- [ ] Update `design.md`, `changes.md`, `design-qa.md`, and the T-20260810-001 checklist with the actual commands, package metadata, screenshot paths, and any device limitations.
- [ ] Run `git diff --check`, review the final diff against the approved design, and leave unrelated pre-existing worktree changes untouched.

### Verification commands

```powershell
powershell -ExecutionPolicy Bypass -File scripts/test-appgallery-acceptance.ps1
powershell -ExecutionPolicy Bypass -File scripts/check-standard.ps1
powershell -ExecutionPolicy Bypass -File scripts/build-harmony.ps1
```

Expected result: each contract exits 0; the build exits 0 and produces a HAP whose metadata and icon resources match the assertions above. A device check is required for every target that is online; an offline target is reported as unverified rather than inferred to pass.
