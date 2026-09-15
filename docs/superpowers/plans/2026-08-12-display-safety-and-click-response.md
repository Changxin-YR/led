# Display Safety and Click Response Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent low-contrast LED text and remove Preferences flush latency from visible click completion.

**Architecture:** Put contrast normalization in the existing `Utils` helper and apply it at both reusable preview and full-screen render boundaries. Keep durable Preferences writes serialized in `StorageService`, but let navigation and optimistic UI state happen before that queue completes.

**Tech Stack:** ArkTS, ArkUI, ArkData Preferences, PowerShell source contracts, Hvigor.

---

### Task 1: Regression Contract

**Files:**
- Create: `scripts/test-display-safety-contract.ps1`
- Modify: `scripts/check-standard.ps1`

- [ ] **Step 1: Write the failing contract**

Require `Utils.ensureTextContrast`, render-boundary use in `LedPanel` and `DisplayPage`, combined `StorageService.saveDisplayConfig`, route-before-background-save in all display entries, and nonblocking counter/color interactions.

- [ ] **Step 2: Run the contract to verify it fails**

Run: `powershell -ExecutionPolicy Bypass -File .\\scripts\\test-display-safety-contract.ps1`
Expected: failure because the shared contrast and response helpers do not exist.

- [ ] **Step 3: Register the contract with the standard check**

Add one invocation next to the existing repository contracts.

### Task 2: Shared Contrast and Display Persistence

**Files:**
- Modify: `entry/src/main/ets/common/Utils.ets`
- Modify: `entry/src/main/ets/components/LedPanel.ets`
- Modify: `entry/src/main/ets/pages/DisplayPage.ets`
- Modify: `entry/src/main/ets/services/StorageService.ets`

- [ ] **Step 1: Implement contrast normalization**

Add hexadecimal color validation, relative luminance, contrast ratio, and `ensureTextContrast(requestedColor, backgroundColor)` that preserves a compliant requested color and otherwise returns the better black/white fallback.

- [ ] **Step 2: Apply at both render boundaries**

Normalize the reusable panel foreground against `#01060C`, and normalize the full-screen LED foreground against the active banner background.

- [ ] **Step 3: Batch a display save**

Add `saveDisplayConfig(config)` to write the last config and merged history inside the existing write queue with one final `flush()`.

### Task 3: Immediate Interaction Completion

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/TemplatePage.ets`
- Modify: `entry/src/main/ets/pages/HistoryPage.ets`
- Modify: `entry/src/main/ets/pages/ColorPickerPage.ets`
- Modify: `entry/src/main/ets/pages/CounterPage.ets`

- [ ] **Step 1: Route display actions first**

Build normalized display configs, await only `pushUrl`, then start a non-awaited `saveDisplayConfig` chain with error logging.

- [ ] **Step 2: Make local state controls optimistic**

Update color recents, history list state, and counter state before background persistence; serialize counter saves so quick taps retain their final value.

- [ ] **Step 3: Run the contract to verify it passes**

Run: `powershell -ExecutionPolicy Bypass -File .\\scripts\\test-display-safety-contract.ps1`
Expected: `Display safety and click response contract passed.`

### Task 4: Verification and Records

**Files:**
- Modify: `tasks.md`
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`

- [ ] **Step 1: Run required checks**

Run: `powershell -ExecutionPolicy Bypass -File .\\scripts\\check-standard.ps1`, `powershell -ExecutionPolicy Bypass -File .\\scripts\\test-arkts-compile.ps1`, and `powershell -ExecutionPolicy Bypass -File .\\scripts\\build-harmony.ps1`.

- [ ] **Step 2: Install on an available target and verify immediate response**

Install the generated HAP, open a deliberately low-contrast color configuration, start display, and confirm counter/color interactions update without waiting for storage.

- [ ] **Step 3: Record evidence**

Mark the task outcome and add actual command/device evidence to the project-required design, change, and QA records.
