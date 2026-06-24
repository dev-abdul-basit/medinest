# F19 · Evening Adherence-Tip & Streak-at-Risk Nudges

| | |
| --- | --- |
| Roadmap ref | engagement-system.md §4 B1 + C2 (build-order #4) |
| Effort | 1 day |
| Risk | low–med (scheduled fire; shares the engagement budget) |
| Schema change | no (new `Preference` key) |
| New package | no |
| Premium-gated | no |
| ASO signals moved | R (habituation) — recovers a partial adherence day before it's lost |
| Status | shipped |

## 1. Why we're shipping it

The first **scheduled** (vs immediate) consumer of the F15 budget, and the first to exercise `canFire` against a *future* fire time + reminder spacing. If a user has taken some but not all of today's doses, a single evening nudge recovers the day. Copy adapts: a user with a streak to protect gets loss-framed "keep your streak" (C2, loss-aversion outperforms gain framing); everyone else gets a gentle tip (B1). See engagement-system.md §4 B1/C2.

## 2. What changes for the user

If doses remain untaken by evening, at **19:30 local** one nudge:
- **No streak (tip):** "Don't forget today's dose — 1 left to take today…"
- **Streak ≥ 3 (at-risk):** "Keep your streak alive — 6 day streak is on the line…"

At most one engagement notification per day total (shared budget): if a milestone already celebrated today, no evening nudge. If the user finishes all doses, a scheduled nudge is cancelled.

## 3. What changes in the code

- **`lib/services/engagement_scheduler.dart`** — `evaluate()` now takes the `TodayPlan`; added `_maybeScheduleEveningNudge(...)`. Schedules at the evening slot when `scheduledToday - takenToday > 0`, gated by `EngagementService.canFire(now: fireAt, reminders, kind)`; guards against rescheduling/double-record via a per-day flag; cancels when nothing remains.
- **`lib/notification/notification_helper.dart`** — `scheduleEngagementNotification({id, fireAt, title, body})`, `cancelEngagementNotification(id)`, `todayRemainingReminderTimestamps(now)` (for spacing).
- **`lib/utils/constant.dart`** — `eveningNudgeNotificationId`, `engagementEveningHour/Minute`.
- **`lib/utils/preference.dart`** — `lastEveningNudgeScheduledTs`.
- **`lib/ui/home/home_controller.dart`** — pass `todayPlan!` into `evaluate`.
- **52 locale files** — 4 keys.

## 4. Data model

No schema change. `Preference.lastEveningNudgeScheduledTs` (epoch ms) — set when a nudge is scheduled; same-day value suppresses re-scheduling/double-counting. Remaining-doses = `TodayPlan.scheduledToday - TodayPlan.takenToday`.

## 5. Locale keys

```
'txtEveningTipTitle': "Don't forget today's dose",
'txtEveningTipBody': "left to take today. A quick tap keeps you on track.",
'txtAtRiskTitle': "Keep your streak alive",
'txtAtRiskBody': "day streak is on the line — take today's dose to keep it going.",
```

Rendered with the count interpolated in front (`'$remaining ${'txtEveningTipBody'.tr}'`), matching the `adherence_card.dart` convention. All 52 files, English fallback.

## 6. Routing

No new route. Tap routes to Home (guarded as `engagementPayload`, F18).

## 7. Implementation steps (linear)

1. Constants + `Preference` key.
2. `NotificationHelper` schedule/cancel/remaining-timestamps helpers.
3. `EngagementScheduler._maybeScheduleEveningNudge` + `evaluate(todayPlan)` signature.
4. `home_controller` pass `todayPlan!`.
5. 4 locale keys × 52.
6. `flutter analyze`.

## 8. Manual test plan

- **Tip path:** 2 of 3 doses taken, open Home before 19:30 → a nudge is scheduled for 19:30; at 19:30 it fires with "1 left to take today…".
- **At-risk path:** same but with a 5-day streak → copy is "Keep your streak alive — 5 day streak…".
- **All taken:** take the last dose, reopen → scheduled nudge is cancelled (none fires).
- **Budget — milestone first:** hit a milestone same day → milestone fires, evening nudge suppressed (`daily-cap`).
- **Idempotent reopen:** open Home several times before 19:30 → exactly one nudge scheduled (per-day flag), not N.
- **Past slot:** first open after 19:30 → nothing scheduled for today.
- **Regression:** medicine reminders + adherence card unaffected.

## 9. Rollout

No flag. Roll-back: revert the edits + locale keys; `eveningNudgeNotificationId` is unique.

## 10. Definition of done

Per `../04-definition-of-done.md`. At most one engagement notification/day; nudge cancels when doses complete; copy switches on streak.

## 11. Out of scope

- Per-dose timing (one evening slot, not per-reminder).
- Journal prompt (B2) — parked.
- Morning nudges — evening only in v1.

## 12. Open questions

Evening slot fixed at 19:30; revisit with F20 instrumentation if tap-rate is low.
