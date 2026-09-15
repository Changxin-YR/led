# Vertical Scroll Exit Design

## Problem

`DisplayPage` centers the text and then applies `translate(y)`. The current bottom-to-top loop resets at `-textHeight`, but that value is not the top off-screen coordinate for a centered element. The reset therefore occurs while the text is still visible, producing an abrupt disappearance at the top edge.

## Recommended Design

Keep the existing timer-based animation and calculate one symmetric travel limit:

```text
travelLimit = (screenHeight + textHeight) / 2
```

For bottom-to-top motion, start at `+travelLimit` and finish at `-travelLimit`. For top-to-bottom motion, reverse those values. At either endpoint the nearest text edge is exactly at the viewport edge, so the full text enters before crossing the page and fully exits before the loop resets.

## Alternatives Considered

1. Adjust only the bottom-to-top end threshold. This fixes the reported direction but leaves asymmetric and incorrect top-to-bottom geometry.
2. Replace the interval with chained `animateTo` callbacks. This adds lifecycle and pause/resume complexity without improving the boundary calculation.

## Scope And Verification

The change is limited to vertical scrolling. Horizontal scrolling, speed presets, pause/resume, mirroring, and other display modes remain unchanged. A static regression contract must first fail against the old `-textHeight` boundary, then pass only when both directions use the symmetric centered-coordinate travel limit. Standard checks, a full HAP build, and available-device verification complete the work.

## Smooth Re-entry

Resetting a completed loop directly to the off-screen start coordinate while keeping `textOpacity` at `1.0` makes the first visible pixels appear at full intensity. The vertical loop must therefore set opacity to `0.0` at its initial start and at every reset, then derive opacity from the absolute distance travelled away from `startPos`.

Use one estimated text height as the fade distance:

```text
entryFadeDistance = max(textHeight, 1)
textOpacity = min(abs(offsetY - startPos) / entryFadeDistance, 1)
```

This applies symmetrically to bottom-to-top and top-to-bottom motion. It changes only the entry presentation: direction, duration, speed presets, off-screen endpoints, orientation selection, exit behavior, and all non-vertical modes remain unchanged.
