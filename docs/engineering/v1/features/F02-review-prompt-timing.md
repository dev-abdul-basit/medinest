# F02 · Review-Prompt Timing Fix

| | |
| --- | --- |
| Roadmap ref | QW-2 |
| Effort | ½ day |
| Risk | low–med |
| Schema change | no |
| New package | no |
| Premium-gated | no |
| ASO signals moved | ★, R |
| Status | spec |

## 1. Why we're shipping it

`in_app_review` is wired but the trigger conditions need an audit. Current behavior likely fires too early or too often, hurting average rating. Improving when we ask is one of the highest-leverage 4-hour ASO wins because rating volume + freshness directly affect ranking. See `../../feature-improvements/feature-roadmap.md` QW-2.

## 2. What changes for the user

Before: User may be prompted to rate the app before they've successfully used it (annoying, often 1-stars).

After: User is only prompted to rate after a positive interaction: they've marked **≥3 doses as taken** AND it's been at least 7 days since first install AND they haven't been shown a paywall in the last 24 hours AND they haven't been prompted in the last 90 days.

The user sees the system rate-prompt on a *good* day, not a frustrating one.

## 3. What changes in the code

- **`lib/utils/preference.dart`** — add three new keys + accessors (section 4).
- **`lib/ui/full_screen_notification/full_screen_notification_view.dart`** OR `..._controller.dart` — increment "doses taken" counter when the user taps `Taken` from the full-screen reminder. Find the existing tap handler.
- **`lib/ui/home/home_controller.dart`** — same: when "Taken" is tapped from the home list (find existing handler), increment counter.
- **`lib/ui/home/home_controller.dart`** — paywall trigger: set `lastPaywallTimestamp` whenever `CommonSubscriptionDialog` is shown.
- **NEW: `lib/services/review_prompt_service.dart`** *(new file)* — single helper class with one entry point: `ReviewPromptService.maybeShow()`. Encapsulates all gating logic.
- **`lib/ui/home/home_controller.dart`** — call `ReviewPromptService.maybeShow()` in `onReady()`, behind a small delay (3 sec) so it never collides with app-launch or dialog flows.

## 4. Data model

No SQLite schema changes.

New `Preference` keys (in `lib/utils/preference.dart`):

```dart
static const String dosesMarkedTaken     = "DOSES_MARKED_TAKEN";       // int counter
static const String lastReviewPromptTs   = "LAST_REVIEW_PROMPT_TS";    // millis since epoch
static const String firstInstallTs       = "FIRST_INSTALL_TS";         // millis since epoch
static const String lastPaywallTs        = "LAST_PAYWALL_TS";          // millis since epoch
```

Accessors:

```dart
int  getDosesMarkedTaken()                => _pref!.read(dosesMarkedTaken) ?? 0;
Future<void> setDosesMarkedTaken(int v)   => _pref!.write(dosesMarkedTaken, v);
int  getLastReviewPromptTs()              => _pref!.read(lastReviewPromptTs) ?? 0;
Future<void> setLastReviewPromptTs(int v) => _pref!.write(lastReviewPromptTs, v);
int  getFirstInstallTs()                  => _pref!.read(firstInstallTs) ?? 0;
Future<void> setFirstInstallTs(int v)     => _pref!.write(firstInstallTs, v);
int  getLastPaywallTs()                   => _pref!.read(lastPaywallTs) ?? 0;
Future<void> setLastPaywallTs(int v)      => _pref!.write(lastPaywallTs, v);
```

`firstInstallTs` is set in `main.dart` if not already set, on app boot:

```dart
if (Preference.shared.getFirstInstallTs() == 0) {
  Preference.shared.setFirstInstallTs(DateTime.now().millisecondsSinceEpoch);
}
```

## 5. Locale keys

None. The system review prompt is rendered by the OS, not the app.

## 6. Routing

No routing changes.

## 7. Implementation steps (linear)

1. Add the 4 `Preference` keys + accessors per section 4. Place in alphabetical-ish order under existing keys.
2. Wire `firstInstallTs` set in `main.dart` boot sequence (after `Preference.shared.instance()` resolves).
3. Create `lib/services/review_prompt_service.dart`:
   ```dart
   class ReviewPromptService {
     static Future<void> maybeShow() async {
       final p = Preference.shared;
       final now = DateTime.now().millisecondsSinceEpoch;
       const sevenDaysMs   = 7 * 24 * 60 * 60 * 1000;
       const ninetyDaysMs  = 90 * 24 * 60 * 60 * 1000;
       const oneDayMs      = 24 * 60 * 60 * 1000;

       final daysSinceInstall   = now - p.getFirstInstallTs();
       final daysSincePrompt    = now - p.getLastReviewPromptTs();
       final daysSincePaywall   = now - p.getLastPaywallTs();

       if (p.getDosesMarkedTaken() < 3)            return;
       if (daysSinceInstall  < sevenDaysMs)        return;
       if (daysSincePrompt   < ninetyDaysMs)       return;
       if (daysSincePaywall  < oneDayMs)           return;
       if (p.getIsPurchase())                      return; // never ask premium users to review free-tier
                                                            // (optional — discuss with Abdul)

       final InAppReview review = InAppReview.instance;
       if (await review.isAvailable()) {
         await review.requestReview();
         await p.setLastReviewPromptTs(now);
         Debug.printLog("ReviewPromptService: prompt requested at $now");
       }
     }
   }
   ```
4. In every place a dose is marked taken, increment `dosesMarkedTaken`. Audit:
   - `lib/ui/home/home_controller.dart` — search for "Taken" handler
   - `lib/ui/full_screen_notification/full_screen_notification_view.dart` — same
   - `lib/ui/medicine_history_screen/medicine_history_screen_logic.dart` — same
   Add: `await Preference.shared.setDosesMarkedTaken(Preference.shared.getDosesMarkedTaken() + 1);`
5. In every place `CommonSubscriptionDialog` is shown (the same call sites as F01), set `lastPaywallTs`:
   ```dart
   await Preference.shared.setLastPaywallTs(DateTime.now().millisecondsSinceEpoch);
   ```
6. In `home_controller.dart` `onReady()`, schedule the prompt with a 3 s delay:
   ```dart
   Future.delayed(const Duration(seconds: 3), () {
     ReviewPromptService.maybeShow();
   });
   ```
7. Re-grep for any *other* call to `InAppReview` already in the codebase. If found, route through `ReviewPromptService.maybeShow()` instead.

## 8. Manual test plan

**Golden path:**

1. Fresh install, sign in.
2. Verify `firstInstallTs` is set in storage. (Use `Debug.printLog` to dump on next boot if no inspector handy.)
3. Mark 3 doses taken across 1 hour.
4. Force-quit and reopen. **Expected:** no review prompt yet (`<7 days since install`).
5. Manually rewind storage by setting `firstInstallTs` to 8 days ago via debug helper or by changing system clock. Reopen.
6. **Expected:** review prompt appears ~3 seconds after Home loads.

**Edge case 1 — paywall just shown:**

1. With all other gates passed, hit the medicine cap and dismiss the paywall.
2. Reopen the app within 24 h.
3. **Expected:** no review prompt.

**Edge case 2 — premium user:**

1. Subscribe.
2. Pass all other gates.
3. **Expected:** depending on the policy decision in step 3 of section 7, either prompt OR don't prompt premium users. Confirm intended behavior with Abdul; document the choice in the `Implemented` block.

**Edge case 3 — second review prompt within 90 days:**

1. Trigger a successful prompt.
2. Pass all other gates again.
3. **Expected:** no second prompt.

**Edge case 4 — `InAppReview.isAvailable()` returns false:**

1. Run on emulator without Play Services.
2. **Expected:** no prompt, no crash, log line written.

**Regression check:**

Add a medicine, add a journal note, check appointment screen renders. None of these should be affected by the helper, but the helper runs on `onReady` so we want to confirm nothing UI-blocks during launch.

## 9. Rollout

- Ship in the next release.
- No flag.
- Rollback: revert the new file + the call-site additions. The `Preference` accessor additions are forward-compatible (extra keys in storage are harmless).

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:

- The four new `Preference` keys are typed-accessor only (no raw `_pref!.read`)
- `Debug.printLog` line confirms the prompt fires when expected
- Premium-user behavior decision is documented

## 11. Out of scope

- Adding a custom in-app rating dialog (we use the OS prompt only)
- Sentiment-gating the prompt (asking "are you enjoying the app?" first) — that pattern is now penalized by Apple and frowned-on by Google. Don't add it.
- Analytics on prompts shown / responded — v2.

## 12. Open questions

1. Premium users: prompt or not? Recommendation: **yes, do prompt** — they're high-NPS users and a 5-star from a paying user is worth more. Final call from Abdul.

---

## Implemented

- Date: 2026-05-09
- versionCode shipped: pending Abdul's release
- Files changed:
  - `lib/utils/preference.dart` — 4 new keys + 8 typed accessors.
  - `lib/main.dart` — sets `firstInstallTs` once, immediately after `Preference().instance()`.
  - `lib/services/review_prompt_service.dart` *(new)* — `ReviewPromptService.maybeShow()` with all gates and verbose `Debug.printLog` skip-reason output for QA visibility.
  - `lib/ui/full_screen_notification/full_screen_notification_logic.dart` — increments `dosesMarkedTaken` on `takeMedicine(false)`. Added `Preference` import.
  - `lib/ui/medicine_history_screen/medicine_history_screen_logic.dart` — increments `dosesMarkedTaken` on `updateHistory(isTaken: true)`. Also writes `lastPaywallTs` at paywall site.
  - `lib/ui/appointment_history_screen/appointment_history_screen_logic.dart` — writes `lastPaywallTs` at paywall site.
  - `lib/ui/home/home_controller.dart` — added `onReady` override that schedules `maybeShow()` 3 s after home loads. Writes `lastPaywallTs` at both paywall sites. Imports `review_prompt_service`.
- Open question resolved as: **premium users are still prompted** (the service does not gate on `getIsPurchase()`). Rationale: a 5-star from a paying user is high-value; the gate set already filters out the frustrated-state edge cases. Easy to flip later with a one-liner in the service.
- Pre-existing TODO comments in `*_logic.dart` files (`// TODO: implement onInit`) — left as-is per canon (boilerplate, not added by F02).
- Pre-existing diagnostic in `home_controller.dart` line 596 (`appointmentDataList` unused inside a commented-out loop) — pre-existing, not changed.
