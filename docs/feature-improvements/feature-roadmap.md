# Feature Roadmap (ASO-Driven)

> **MVP scope reminder (2026-05-10):** the MVP pillars are pill reminder + health journal + family medication support. Doctor profiles and appointment reminders were **removed from the MVP** and are tracked below in the new "Pulled from MVP — slated to return" section. Code for these features may still exist; the decision was a marketing / scope call, not necessarily a code-deletion call.

> Only features that move ASO needles. Not a product wishlist. Each item names *which* signal it moves and *roughly* how much. If a feature would be cool but doesn't move retention, ratings, keyword surface, or paywall conversion — it goes in the parking lot at the bottom, not in the sprint.

Signal acronyms used below:
- **R** = Retention (D1 / D7 / D30)
- **★** = Rating sentiment + review volume
- **KW** = Keyword surface area (claims new query terms)
- **CVR** = Store-listing conversion (impressions → installs)
- **$$** = Premium upgrade rate
- **L** = Localized-listing leverage

---

## Pulled from MVP — slated to return

These features were dropped from the MVP scope on 2026-05-10. Re-introduction order is opinionated; revisit after the MVP hits Day-90 install targets.

### PR-1 · Doctor profiles
**Signals:** KW (`doctor app`, `doctor contacts`), $$, ★ · **Effort:** ~2 days code reactivation + listing copy update · **Re-introduction trigger:** ship T1-4 (Notes-for-doctor PDF export) first; doctor profiles are the natural attachment point for the export.

Code lives in `lib/ui/add_or_edit_doctor_screen/` and `lib/ui/doctors_screen/`. The feature was pulled from MVP because (a) it widened the product story without deepening it, and (b) without the PDF export, "save doctor details" had weak retention pull. Returns once the export feature gives doctor profiles a clear job.

### PR-2 · Appointment reminders
**Signals:** KW (`doctor appointment reminder`, `appointment reminder`), R · **Effort:** ~2 days code reactivation + new listing block · **Re-introduction trigger:** after we have analytics on whether MVP users want a unified reminder surface or two distinct ones.

Code lives in `lib/ui/add_or_edit_appointment/`, `lib/ui/appointment_history_screen/`, `lib/ui/full_screen_appointment_notification/`. The feature was pulled because the MVP product story is cleaner with one reminder type (medicines). The re-introduction question is: do we ship appointments back as a separate flow, or fold them into the medicine reminder engine as a second "type"?

---

## Quick wins (ship in next 2 release cycles)

These move signals fast and most are <2 days of work.

### QW-1 · Paywall copy rewrite
**Signals:** $$, ★ ·  **Effort:** ½ day · **Owner:** dev (you)
The current paywall says: *"You have reached the limit. Please subscribe to the plan. (In the free version, you only have a limit of 10 medicines and appointments.)"* That's developer copy, not user copy. Rewrite to lead with the upgrade benefit, name the price ("only 5 SAR/month"), drop the appointments mention (out of MVP), and remove the parenthetical. See `../context/monetization-snapshot.md` for the analysis.

**Files to change:** `lib/Widgets/common_subscribe_dialog.dart`, locale strings in `lib/localization/languages/language_*.dart`.

### QW-2 · Review-prompt timing fix
**Signals:** ★, R · **Effort:** ½ day
`in_app_review` is wired in. Audit *when* it fires. Rules:
- Fire **after** the user has marked ≥3 doses as taken
- Never on first session
- Never within 24 h of a paywall trigger (negative emotional state)
- Cap at once per 90 days per user

Even small timing improvements move 4-week rating averages by 0.1–0.3 stars in this category.

### QW-3 · "Taken / Skipped / Snooze" microcopy on the full-screen reminder
**Signals:** R, ★ · **Effort:** 1 day
Right now (per `lib/ui/full_screen_notification/full_screen_notification_view.dart`), the action labels need a final pass. Caregiver feedback consistently shows that **`Taken`** outperforms `Mark as taken` (faster, less ambiguous) and **`Skip`** outperforms `Skipped` or `Missed` (less guilt-loaded).

### QW-4 · Add `Pill Reminder` to in-app strings used in screenshots
**Signals:** KW · **Effort:** ¼ day
The store screenshots are images, but localized in-app strings populate them. Make sure phrases like "pill reminder", "medication tracker", "dose log" appear in actual app UI text used in screenshots — Play OCRs screenshots and may use the text as a weak ranking signal. (Contested — multiple practitioners report it; Google won't confirm. Cheap to do regardless.)

### QW-5 · Privacy policy live + linked
**Signals:** Compliance, ★ · **Effort:** ½ day
Required by Play Console. If not already live: spin up a one-page site (GitHub Pages is fine), link it in Play Console "Privacy policy" field, link it from in-app Settings.

### QW-6 · App update cadence cap
**Signals:** Algorithm freshness · **Effort:** scheduling
Bump versionCode and ship at least once every 4 weeks even if it's just a string fix. Play algorithm down-weights apps that look abandoned. The `versionCode` increment is what counts, not the diff size.

---

## Tier 1 — high-impact features (next 8 weeks)

### T1-1 · Onboarding rewrite focused on first-reminder-set
**Signals:** R (D1), CVR · **Effort:** 1–2 weeks
The biggest D1 retention drop in pill-reminder apps is users who installed but never set a single reminder. Onboarding goal: get a working reminder set in <60 s. Steps to compress:
- Pre-select common dosage frequencies (once daily, twice daily) on first run
- Default time to 8:00 am for the first reminder, not "pick a time"
- Skip Google Sign-in on first run; offer it after first reminder fires successfully

**Files to touch:** `lib/ui/get_started_screen/`, `lib/ui/introduction_screen/`, `lib/ui/add_medicine/`.

### T1-2 · Streak / adherence visualization on home screen
**Signals:** R (D7+), $$ · **Effort:** 1–2 weeks
Mango Health proved it; Round Health uses it. Pill-reminder retention compounds when users see their adherence as a streak/percentage on the home screen. Don't overdo — one number, one weekly view, no gamification noise.

### T1-3 · Apple Health / Google Health Connect integration (Health Connect first)
**Signals:** KW, ★ · **Effort:** 1 week
Google Health Connect support adds the keywords `health connect`, `google fit integration`, plus a real Play badge. Less marketing fluff than expected because the integration is genuinely thin: write a record per dose taken.

### T1-4 · "Notes for doctor" export
**Signals:** $$, ★ · **Effort:** 1 week
Take the existing journal feature, add: "Export last 30 days of medicine history + journal notes as PDF for your next doctor visit." This is the differentiating feature in `01-store-listing.md`. Currently we *advertise* this capability without fully shipping it. Ship it.

### T1-5 · "Caregiver mode" toggle
**Signals:** KW (`caregiver app`), $$ · **Effort:** 1–2 weeks
Renames the family-profile feature in onboarding when the user picks "I'm setting this up for someone else." UI is identical; copy is different. Cheap. Claims the `caregiver app` keyword cleanly.

### T1-6 · Per-region IAP pricing
**Signals:** $$ · **Effort:** ½ day in Play Console
Not a code change. Set price tiers per region in Play Console. Most-impactful 30-min job in mobile pricing. See `../context/monetization-snapshot.md`.

---

## Tier 2 — medium-impact (weeks 8–16)

### T2-1 · Smart Refill reminder
**Signals:** KW, R · **Effort:** 1 week
"Track pills remaining; remind to refill 3 days early." Claims `prescription refill reminder`, `medication refill app`. Niche but high-intent.

### T2-2 · Wearable companion (Wear OS first, Apple Watch later)
**Signals:** ★, KW · **Effort:** 2–3 weeks
Wear OS app that shows the next dose and lets you tap "Taken" from the wrist. Bigger lift than it sounds in reviews — 5-stars love it.

### T2-3 · Multiple-times-per-day medications without separate entries
**Signals:** R, ★ · **Effort:** 1 week
Some meds are 3× / day with different dosages. Today (verify in code) you have to add three entries. Audit and consolidate.

### T2-4 · Backup / restore from cloud (already partial via Firestore)
**Signals:** ★, R · **Effort:** 1 week
Make the existing Firestore sync work as a clean **export / import** flow on settings, not just a background sync. Power users want to see "Last backed up 2 hours ago." Reduces 1-star reviews when users switch phones.

### T2-5 · Widget on home screen
**Signals:** R, ★ · **Effort:** 1–2 weeks
Today widget showing next dose. Marginal CVR claim ("home screen widget"). Notable bump in D7 retention.

---

## Tier 3 — long-term (months 4–6)

### T3-1 · Family Sync (real, not multi-profile)
**Signals:** $$, KW (`family medication app`), R · **Effort:** 3–4 weeks
Real shared family — caregiver gets pinged when the parent doesn't acknowledge a dose. Distinct from current multi-profile. Strong premium upsell — not free.

### T3-2 · Integration with major chains for prescription import
**Signals:** ★, KW, $$ · **Effort:** 6–8 weeks (partnerships involved)
Walgreens / CVS / equivalents. Out of scope for current sprint, but worth scoping with one regional partner per market.

### T3-3 · iOS launch
**Signals:** Coverage doubles · **Effort:** depends on what's already iOS-ready
`pubspec.yaml` ships iOS targets — verify how close to working iOS already is. The decision is whether to split focus while Android is still climbing. Recommendation: don't ship iOS until Android hits the Day-90 target in `aso/05-aso-roadmap-90day.md`.

---

## Parking lot (good ideas, NOT this year)

These get suggested often. Saying no clearly:

| Idea | Why not |
| --- | --- |
| AI assistant for medication questions | Triggers Play medical-claims policy. Reputational + regulatory risk. |
| Symptom tracker | Different category (Bearable, Guava). Dilutes pill-reminder relevance. |
| Telemedicine integration | Wrong category. Different acquisition cost. |
| Social / community features | Privacy nightmare for medication data. Doesn't help retention. |
| Wearable health data import (heart rate, sleep) | Out of scope. We are a reminder app, not a tracker. |
| Apple Watch complication before Wear OS app | Tiny iOS audience for us right now. Wear OS first. |
| Voice assistant integration (Alexa, Google Assistant) | Sounds great, almost no install lift in pill-reminder category historically. |
| Web app | Mobile-only is fine; web app costs 4 weeks of work for marginal install gain. |
| In-app pharmacy / prescription delivery | Massive regulatory burden. Not us. |

---

## How to use this file

When prioritizing your next sprint:
1. Pick 1 quick win for shipping THIS week (always).
2. Pick 1 Tier-1 feature in active development.
3. Park everything else.
4. Re-rank Tier 1 vs Tier 2 every month based on real data — what reviews are asking for, what Search Terms report shows, what's churning users.

Don't ship two Tier-1 features in parallel. Keeps signal attribution clean.
