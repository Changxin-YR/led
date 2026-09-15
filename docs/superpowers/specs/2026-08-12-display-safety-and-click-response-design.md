# Display Safety and Click Response Design

## Goal

Guarantee a minimum 4.5:1 contrast ratio for user-visible LED text and avoid making a completed in-app action wait for Preferences disk persistence.

## Design

- `Utils` will own sRGB luminance, contrast, and LED foreground normalization. A valid requested foreground remains unchanged when it is already at least 4.5:1 against its background; otherwise the helper selects the higher-contrast black or white fallback. This always supplies a compliant foreground for opaque six-digit sRGB backgrounds.
- `LedPanel` and `DisplayPage` use that helper at render time so old history, new custom colors, templates, presets, and future callers cannot bypass the rule. New Index and Template configurations are also normalized before persistence.
- `StorageService.saveDisplayConfig()` stores last configuration and updated history in one serialized write and one `flush()`. Display entry routes first, then starts this write in the background. Local state actions that do not delete user data update immediately and persist through serialized background queues.
- Deletion/clear confirmation still waits for user confirmation; their visible list state is updated first and a failed background write reloads data and reports the failure.

## Validation

- A source/color-math contract rejects missing contrast normalization, direct display configuration persistence before navigation, and blocking counter/color/history actions.
- Standard, ArkTS, and Harmony builds remain required. The available device is used to verify immediate navigation, immediate counter/color feedback, and a deliberately low-contrast custom color corrected in the LED preview/display.
