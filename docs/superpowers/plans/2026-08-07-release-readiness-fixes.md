# Release Readiness Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the approved repository-controlled release-readiness findings without changing signing or the API 22 compatibility target.

**Architecture:** Preserve the current Stage-model page and service boundaries. Use static PowerShell contracts for source/config/resource invariants, then validate actual ArkTS compilation, HAP packaging, and available-device behavior.

**Tech Stack:** ArkTS, ArkUI Stage model, Preferences, PowerShell regression contracts, Hvigor, HDC/UITest.

---

### Task 1: Add Failing Release Contracts

**Files:**
- Modify: `scripts/test-business-contract.ps1`
- Modify: `scripts/test-icon-assets.ps1`
- Create: `scripts/test-release-contract.ps1`
- Modify: `scripts/check-standard.ps1`

- [ ] Assert native `GestureGroup(GestureMode.Exclusive, ...)`, double-tap-first ordering, and removal of timer-based tap counting.
- [ ] Assert `HistoryPage.useRecord()` calls both `saveLastConfig()` and `addHistory()` before navigation.
- [ ] Assert backup is disabled, permissions remain empty, no network references exist, and release documents exist.
- [ ] Replace the foreground edge-touch rule with an 80-pixel alpha-content safe inset.
- [ ] Run the three contracts and confirm they fail only on the missing approved behavior.

### Task 2: Implement Functional And Offline Fixes

**Files:**
- Modify: `entry/src/main/ets/pages/DisplayPage.ets`
- Modify: `entry/src/main/ets/pages/HistoryPage.ets`
- Modify: `entry/src/main/resources/base/profile/backup_config.json`

- [ ] Remove `tapCount`, `tapTimer`, and `handleTap()`; register a double-tap recognizer before a single-tap recognizer in an exclusive gesture group.
- [ ] Call `await this.storageService.addHistory(record.config)` after saving the last configuration and before routing.
- [ ] Set `allowToBackupRestore` to `false` while retaining an empty `requestPermissions` list.
- [ ] Run the business and release contracts and confirm they pass.

### Task 3: Regenerate Safe-Area Icons

**Files:**
- Modify: `scripts/generate-layered-icon.ps1`
- Regenerate: `AppScope/resources/base/media/app_icon_foreground.png`
- Regenerate: `entry/src/main/resources/base/media/icon_foreground.png`

- [ ] Move circuit decoration and LED lettering inside the 80-pixel foreground inset.
- [ ] Run the generator and icon contract; confirm 1024x1024 dimensions, transparent foreground, opaque background, matching layer hashes, and safe bounds.

### Task 4: Replace Deprecated ArkUI Globals

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/DisplayPage.ets`
- Modify: `entry/src/main/ets/pages/TemplatePage.ets`
- Modify: `entry/src/main/ets/pages/HistoryPage.ets`
- Modify: `entry/src/main/ets/pages/ColorPickerPage.ets`
- Modify: `entry/src/main/ets/pages/CounterPage.ets`
- Modify: `entry/src/main/ets/services/StorageService.ets`

- [ ] Use `getUIContext().getRouter()`, `getPromptAction()`, `getHostContext()`, `px2vp()`, and `animateTo()`.
- [ ] Add explicit host-context guards and error handling around functions marked as throwing.
- [ ] Run a clean ArkTS build and confirm deprecated-global and unhandled-exception warnings are removed.

### Task 5: Align Release Documentation

**Files:**
- Modify: `DevDoc.md`
- Create: `docs/release/privacy-policy.md`
- Create: `docs/release/user-agreement.md`
- Create: `docs/release/appgallery-submission-checklist.md`
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`
- Modify: `tasks.md`

- [ ] Correct SDK, feature, preset, border, and LED-style claims to match the application.
- [ ] Document the offline data practices and user terms without inventing external registration data.
- [ ] Record AppGallery console, copyright/registration, screenshot, icon-preview, and tablet checks as external acceptance items.
- [ ] Record verification evidence and mark `T-20260807-004` done only after all in-scope checks pass.

### Task 6: Final Verification

**Files:**
- Verify only.

- [ ] Run `scripts/check-standard.ps1` and require zero contract failures.
- [ ] Run clean debug and release builds and inspect full compiler output.
- [ ] Install and start the signed HAP on phone and 2in1; verify pause, history refresh, immersive entry/exit, icon metadata, and empty permissions.
- [ ] Record tablet as waiting if no tablet target is available.
