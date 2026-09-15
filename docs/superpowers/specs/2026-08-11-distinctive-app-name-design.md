# Distinctive App Name Design

## Goal

Replace the generic display name `LED跑马灯` with the approved distinctive name `光迹字幕` wherever a user can identify the application.

## Scope

- AppScope `app_name` drives the installed launcher name.
- EntryAbility label and description drive the Ability and recent-task name.
- The Index title renders the same name without an inserted space, while retaining the existing two-color title treatment.
- The AppGallery acceptance contract locks these three resource values and the visible Index title spans.

## Constraints

- Preserve `com.ledscroll.banner`, `1.0.0`, `1000000`, icon resources, and signing configuration.
- Do not alter the LED display feature or user-entered text.

## Verification

The acceptance contract must fail with the previous name, then pass after the resource and title updates. The standard check, Debug build, and phone launcher/start verification complete the change.
