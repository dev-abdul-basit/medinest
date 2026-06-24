# F15 · Engagement Notification Budget

| | |
| --- | --- |
| Roadmap ref | engagement-system.md §2 (build-order #1) |
| Effort | 1 day |
| Risk | low (pure-Dart foundation, unwired on first ship) |
| Schema change | no (uses `Preference` only) |
| New package | no |
| Premium-gated | no |
| ASO signals moved | R (D7+) — indirect: protects every later engagement notification from causing notification-fatigue churn |
| Status | spec |

## 1. Why we're shipping it

Medicine reminders are already frequent. Every engagement notification we add later (win-back, streak, adherence tip) stacks on top of them — and the failure mode for a Productivity-category app is: too many notifications → user disables notifications → the reminder backbone dies → silent churn (undetectable, worse than uninstall). See `../../feature-improvements/engagement-system.md` §1–§2. This feature is the gatekeeper every non-medicine notification must pass before it fires. It ships **before** any notification that uses it, so the guardrail can never be retrofitted under pressure.

## 2. What changes for the user

Nothing visible in this slice. This is foundation: a service plus persisted counters. User-facing behavior arrives in F16 (the first consumer). Shipping it unwired is deliberate — it's a safe, commit-able slice with zero behavioral risk.

## 3. What changes in the code

- **`lib/services/engagement_service.dart`** *(new)* — pure-Dart budget logic, same shape as `adherence_service.dart` (no GetX, no UI, testable). Exposes `canFire(...)` and `recordFired()`.
- **`lib/utils/constant.dart`** — add engagement-budget constants (quiet hours, caps, spacing, milestone ladder).
- **`lib/utils/preference.dart`** — add 4 keys + accessors: `lastEngagementNotifTs`, `engagementWeekStartTs`, `engagementWeekCount`, `lastOpenTs`.

No changes to `notification_helper.dart` or `main.dart` in this slice — wiring is F16.

## 4. Data model

No schema changes. New `Preference` keys (GetStorage, ints, epoch-ms or counts):

```dart
static const String lastEngagementNotifTs = "LAST_ENGAGEMENT_NOTIF_TS";
static const String engagementWeekStartTs = "ENGAGEMENT_WEEK_START_TS";
static const String engagementWeekCount   = "ENGAGEMENT_WEEK_COUNT";
static const String lastOpenTs            = "LAST_OPEN_TS";

int getLastEngagementNotifTs() => _pref!.read(lastEngagementNotifTs) ?? 0;
Future<void> setLastEngagementNotifTs(int v) => _pref!.write(lastEngagementNotifTs, v);

int getEngagementWeekStartTs() => _pref!.read(engagementWeekStartTs) ?? 0;
Future<void> setEngagementWeekStartTs(int v) => _pref!.write(engagementWeekStartTs, v);

int getEngagementWeekCount() => _pref!.read(engagementWeekCount) ?? 0;
Future<void> setEngagementWeekCount(int v) => _pref!.write(engagementWeekCount, v);

int getLastOpenTs() => _pref!.read(lastOpenTs) ?? 0;
Future<void> setLastOpenTs(int v) => _pref!.write(lastOpenTs, v);
```

New `Constant` values (locked per engagement-system.md §9):

```dart
static const int engagementQuietHourStart = 21; // 21:00 inclusive
static const int engagementQuietHourEnd   = 8;  // 08:00 — fires allowed from here
static const int engagementMaxPerDay      = 1;
static const int engagementMaxPerWeek     = 3;
static const int engagementMinGapToReminderMinutes = 90;
static const List<int> engagementStreakMilestones = [3, 7, 14, 30, 100];
```

## 5. Locale keys

`n/a` — no user-facing strings in this slice. Copy lives with F16+ when notifications actually render.

## 6. Routing

No routing changes.

## 7. Implementation steps (linear)

1. Add the 6 `Constant` values (section 4).
2. Add the 4 `Preference` keys + accessors (section 4).
3. Create `lib/services/engagement_service.dart`:
   - `enum EngagementKind { resurrection, milestone, journal, adherenceTip }` with a priority order (resurrection highest).
   - `EngagementDecision canFire({ required DateTime now, required List<int> upcomingReminderTimestamps, EngagementKind? kind })` returning an allow/deny + reason. Pure — caller injects `now` and the reminder timestamps (from `notification_table`), so no DB coupling and it's unit-testable like `AdherenceService`.
   - Checks in order: (a) quiet hours via `now.hour`; (b) within `engagementMinGapToReminderMinutes` of any `upcomingReminderTimestamps`; (c) daily cap — `lastEngagementNotifTs` same calendar day; (d) weekly cap — roll `engagementWeekStartTs` forward when >7 days old, else compare `engagementWeekCount` to `engagementMaxPerWeek`.
   - `Future<void> recordFired(DateTime now)` — sets `lastEngagementNotifTs`, rolls/increments the week window+count.
4. Keep all thresholds referencing the `Constant` values — no magic numbers in the service.

Each step is commit-able if interrupted.

## 8. Manual test plan

No device UI in this slice. Verify by reasoning + a temporary debug harness (a throwaway button calling `EngagementService` with crafted `now` values), removed before commit.

- **Golden path:** `now` = 14:00, empty reminder list, no prior fire → `canFire` allows. Call `recordFired`. Second call same day → denied (daily cap).
- **Quiet hours:** `now` = 22:30 → denied. `now` = 07:00 → denied. `now` = 08:00 → allowed.
- **Reminder spacing:** reminder at 14:30, `now` = 13:30 (60 min gap) → denied; `now` = 12:30 (120 min) → allowed.
- **Weekly cap:** fire on 3 distinct days in a 7-day window → 4th denied even if a new day. After window rolls (>7 days) → allowed again.
- **Regression check:** none — no existing code path is touched. Confirm app still builds (`flutter analyze` on the two changed files + new file).

## 9. Rollout

- No flag. Unwired foundation — shipping it changes no behavior.
- Roll-back: revert the new file + the two additive edits. Nothing else depends on it yet.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:
- `EngagementService.canFire` returns correct allow/deny across all section-8 cases by hand-trace.
- No magic numbers — every threshold reads from `Constant`.
- `flutter analyze` clean on changed files.

## 11. Out of scope

- Wiring into actual notification sends — that's F16.
- Quiet-hours UI / per-user windows — global constant only in v1.
- FCM / server budgeting — phase 2.
- Per-kind separate caps — single shared budget in v1; priority ordering handles contention.

## 12. Open questions

None — the four cadence decisions are locked in engagement-system.md §9.
