# F08 · Adherence Streak on Home

| | |
| --- | --- |
| Roadmap ref | T1-2 |
| Effort | 1–2 weeks |
| Risk | low–med |
| Schema change | no (uses existing `medicine_history_table`) |
| New package | no |
| Premium-gated | no (free feature; encourages retention which feeds funnel) |
| ASO signals moved | R (D7+), $$ |
| Status | spec |

## 1. Why we're shipping it

Pill-reminder retention compounds when users see their adherence visualized on the home screen. Mango Health and Round Health have proven this pattern over years. We add a single, calm streak indicator — no gamification, no points, no badges. The goal is to reinforce a behavior, not turn the app into a game.

## 2. What changes for the user

A new card at the top of the Home screen, above today's medicine list, showing:

- **Today's adherence**: `3 of 4 doses taken` with a thin progress bar
- **Current streak**: `7 day streak` (number of consecutive days with ≥80 % adherence)
- **Tap action**: opens a calm weekly view (last 14 days as small dots — green / yellow / red).

The card is collapsible. After 14 days of use, the user can tap "Hide" to dismiss permanently (rate-stored in `Preference`).

## 3. What changes in the code

- **NEW: `lib/ui/home/widgets/adherence_card.dart`** *(new file, widget — placed in a new `widgets/` subfolder under home, matching emerging convention)*
- **`lib/ui/home/home_controller.dart`** — compute today's adherence and current streak from `medicine_history_table`. Two new public fields: `todayAdherenceTaken`, `todayAdherenceTotal`, `currentStreakDays`. Update IDs.
- **`lib/ui/home/home_screens.dart`** — render `AdherenceCard` above the existing medicine list, gated by `Preference.shared.getAdherenceCardHidden()`.
- **`lib/utils/preference.dart`** — add `adherenceCardHidden` bool.
- **`lib/utils/constant.dart`** — add `static const idAdherenceCard = "idAdherenceCard";`
- **NEW: `lib/services/adherence_service.dart`** *(new file)* — pure-Dart logic for streak calculation. Single function: `Future<AdherenceSummary> compute({DateTime? at})`. Keeps the controller thin and the streak-rules testable in the future.

## 4. Data model

No schema changes. We compute adherence from existing `medicine_history_table`:

- For each day, count rows where `mHistoryAction == 'taken'` and rows where `mHistoryAction == 'skipped'` (or whatever values exist — audit table model in `lib/database/tables/medicine_history_table.dart`).
- Adherence ratio = taken / (taken + skipped + missed).
- A day "counts" toward streak when adherence ≥ 80 % AND the user had at least one scheduled dose that day.
- Streak = number of consecutive prior days (back from today) meeting the criterion.

New `Preference` key:

```dart
static const String adherenceCardHidden = "ADHERENCE_CARD_HIDDEN";
Future<void> setAdherenceCardHidden(bool v) => _pref!.write(adherenceCardHidden, v);
bool getAdherenceCardHidden()              => _pref!.read(adherenceCardHidden) ?? false;
```

## 5. Locale keys

```
'txtAdherenceTodayLabel': "Today",
'txtAdherenceDosesTakenOf': "{taken} of {total} doses taken",
'txtAdherenceStreakSingular': "1 day streak",
'txtAdherenceStreakPlural': "{n} day streak",
'txtAdherenceCardHide': "Hide",
'txtAdherenceWeekTitle': "Last 14 days",
'txtAdherenceLegendOnTrack': "On track",
'txtAdherenceLegendPartial': "Partial",
'txtAdherenceLegendMissed': "Missed",
```

Replicate to all locale files.

## 6. Routing

No new route — the 14-day weekly view opens as a bottom sheet (use `Get.bottomSheet(...)`).

## 7. Implementation steps (linear)

1. Add `Preference` key + accessors.
2. Add locale keys + replicate.
3. Add `Constant.idAdherenceCard`.
4. Create `lib/services/adherence_service.dart` with `AdherenceSummary` model class (`int takenToday`, `int totalToday`, `int currentStreakDays`, `List<DayMark> last14Days`). Implement `compute()` reading from `DataBaseHelper.instance.getMedicineHistoryData(...)` (existing method — confirm signature in DB helper).
5. Create the widget at `lib/ui/home/widgets/adherence_card.dart`. Pure StatelessWidget, takes the summary fields as constructor params and a callback for `onHide`.
6. Wire up the bottom-sheet 14-day view inside the same widget file or a separate `adherence_week_sheet.dart`.
7. In `home_controller.dart`, in `onReady`, call `AdherenceService().compute()` and call `update([Constant.idAdherenceCard])` on the result.
8. In `home_screens.dart`, conditionally render the card above the existing list.
9. Hide-action: tap → `Preference.shared.setAdherenceCardHidden(true)` → `update([...])`.
10. QA across edge cases (section 8).

## 8. Manual test plan

**Golden path:**

1. Pre-existing user with at least 5 days of medicine history. Open app.
2. **Expected:** card visible. Today's progress correct. Streak number reflects history.
3. Tap card.
4. **Expected:** bottom sheet with 14 dots colored according to per-day adherence.

**Edge case 1 — Brand new user (no history):**

1. Fresh install, set first medicine. Don't take it yet.
2. **Expected:** card shows `0 of 1 doses taken`, no streak number (or "0 day streak").
3. Mark dose taken.
4. **Expected:** card updates to `1 of 1 doses taken`, streak stays 0 until end of day.

**Edge case 2 — User has zero medicines:**

1. Brand new user, hasn't created any medicine yet (skipped onboarding).
2. **Expected:** card does NOT render — there's nothing to show. `home_screens.dart` should suppress when `totalToday == 0` AND `currentStreakDays == 0`.

**Edge case 3 — Hide:**

1. Tap Hide.
2. **Expected:** card disappears immediately. `Preference.adherenceCardHidden = true`. Persists across restart.

**Edge case 4 — Multiple family members:**

1. User has self + parent profiles, each with meds.
2. **Expected:** adherence is calculated for the *currently-selected* profile in the home tab controller. Verify against `medicineTabController.index`.

**Edge case 5 — Day-boundary:**

1. At 11:59 PM, mark a dose taken. Wait until 12:01 AM.
2. **Expected:** "Today" updates to the new day. Streak count includes the previous day if it qualified.

**Edge case 6 — DST / timezone change:**

Move device timezone forward / back by 1 hour. Streak shouldn't shift unexpectedly.

**Regression check:**

Existing today's-medicine list still renders below the card. Sorting / filtering still works.

## 9. Rollout

- Ship behind `Preference.adherenceCardHidden = true` on first launch for *existing* users (so we don't surprise users with a new card after an update). Reset to `false` after they pass through any onboarding hint about the card.
  - On reflection: **simpler** — show by default for all users, including existing. The card is calm and dismissable. Risk is minimal. Ship without flag.
- Roll-back: hide via a hot-config? We don't have hot-config infra. Roll back via revert + new versionCode.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:

- Card hidden state persists across app restart
- Streak math verified by hand on a real 7-day history
- Bottom sheet renders correctly in dark mode + RTL

## 11. Out of scope

- Push notifications for streak loss ("you broke your streak!") — too aggressive for this category, hurts review sentiment
- Sharing streak to social — privacy concern, irrelevant to install funnel
- Custom streak rules per medicine — over-engineering

## 12. Open questions

1. Confirm exact field names and possible values of `mHistoryAction` in `medicine_history_table`. If the values aren't `taken` / `skipped` / `missed`, adjust `AdherenceService` accordingly.
2. Streak threshold (80 %) — Abdul to confirm. Lower (e.g., 60 %) is friendlier; higher feels meaningful but breaks more easily.
3. When a user hasn't logged anything for a day (no taken, no skipped), does that count as broken streak or not? Recommendation: **not counted** if the day had zero scheduled doses; **counted as missed** if there were scheduled doses unanswered.

---

## Implemented

- Date: 2026-05-09
- Files added:
  - `lib/services/adherence_service.dart` — `AdherenceService.compute()` returning `AdherenceSummary` (today's taken/total, current streak, last 14 days). Day "counts" toward streak when ratio ≥ 0.8 AND day had at least one logged action; days with zero actions are neutral (don't extend, don't break).
  - `lib/Widgets/adherence_card.dart` — `AdherenceCard` widget + `AdherenceWeekSheet` bottom sheet.
- Files changed:
  - `lib/utils/preference.dart` — added `adherenceCardHidden` key + accessors.
  - `lib/utils/constant.dart` — added `idAdherenceCard` GetX update id.
  - `lib/localization/languages/language_en.dart` — 9 new keys.
  - 51 other locale files — same 9 keys with English fallback.
  - `lib/ui/home/home_screens.dart` — renders `AdherenceCard` between header row and tab content. Suppressed when `summary.isEmpty` OR `adherenceCardHidden`. Imports `adherence_card.dart`.
  - `lib/ui/home/home_controller.dart` — adds `adherenceSummary`, `adherenceCardHidden` fields, `refreshAdherence()`, `hideAdherenceCard()`, `openAdherenceWeek()`. `onReady` calls `refreshAdherence()`.
- Streak threshold (0.8) is hardcoded in `AdherenceService.streakThreshold`. To revisit per spec section-12 question 2.
- Refresh strategy: card updates on every Home `onReady`. NOT updated reactively when a dose is marked taken from the full-screen reminder (would require cross-controller coupling we can't safely add in v1). User sees the new value on next return to Home — acceptable trade-off.
- Deferred from spec: writing tests (no test infra in v1), adding analytics on `Hide` taps.
