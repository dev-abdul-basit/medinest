# F16 · Win-back Notifications (offline resurrection)

| | |
| --- | --- |
| Roadmap ref | engagement-system.md §4 D1/D2 (build-order #2, the win-back half) |
| Effort | 1 day |
| Risk | low–med (touches the shared notification reschedule path + tap routing) |
| Schema change | no (uses `Preference.lastOpenTs` from F15) |
| New package | no |
| Premium-gated | no |
| ASO signals moved | R (D7+) — direct: recovers users who lapsed before forming the habit |
| Status | spec |

## 1. Why we're shipping it

The single highest-ROI net-new notification in the engagement system. A pill-reminder user who stops opening the app inside the first two weeks usually never comes back on their own — there's no social pull. The classic fix is a local "we miss you" notification scheduled for *now + 5 days* and **cancelled/rescheduled on every app open**: active users never see it, lapsed users do. It needs **zero backend** — `zonedSchedule()` fires even when the app is killed. See `../../feature-improvements/engagement-system.md` §4 (D1/D2) and §1 Resurrection stage.

## 2. What changes for the user

- An **active** user never sees these — every app open pushes the timer back.
- A user who stops opening MediNest gets, at **11:00 local** (chosen to sit outside the 21:00–08:00 quiet window):
  - **D1, +5 days idle:** *"Your reminders are waiting — Open MediNest to pick up where you left off."*
  - **D2, +14 days idle:** *"Start fresh today — A new streak is one tap away."*
- Tapping either just opens the app to Home. We stop after D2 — chasing a 30-day-gone user earns an uninstall.

## 3. What changes in the code

- **`lib/utils/constant.dart`** — add win-back IDs, day offsets, fire hour, engagement channel id/name, and the `winback` payload marker.
- **`lib/notification/notification_helper.dart`** — add `scheduleWinBackNotifications()` (public) + `_scheduleWinBack(...)` (private). Call `scheduleWinBackNotifications()` at the **end** of the existing `scheduleMedicineNotification()` — that method already `cancelAll()`s at the top and is the single choke point invoked on app start (via `reScheduleNotifications`) and after every medicine add/edit, so the win-back is always refreshed *after* the cancel and the "open" timer resets whenever the user is active.
- **`lib/ui/home/home_controller.dart`** — guard the two payload consumers so a `winback` payload never routes into the full-screen medicine screen:
  - cold-launch block (`onInit`, ~line 76) — skip if `selectedNotificationPayload` is the win-back marker.
  - `selectNotificationStream` listener (~line 287) — return early on the win-back marker (app is already open; nothing to route).
- **52 locale files** — 4 new keys.

`lastOpenTs` (from F15) is written inside `scheduleWinBackNotifications()` so it's set on every reschedule.

## 4. Data model

No schema changes. Reuses `Preference.lastOpenTs` (added in F15). New `Constant` values:

```dart
static const int winBackD1NotificationId = 990001; // far outside medicine id range (nId + 1000)
static const int winBackD2NotificationId = 990002;
static const int winBackD1AfterDays = 5;
static const int winBackD2AfterDays = 14;
static const int winBackFireHour = 11; // 11:00 local — outside quiet hours
static const String winBackPayload = "winback";
static const String engagementNotificationChannelId = "engagement_notification_channel";
static const String engagementNotificationChannelName = "MediNest Nudges";
```

The win-back uses a **calm** notification (default importance/priority, no full-screen intent, no alarm sound) — the opposite of the medicine-reminder channel. `androidScheduleMode: inexactAllowWhileIdle` so it needs no exact-alarm permission and is battery-friendly (a resurrection nudge does not need second-precision).

## 5. Locale keys

```
'txtWinBackD1Title': "Your reminders are waiting",
'txtWinBackD1Body': "Open MediNest to pick up where you left off.",
'txtWinBackD2Title': "Start fresh today",
'txtWinBackD2Body': "A new streak is one tap away. Your reminders are ready.",
```

Added to all 52 files in `lib/localization/languages/` with the English value as fallback (same convention as F08/F13). Copy is Productivity-safe — no medical claim.

## 6. Routing

No new route. A win-back tap opens the app to Home (default launch); the guards in §3 prevent any navigation to the medicine full-screen.

## 7. Implementation steps (linear)

1. Add the `Constant` values (§4).
2. Add 4 locale keys to all 52 files (§5).
3. In `notification_helper.dart`, add `scheduleWinBackNotifications()` + `_scheduleWinBack(...)`; call it at the end of `scheduleMedicineNotification()`.
4. In `home_controller.dart`, add the `winback` guard to both payload consumers.
5. `flutter analyze` the changed files.

## 8. Manual test plan

- **Golden path (active user):** open app → background it → reopen. Inspect pending notifications log (`checkPendingNotificationRequests`) → exactly two win-back ids (990001/990002) scheduled ~5d and ~14d out at 11:00. Each reopen pushes them forward.
- **Idle fire (simulated):** temporarily set `winBackD1AfterDays = 0` and `winBackFireHour` to two minutes ahead; do NOT reopen; confirm D1 fires with the right copy. Revert.
- **Tap while app alive:** with app foregrounded, tap a win-back → app stays on Home, no full-screen medicine screen, no crash (verifies the `selectNotificationStream` guard).
- **Cold-launch tap:** kill app, fire a win-back, tap it → app launches to Home, not the medicine full-screen (verifies the `onInit` guard).
- **Edge — notifications denied:** deny permission → `reScheduleNotifications` isn't called → no win-back scheduled. Correct (they couldn't fire anyway).
- **Regression check:** add a medicine → reminders still schedule and fire normally; the `cancelAll` + reschedule path is unaffected; medicine tap still opens the full-screen reminder.

## 9. Rollout

- No flag. Roll-back: revert the four edits. Win-back ids are unique, so a revert leaves no orphans after the next `cancelAll()` on app start.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:
- Two win-back ids present after app open; pushed forward on reopen.
- Win-back tap (foreground + cold) lands on Home, never the medicine full-screen.
- Medicine reminders unaffected (regression).

## 11. Out of scope

- A1 permission rescue card → **F17** (UI surface, separate slice).
- In-session nudges (streak milestone, adherence tip) that exercise `EngagementService.canFire` caps → **F18**.
- Warm resume-from-background reset — v1 resets on cold start + med edits only; a root `WidgetsBindingObserver` is a later refinement.
- FCM-driven win-back → phase 2.

## 12. Open questions

None. Copy is provisional pending the full A/B set (engagement-system.md §10, "draft the full copy set").
