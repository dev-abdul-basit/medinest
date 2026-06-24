# F20 · Retention Instrumentation (local)

| | |
| --- | --- |
| Roadmap ref | engagement-system.md §6 |
| Effort | ½ day |
| Risk | low (additive counters; no behavior change) |
| Schema change | no (`Preference` counters) |
| New package | no (Firebase Analytics deferred — needs approval) |
| Premium-gated | no |
| ASO signals moved | — (enables tuning every other engagement feature) |
| Status | shipped |

## 1. Why we're shipping it

You can't tune cadence you can't measure (engagement-system.md §6). With `firstInstallTs` (F02) + `lastOpenTs` (F15) + a new `openCount` we can read basic D1/D7/D30 windows; an engagement-tap counter is a proxy for notification effectiveness. Deliberately **local + no new package** — `firebase_analytics` isn't in pubspec and the architecture canon requires sign-off before adding one. Call sites are centralised so forwarding to Analytics later is one line per event.

## 2. What changes for the user

Nothing visible. Counters + `Debug` logs only.

## 3. What changes in the code

- **`lib/services/instrumentation_service.dart`** *(new)* — `recordAppOpen()` (advances `openCount` + `lastOpenTs`, logs days-since-install), `recordEngagementTap()` (increments `engagementTapCount`).
- **`lib/utils/preference.dart`** — `openCount`, `engagementTapCount` + accessors.
- **`lib/ui/home/home_controller.dart`** — `recordAppOpen()` in `onInit`; `recordEngagementTap()` in the engagement-payload tap guard.

## 4. Data model

No schema change. `Preference.openCount` (int), `Preference.engagementTapCount` (int). Reuses `firstInstallTs`, `lastOpenTs`.

## 5. Locale keys

`n/a`.

## 6. Routing

No routing changes.

## 7. Implementation steps (linear)

1. `Preference` keys + accessors.
2. `InstrumentationService`.
3. Wire `recordAppOpen` (onInit) + `recordEngagementTap` (tap guard).
4. `flutter analyze`.

## 8. Manual test plan

- Open the app twice → log shows `appOpen #1`, `#2`; `openCount` persists across restart.
- Tap an engagement notification → log shows `engagement tap #1`; counter increments.
- `daysSinceInstall` reflects `firstInstallTs`.
- Regression: no behavior change anywhere.

## 9. Rollout

No flag. Roll-back: revert the new service + edits.

## 10. Definition of done

Counters persist; logs emit on open + tap; no behavioral change.

## 11. Out of scope

- **Firebase Analytics** forwarding (real funnels/dashboards) — needs `firebase_analytics` approval; centralised call sites make it a one-line-per-event add.
- Per-notification-type scheduled-vs-tapped breakdown — single tap counter in v1.
- Server-side cohort analytics — phase 2.

## 12. Open questions

Whether to approve `firebase_analytics` for real retention dashboards — operator decision.
