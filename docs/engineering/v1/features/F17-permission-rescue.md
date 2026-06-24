# F17 · Notification Permission Rescue

| | |
| --- | --- |
| Roadmap ref | engagement-system.md §4 A1 (build-order #2, the rescue half) |
| Effort | ½ day |
| Risk | low (replaces an existing broken dialog) |
| Schema change | no |
| New package | no (`permission_handler` already in pubspec) |
| Premium-gated | no |
| ASO signals moved | R (activation) — a denied permission silently kills every notification in the system |
| Status | spec |

## 1. Why we're shipping it

A user who denies notification permission gets zero value from a reminder app and churns invisibly. Today's denial handler is a **broken placeholder**: `home_controller.dart` `showAlertDialog()` shows `content: const Text("This is my message.")` and, on "Ok", re-requests permission in an infinite loop — but on Android 13+ a re-request does nothing once denied, so the user is trapped in a meaningless dialog. This is the highest-leverage activation fix (engagement-system.md §1 Activation, A1): replace it with a real explanation + a deep-link to OS settings, which is the only thing that actually re-enables notifications after a denial.

## 2. What changes for the user

When notifications are off on app open, instead of a placeholder loop the user sees:

> **Turn on reminders** — MediNest can't remind you to take your medicine without notification access. Turn it on to get your reminders.

Two buttons: **Not now** (dismisses — no loop) and **Open settings** (opens the OS app-settings page via `openAppSettings()`).

## 3. What changes in the code

- **`lib/ui/home/home_controller.dart`** — rewrite `showAlertDialog()`: real title/body from locale keys, `barrierDismissible: true`, two actions (dismiss / open settings). Remove the recursive re-show loop. Add `import 'package:permission_handler/permission_handler.dart';` for `openAppSettings()`.
- **52 locale files** — 4 new keys.

No change to `_requestPermissions()` / `_isAndroidPermissionGranted()` — the OS request flow and the `else → showAlertDialog` trigger stay as-is; only the dialog content/behavior changes.

## 4. Data model

No schema changes, no new `Preference` keys.

## 5. Locale keys

```
'txtPermRescueTitle': "Turn on reminders",
'txtPermRescueBody': "MediNest can't remind you to take your medicine without notification access. Turn it on to get your reminders.",
'txtNotNow': "Not now",
'txtOpenSettings': "Open settings",
```

Added to all 52 files with English fallback (same convention as F08/F13/F16).

## 6. Routing

No new route — `openAppSettings()` leaves the app to the OS settings screen.

## 7. Implementation steps (linear)

1. Add the 4 locale keys to all 52 files.
2. Add the `permission_handler` import to `home_controller.dart`.
3. Replace the body of `showAlertDialog()` (drop the loop; add real copy + two actions).
4. `flutter analyze` the changed file.

## 8. Manual test plan

- **Golden path (Android 13+):** fresh install → OS asks for notification permission → deny → rescue dialog appears with real copy. Tap **Open settings** → OS app settings opens. Enable notifications → return to app → next launch schedules reminders normally (no dialog).
- **Not now:** tap **Not now** → dialog dismisses, no loop, app usable.
- **Permission already granted:** launch with permission on → no dialog (regression — `else` branch never runs).
- **Regression check:** medicine reminders still schedule when permission is granted (`reScheduleNotifications` path untouched).

## 9. Rollout

- No flag. Roll-back: revert `home_controller.dart` + the locale keys.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:
- No infinite dialog loop remains.
- "Open settings" reaches the OS settings page on a real device.
- Dialog copy renders in dark mode + RTL.

## 11. Out of scope

- Frequency-capping the rescue dialog — it shows whenever reminders are off on launch, which is acceptable for a reminder app whose core value is the notification. Could be revisited if users report annoyance.
- A persistent in-Home banner (vs the launch dialog) — the dialog is the existing surface; not worth a second surface in v1.
- The exact-alarm-permission nuance on Android — unchanged from current behavior.

## 12. Open questions

None.
