# F22 · Notification Reliability (exact-alarm fix)

| | |
| --- | --- |
| Roadmap ref | bugfix — "no reminder after adding a medicine" |
| Effort | ½ day |
| Risk | med (touches the core scheduling path + a manifest permission) |
| Schema change | no |
| New package | no |
| Premium-gated | no |
| ASO signals moved | R, ★ — a reminder app whose reminders don't fire churns + gets 1-star reviews |
| Status | shipped (needs device confirmation on Android 13+) |

## 1. The bug

On a fresh install on **Android 13+** (app targets SDK 36), medicine reminders never fired after adding a medicine.

Root cause chain:
1. `SCHEDULE_EXACT_ALARM` is **revoked by default** on Android 13+; the user must hand-enable "Alarms & reminders".
2. Medicine reminders scheduled with `AndroidScheduleMode.alarmClock`, which **requires** that permission.
3. `USE_EXACT_ALARM` (auto-granted for alarm/reminder apps) was **commented out** in the manifest.
4. There was **no try/catch** around `zonedSchedule` or the scheduling loop — so the first call threw `PlatformException('exact_alarms_not_permitted')` and **aborted scheduling for the entire batch**. Zero reminders, silently.

This also blocked `scheduleWinBackNotifications()` (F16), which runs at the *end* of the same aborted loop.

## 2. What changes for the user

Reminders fire on time on Android 13+ **without** the user manually enabling any setting. If exact alarms are ever unavailable, reminders still fire (a few minutes late) instead of not at all.

## 3. What changes in the code

- **`android/app/src/main/AndroidManifest.xml`** — declare `USE_EXACT_ALARM` (kept `SCHEDULE_EXACT_ALARM` for API 31–32). **Requires a Play Console declaration at submission** (app's core function is reminders — qualifies).
- **`lib/notification/notification_helper.dart`**:
  - `resolveAndroidScheduleMode()` — queries `canScheduleExactNotifications()`; returns `alarmClock` when exact is allowed, else `inexactAllowWhileIdle`.
  - `scheduleMedicineNotification()` loop — resolves mode once, wraps each `scheduleNotification` in try/catch so one failure can't abort the batch.
  - `scheduleNotification()` — takes an optional `scheduleMode`; wraps `zonedSchedule` in try/catch and retries with `inexactAllowWhileIdle` on `PlatformException`.
  - Added `import 'package:flutter/services.dart'` for `PlatformException`.

## 4. Data model

No schema change.

## 5. Locale keys

`n/a`.

## 6. Routing

No routing changes.

## 7. Implementation steps (linear)

1. Manifest: enable `USE_EXACT_ALARM`.
2. Add `resolveAndroidScheduleMode()`.
3. Harden the loop (resolve once + per-item try/catch).
4. Harden `scheduleNotification` (optional mode + exact→inexact fallback).
5. `flutter analyze`.

## 8. Manual test plan

- **Primary (Android 13+ device):** fresh install, grant notifications, do NOT touch "Alarms & reminders". Add a medicine with a time ~2 minutes ahead → reminder fires. (Before the fix: nothing.)
- **Exact revoked:** Settings → revoke "Alarms & reminders" → add a medicine → reminder still fires (inexact fallback, possibly a few min late); no crash.
- **Android 11/12:** add a medicine → fires exactly (SCHEDULE_EXACT_ALARM auto-granted).
- **Batch integrity:** add several medicines / many times → all schedule; a single bad row logs and is skipped, others still scheduled.
- **Engagement regression:** confirm win-back is scheduled after the loop (it no longer gets skipped when a medicine schedule fails).

## 9. Rollout

No flag. Roll-back: revert the manifest line + `notification_helper` changes. **Do not roll back the manifest alone** — the code fallback depends on nothing, but exact alarms need the permission.

## 10. Definition of done

- Reminder fires on an Android 13+ device without manually enabling Alarms & reminders.
- No single-failure abort of the batch.
- `flutter analyze` clean.

## 11. Out of scope

- **OEM battery-killers** (Xiaomi/Oppo/Vivo/Huawei aggressive Doze) can still delay/drop alarms — not fully solvable in code; `alarmClock` mode is the most resilient. A future "disable battery optimization" prompt could help.
- Rewriting the per-sound channel-id scheme.
- `matchDateTimeComponents` repeat semantics — unchanged.

## 12. Open questions

Confirm the `USE_EXACT_ALARM` Play Console declaration is accepted for the Productivity listing (reminder apps qualify; flag if review pushes back).
