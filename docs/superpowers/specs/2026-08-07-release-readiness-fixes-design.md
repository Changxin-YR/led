# Release Readiness Fixes Design

## Scope

Keep the current signing configuration unchanged and retain `compatibleSdkVersion` and `targetSdkVersion` at HarmonyOS 6.0.2 API 22. Fix all repository-controlled findings from the 2026-08-07 audit. External certificates, registrations, AppGallery console fields, and tablet availability remain external acceptance items.

## Behavior

- `DisplayPage` uses ArkUI's native exclusive gesture recognizers. A double tap toggles pause exactly once; a single tap only reveals the exit control.
- Opening a history record saves the last configuration and records another use through `StorageService.addHistory()`, updating both count and timestamp before navigation.
- The application requests no network permissions, contains no network client code, and opts out of system backup/restore.

## Store Readiness

- The existing deterministic layered icon keeps its full-bleed opaque background, while every nontransparent foreground pixel stays at least 80 pixels from the 1024x1024 canvas edge.
- Product documentation describes API 22 targeting, eight implemented display modes, eleven presets plus one custom entry, a static optional border, and the current standard text rendering on the full-screen display page.
- Repository release documents cover the offline privacy posture, user terms, and the external evidence that must be supplied in AppGallery Connect.

## Compatibility And Validation

Deprecated global ArkUI helpers are replaced by API 22-compatible `UIContext` equivalents without changing routes or page structure. Regression contracts must fail against the current implementation, pass after the minimal changes, and be followed by standard checks, debug/release builds, and runtime checks on available phone and 2in1 targets. Tablet remains explicitly unverified until a target is online.
