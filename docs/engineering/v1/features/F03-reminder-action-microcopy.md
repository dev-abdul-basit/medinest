# F03 · Reminder-Action Microcopy Pass

| | |
| --- | --- |
| Roadmap ref | QW-3 |
| Effort | 1 day |
| Risk | low |
| Schema change | no |
| New package | no |
| Premium-gated | no |
| ASO signals moved | R, ★ |
| Status | spec |

## 1. Why we're shipping it

The full-screen reminder UI uses verbose action labels (`Mark as taken`, `Skipped`, `Reschedule`). User research in this category consistently shows shorter, lower-guilt verbs convert better. `Taken` > `Mark as taken`. `Skip` > `Skipped` / `Missed`. We're making one careful microcopy pass and verifying it doesn't break the underlying handler logic.

## 2. What changes for the user

The full-screen reminder shows three primary action labels. Today these read (verify on real device — see step 1):

- "Mark as taken" → **"Taken"**
- "Skipped" / "Missed" → **"Skip"**
- "Snooze" / "Snooze for X" → **"Snooze"**

The icons stay. The colors stay. Only the labels change. The same change cascades to:

- Notification action buttons (the small action buttons under the OS notification)
- Today's-medicine list "Taken" button on the home screen

## 3. What changes in the code

- **`lib/localization/languages/language_en.dart`** — likely the keys `txtTaken` and `txtSkipped` already exist. Verify, then ensure the values are `"Taken"` and `"Skip"`. Do not introduce new keys if existing ones can carry the new copy.
- **`lib/Widgets/select_sound_appointment_screen_view.dart` / select_sound_screen_view.dart** — these contain "Take after / before / any time" strings; verify if they use existing locale keys or hardcoded English.
- **`lib/ui/full_screen_notification/full_screen_notification_view.dart`** — replace any hardcoded label with `'txtTaken'.tr`, `'txtSkip'.tr`, `'txtSnooze'.tr`.
- **`lib/ui/full_screen_appointment_notification/full_screen_appointment_notification_view.dart`** — same.
- **`lib/notification/notification_helper.dart`** — the OS notification action button text is set when scheduling. Find the `AndroidNotificationDetails` / `DarwinNotificationDetails` block. Update to use the same locale keys. **Important:** notification action labels may not localize on a per-fire basis on all OS versions — confirm before claiming the change works at the OS level.
- **`lib/ui/home/home_screens.dart`** — verify the today's list uses `'txtTaken'.tr` for its quick-action button.

## 4. Data model

No schema changes.

## 5. Locale keys

Existing keys to confirm and possibly retune values:

```
'txtTaken': "Taken",        // already exists; confirm value is exactly "Taken"
'txtSkipped': "Skipped",    // currently used; consider replacing with txtSkip
'txtSkip': "Skip",          // already exists; verify
'txtSnoozeFor': "Snooze for",  // already exists
```

Possible new key (only if needed for the standalone snooze button):

```
'txtSnooze': "Snooze",
```

> **Decision rule:** if `txtSnoozeFor` is used in a "Snooze for X minutes" submenu and we need a standalone "Snooze" button, add `txtSnooze`. Otherwise reuse.

## 6. Routing

No routing changes.

## 7. Implementation steps (linear)

1. Build the app on a real device. Trigger a full-screen reminder (set a med for 1 minute from now). Photograph the screen so we have ground-truth labels before changing anything.
2. Open `lib/ui/full_screen_notification/full_screen_notification_view.dart`. Identify each button. Note: hardcoded English vs `.tr` keys.
3. Repeat for `full_screen_appointment_notification_view.dart`.
4. Audit `lib/notification/notification_helper.dart` for `actions:` / `androidActions:` blocks (in `AndroidNotificationDetails`). Identify the action labels.
5. For each label found:
   - If hardcoded English: replace with the existing locale key (`txtTaken`, `txtSkip`, `txtSnooze`).
   - If using a long key like `txtMarkAsTaken`: confirm the **value** is updated in `language_en.dart` to `"Taken"`. Do not delete the key — other places may use it. Just refresh the value.
6. If a new key is needed (`txtSnooze`): add to all `language_*.dart`.
7. For OS-side notification actions: re-schedule all pending notifications (`NotificationHelper.instance.scheduleMedicineNotification()`) once on the next app launch after this build, so existing scheduled actions get the new labels. Bump `versionCode` so the helper re-runs on first open.
8. Run `flutter analyze`.

## 8. Manual test plan

**Golden path 1 — full-screen reminder (medicine):**

1. Set a medicine reminder for 1 minute from now.
2. Lock device. Wait for trigger.
3. **Expected:** full-screen UI shows three buttons labelled `Taken`, `Skip`, `Snooze`. Tap `Taken`. Reminder is marked taken in history.
4. Set another reminder, this time tap `Skip`. Verify history shows skipped.
5. Set another, tap `Snooze`. Verify the snooze submenu shows `Snooze for 5 minutes` etc.

**Golden path 2 — appointment reminder:**

Same as above for the appointment full-screen.

**Edge case — OS notification action buttons:**

1. With device unlocked, allow a reminder to fire as a system notification (don't open it).
2. Pull down notification shade.
3. **Expected:** action buttons show `Taken` and `Skip`. Tap `Taken`. Confirm history updated. (If OS doesn't update existing scheduled notifications, this only works for newly-scheduled — note in the `Implemented` block.)

**Edge case — Arabic locale:**

1. Switch to Arabic.
2. Trigger reminder.
3. **Expected:** buttons show Arabic translations of `Taken` / `Skip` / `Snooze`. RTL alignment.

**Edge case — Premium vs free:**

No premium-gating affects this change. Verify both still show the same labels.

**Regression check:**

Open `Add medicine` flow → sound picker → check the "Take After A Meal" / "Take Before A Meal" / "Take Any Time" picker. Those strings are separate (`Constant.beforeOrAfterMeal`) and should be unaffected. Confirm.

## 9. Rollout

- Ship in next release.
- No flag.
- Rollback: revert locale key value changes; the key replacements in views are also reversible per file.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:

- Photograph evidence (before / after) of the full-screen reminder labels — attach to commit message
- All locale files have any new key added
- Existing scheduled notifications confirmed to fire with new labels OR known limitation documented

## 11. Out of scope

- Redesigning the full-screen reminder UI
- Changing the snooze duration list (`Constant.snoozeMinutesList`)
- Adding new actions to the reminder

## 12. Open questions

1. Does the Android notification system update action labels on already-scheduled notifications when the app is updated? This is OS-version-dependent. Confirm on at least Android 11 and Android 14 during QA.

---

## Implemented

- Date: 2026-05-09
- versionCode shipped: pending
- Outcome: simpler than feared. The full-screen reminder views were already locale-keyed (`txtTaken`, `txtSkip`, `txtSnoozeFor`). Only the **Android system-notification action labels** in `notification_helper.dart` were hardcoded English (`'Taken'`, `'Skip'`, `'Snooze for 5 minutes'`).
- Files changed:
  - `lib/notification/notification_helper.dart` — replaced 3 hardcoded labels with `.tr` lookups (`txtTaken`, `txtSkip`, `txtSnoozeForFiveMinutes`).
  - `lib/localization/languages/language_en.dart` — added `txtSnoozeForFiveMinutes`: "Snooze for 5 min" (shorter than "Snooze for 5 minutes" — Android action labels are space-constrained).
  - 51 other locale files — same key with English fallback.
- Locale key values verified: `txtTaken`: "Taken", `txtSkip`: "Skip" already match the spec.
- Open question (Android propagation of action labels to already-scheduled notifications): unresolved — depends on OS version. To verify in QA: re-schedule via `NotificationHelper.instance.scheduleMedicineNotification()` after install of new build, OR confirm whether new versionCode triggers re-scheduling automatically.
