# Vertical Scroll Exit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make vertical LED text enter smoothly from one edge and exit fully through the opposite edge before looping.

**Architecture:** Preserve the existing `DisplayPage` timer loop and centered-coordinate travel geometry. During each vertical entry, derive opacity from distance travelled over one estimated text height, and lock both geometry and entry behavior with the existing PowerShell business contract.

**Tech Stack:** ArkTS, ArkUI Stage model, PowerShell contract tests, Hvigor.

---

### Task 1: Lock And Correct Vertical Travel Geometry

**Files:**
- Modify: `scripts/test-business-contract.ps1`
- Modify: `entry/src/main/ets/pages/DisplayPage.ets`

- [x] **Step 1: Write the failing contract**

Require `startScrollV()` to calculate `travelLimit` as `(this.screenHeight + textHeight) / 2`, assign symmetric start/end coordinates, and remove the old direct `-textHeight` endpoint.

- [x] **Step 2: Run the contract to verify RED**

Run: `./scripts/test-business-contract.ps1`

Expected: FAIL because the current implementation uses `this.screenHeight` and `-textHeight` directly.

- [x] **Step 3: Implement the minimal geometry fix**

```typescript
const travelLimit = (this.screenHeight + textHeight) / 2
const startPos = isTtb ? -travelLimit : travelLimit
const endPos = isTtb ? travelLimit : -travelLimit
```

- [x] **Step 4: Verify GREEN and full regression**

Run `./scripts/test-business-contract.ps1`, `./scripts/check-standard.ps1`, and `./scripts/build-harmony.ps1`. The contract and standard checks must report zero failures and the build must report `BUILD SUCCESSFUL`.

- [x] **Step 5: Verify on available devices and document evidence**

Install the signed HAP on available phone/2in1 targets, select vertical bottom-to-top mode, and confirm the text enters below, exits above, loops without snapping, and the page remains responsive. Record unavailable device coverage honestly in `design-qa.md`.

Implementation stays uncommitted because the touched files already contain unrelated worktree changes; do not stage, commit, merge, or push without explicit authorization.

### Task 2: Smooth Each Vertical Entry

**Files:**
- Modify: `scripts/test-business-contract.ps1`
- Modify: `entry/src/main/ets/pages/DisplayPage.ets`
- Modify: `tasks.md`
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`

- [x] **Step 1: Write the failing opacity contract**

Require `startScrollV()` to define one text-height fade distance, start at zero opacity, update opacity from distance travelled, and reset to zero opacity at both direction endpoints:

```powershell
Assert-FileContains 'entry/src/main/ets/pages/DisplayPage.ets' @(
  'const entryFadeDistance = Math.max(textHeight, 1)',
  'const travelledDistance = Math.abs(this.offsetY - startPos)',
  'this.textOpacity = Math.min(travelledDistance / entryFadeDistance, 1.0)'
)
```

- [x] **Step 2: Run the contract to verify RED**

Run: `./scripts/test-business-contract.ps1`

Expected: FAIL because vertical scrolling does not yet derive opacity from travelled distance.

- [x] **Step 3: Implement the minimal distance-based fade**

```typescript
const entryFadeDistance = Math.max(textHeight, 1)

this.offsetY = startPos
this.textOpacity = 0.0
this.scrollTimer = setInterval(() => {
  this.offsetY += increment
  const travelledDistance = Math.abs(this.offsetY - startPos)
  this.textOpacity = Math.min(travelledDistance / entryFadeDistance, 1.0)
  if (isTtb && this.offsetY >= endPos) {
    this.offsetY = startPos
    this.textOpacity = 0.0
  } else if (!isTtb && this.offsetY <= endPos) {
    this.offsetY = startPos
    this.textOpacity = 0.0
  }
}, 16)
```

- [x] **Step 4: Verify GREEN and full regression**

Run `./scripts/test-business-contract.ps1`, `./scripts/check-standard.ps1`, `./scripts/build-harmony.ps1`, and `git diff --check`. The contract and standard checks must report zero failures, the build must report `BUILD SUCCESSFUL`, and Git must report no whitespace errors.

- [x] **Step 5: Verify the loop on an available device and record evidence**

Install the newly built signed HAP, use vertical scrolling with the existing orientation setting, and capture controlled re-entry frames. Confirm the lower-edge entry starts transparent and progresses into the screen, the upper-edge exit remains complete, the application stays running, and no forced portrait behavior is introduced. Record foreground-capture limitations and unavailable device coverage in `design-qa.md`, then mark `T-20260807-003` done.
