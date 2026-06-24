# F18 · Streak Milestone Celebration

| | |
| --- | --- |
| Roadmap ref | engagement-system.md §4 C1 (build-order #3, milestone half) |
| Effort | ½–1 day |
| Risk | low |
| Schema change | no (new `Preference` key only) |
| New package | no |
| Premium-gated | no |
| ASO signals moved | R (stickiness) — celebration reinforces the adherence habit that drives D7+ retention |
| Status | spec |

## 1. Why we're shipping it

Stickiness in week 2–4 comes from making the formed habit *feel* rewarding (engagement-system.md §1 Stickiness, §4 C1). We already compute `currentStreakDays` in `AdherenceService` (F08). This feature fires a calm one-off celebration when the user crosses a milestone — and it's the **first real consumer of `EngagementService.canFire`/`recordFired`** (F15), so it proves the budget guardrail end-to-end: a milestone celebration respects quiet hours and the daily/weekly cap like any other engagement nudge.

## 2. What changes for the user

When the user's streak reaches 3 / 7 / 14 / 30 / 100 days (the locked ladder), the next time adherence is computed (Home open) they get one notification:

> **You're on a streak! 🔥** — 7 days on track. Keep it going!

Each milestone fires at most once (tracked), and only if the engagement budget allows (not in quiet hours, under the cap). No guilt, no "you broke your streak", no points — same calm stance as F08.

## 3. What changes in the code

- **`lib/services/engagement_scheduler.dart`** *(new)* — orchestrator tying `AdherenceService` results → `EngagementService` budget → `NotificationHelper`. Pure-ish: takes the already-computed `AdherenceSummary` (no recompute) and an injectable `now`. Single entry: `evaluate({required AdherenceSummary summary, DateTime? at})`.
- **`lib/notification/notification_helper.dart`** — add `showEngagementNotification({id, title, body})` — an immediate `show()` on the calm engagement channel (reused from F16), payload = `Constant.engagementPayload`.
- **`lib/utils/constant.dart`** — add `milestoneNotificationId` + `engagementPayload`.
- **`lib/utils/preference.dart`** — add `lastCelebratedMilestone` (int) + accessors.
- **`lib/ui/home/home_controller.dart`** — in `refreshAdherence()` (after `adherenceSummary` is computed), call `EngagementScheduler().evaluate(summary: adherenceSummary!)`. Extend the two payload guards (added in F16) to also treat `engagementPayload` as "just open the app".

## 4. Data model

No schema change. New `Preference` key:

```dart
static const String lastCelebratedMilestone = "LAST_CELEBRATED_MILESTONE";
int getLastCelebratedMilestone() => _pref!.read(lastCelebratedMilestone) ?? 0;
Future<void> setLastCelebratedMilestone(int v) => _pref!.write(lastCelebratedMilestone, v);
```

New `Constant` values:

```dart
static const int milestoneNotificationId = 990003;
static const String engagementPayload = "engagement";
```

Logic: find the highest milestone `reached` such that `currentStreakDays >= reached`; if `reached > 0` and `lastCelebratedMilestone < reached` and `EngagementService.canFire(now, kind: milestone).allowed`, fire it, set `lastCelebratedMilestone = reached`, and `recordFired(now)`. Storing the highest-reached value means a user who jumps past a milestone offline still celebrates the latest one once, never re-celebrates a lower one.

## 5. Locale keys

```
'txtStreakMilestoneTitle': "You're on a streak! 🔥",
'txtStreakMilestoneBody': "days on track. Keep it going!",
```

Rendered as `'$reached ${'txtStreakMilestoneBody'.tr}'` → "7 days on track. Keep it going!", matching the direct-interpolation convention used in `adherence_card.dart` (no placeholder substitution). Added to all 52 files with English fallback.

## 6. Routing

No new route. A milestone tap opens the app to Home (guarded like the win-back — never routes to the medicine full-screen).

## 7. Implementation steps (linear)

1. Add `Preference.lastCelebratedMilestone` + accessors.
2. Add `Constant.milestoneNotificationId` + `Constant.engagementPayload`.
3. Add 2 locale keys to all 52 files.
4. Add `NotificationHelper.showEngagementNotification(...)`.
5. Create `lib/services/engagement_scheduler.dart` with `evaluate(...)` + `_maybeCelebrateStreak(...)`.
6. Call `EngagementScheduler().evaluate(...)` at the end of `home_controller.refreshAdherence()`.
7. Extend both F16 payload guards to also skip `engagementPayload`.
8. `flutter analyze` the changed files.

## 8. Manual test plan

- **Golden path:** build a 7-day ≥80% history (or temporarily lower `AdherenceService.streakThreshold`). Open Home → one milestone notification "7 days on track…". Reopen Home → no second notification (already celebrated 7).
- **Budget — quiet hours:** set device clock to 22:30, trigger a milestone → no notification (quiet hours); `lastCelebratedMilestone` unchanged so it celebrates later. Verify via log reason `quiet-hours`.
- **Budget — daily cap:** after one engagement notification today, a second eligible milestone is suppressed (`daily-cap`).
- **No regression on lower milestones:** with `lastCelebratedMilestone = 7`, a streak of 6 (dropped) does not re-fire; a later 14 does.
- **Tap routing:** tap a milestone (foreground + cold) → lands on Home, never the medicine full-screen.
- **Regression check:** adherence card still renders correct numbers; medicine reminders unaffected.

## 9. Rollout

- No flag. Roll-back: revert the new service + the five edits + locale keys. `milestoneNotificationId` is unique; no orphans after next `cancelAll()`.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:
- Each milestone fires at most once; budget (quiet hours + caps) respected.
- Milestone tap lands on Home, never the medicine full-screen.
- `flutter analyze` clean on changed files.

## 11. Out of scope

- Evening **adherence tip** (B1) + **streak-at-risk** (C2) scheduled nudges → **F19** (they schedule a future fire and exercise `canFire` against a candidate time + reminder spacing).
- In-app confetti / animation on the adherence card — notification only in v1.
- Journal prompt (B2) — parked (engagement-system.md §9).

## 12. Open questions

None — milestone ladder + caps locked in engagement-system.md §9.
