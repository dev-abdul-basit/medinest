# F04 · ASO Strings on Key UI Screens

| | |
| --- | --- |
| Roadmap ref | QW-4 |
| Effort | ½ day |
| Risk | low |
| Schema change | no |
| New package | no |
| Premium-gated | no |
| ASO signals moved | KW (weak/contested) |
| Status | spec |

## 1. Why we're shipping it

Google Play OCRs store screenshots and (anecdotally) uses the visible text as a soft ranking signal. Multiple ASO practitioners report this; Google won't confirm it. The cost to align is near-zero (a few string tweaks in screens that show up on screenshots), and the upside is a small but compounding boost on `pill reminder`, `medication tracker`, `dose log`. See `../../aso/02-keyword-research.md`.

## 2. What changes for the user

Almost imperceptible. Some screen titles or section headers tweak phrasing to use the keyword we're chasing in the store. Examples (final values to be picked during implementation, in collaboration with Abdul):

- Home tab labels: `Medicine` → consider `Medicines` or keep as-is (consistency with current copy outweighs keyword stuffing). Most likely: **no change here.**
- Empty-state on home medicine list: confirm wording uses `pill reminder` or `medication reminder`.
- Add Medicine screen subtitle: `Add medicine details` → `Set up your pill reminder`.
- History screen empty state: confirm uses `dose log` or `medication history`.
- Settings → premium upsell card: ensures `pill reminder`, `medication tracker`, `journal` appear naturally.

> Decision rule: only change strings where the new copy is at least as natural as the old. If a tweak reads forced, leave the original. Bad copy hurts more than the marginal SEO gain helps.

## 3. What changes in the code

This feature is a string-only change set. The candidate file list:

- **`lib/ui/home/home_screens.dart`** — empty state and section headers
- **`lib/ui/medicine_screen/medicine_list_screen.dart`** — empty state
- **`lib/ui/add_medicine/add_medicine_screens.dart`** — section labels
- **`lib/ui/medicine_history_screen/medicine_history_screen_view.dart`** — empty state and section headers
- **`lib/ui/setting/setting_screen_view.dart`** — premium card subtitle
- **`lib/localization/languages/language_en.dart`** — refresh values; possibly add 1–3 new keys
- **`lib/localization/languages/language_*.dart`** — propagate

## 4. Data model

No schema changes.

## 5. Locale keys

To be finalized during implementation; we will *prefer reusing existing keys* and adjusting their English values.

If new keys are needed, candidates (do not add unless used):

```
'txtSetUpYourPillReminder': "Set up your pill reminder",
'txtMedicationHistory':     "Medication history",
'txtYourDoseLog':           "Your dose log",
```

## 6. Routing

No routing changes.

## 7. Implementation steps (linear)

1. Re-read `../../aso/02-keyword-research.md` Tier 1 + Tier 2 candidates (top 7 keywords). Familiarize.
2. For each candidate file in section 3, read end-to-end; identify the user-visible English strings (whether via `.tr` or hardcoded).
3. For each one, decide:
   - **Keep** — current copy is good
   - **Refresh value** — change the value of the existing locale key (e.g., `txtAddMedicineDetails` value → `"Set up your pill reminder"`)
   - **New key** — add a new key if the existing one is genuinely used elsewhere with the old meaning
4. Walk Abdul through the proposed changes **before** writing them to language files. ASO copy is product-facing — Abdul has final say.
5. Apply the agreed changes. Replicate to every `language_*.dart`.
6. Run `flutter analyze`.

## 8. Manual test plan

**Golden path:**

1. Fresh install. Walk through onboarding to home.
2. Visit, in order: Home (empty), Add medicine, Medicine history (empty), Settings.
3. **Expected:** new strings render. Layout unchanged. No truncation.

**Edge cases:**

- **Long string overflow:** the new copy may be longer than old. Test on a small phone (5.5"). Any clipping requires the change be backed out for that string.
- **Arabic translation:** because we're relying on English fallback until a translator delivers, verify the Arabic UI doesn't show raw `txtKey` strings. (English fallback is acceptable for v1.)
- **Localized listings (later):** once the translator delivers Arabic store-listing copy in `aso/01-store-listing.md` Week 4, the in-app strings should match the listing's keyword vocabulary in Arabic. Note in `Implemented` block: which keys need to be re-translated to align with the localized listing's vocabulary.

**Regression check:**

Take fresh screenshots of the same screens shown in `docs/MediNest/Medinest Playstore grahics/`. Compare layout (not content). Confirm nothing visually broke.

## 9. Rollout

- Ship in next release.
- No flag.
- Rollback: revert the locale value changes.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:

- Abdul reviewed and approved each string change (this is a content decision, not a tech decision)
- All locale files have any added keys

## 11. Out of scope

- Changing screenshots themselves (that's `aso/04-screenshot-strategy.md`'s job)
- Changing the title / short / long description (that's `aso/01-store-listing.md`)
- New features

## 12. Open questions

1. Final wording of each candidate string — to be agreed in implementation step 4.
2. Whether to coordinate this with the screenshot redesign so screenshots and in-app strings align — recommendation: yes; aim to ship F04 *before* the screenshot redesign so screenshots can capture the new strings.

---

## Implemented

- Date: 2026-05-09
- versionCode shipped: pending
- Conservative scope. Only **3 string-value refreshes** in `language_en.dart`. No new keys. The keys already exist in all 51 non-en locale files with their old translations — translators must re-translate via the same pipeline.

| Key | Before | After | Rationale |
| --- | --- | --- | --- |
| `txtHistoryNotFound` | "History Not Found...!" | "No medication history yet" | Better grammar; claims `medication history` (Tier-2 long-tail) |
| `txtHistoryNotFoundDescription` | "You don't have any medicine reminder!\nClick on below button to your first treatment." | "You don't have any pill reminders yet.\nTap below to add your first medicine." | Clean grammar; "tap" is mobile-idiomatic; carries `pill reminder` (Tier-1 keyword) |
| `txtCreateMedicineReminder` | "Create Medicine Reminder" | "Add Pill Reminder" | Shorter; carries `pill reminder` |

- Files changed:
  - `lib/localization/languages/language_en.dart` — 3 value updates only
- Files NOT changed (deliberately):
  - `txtAppName` ("Pills Reminder") — left alone. Real Play Store app name is `Medinest – Pill Reminder` and is set in Play Console listing, not from this string.
  - `txtAddMedicine` ("Add Medicine") — already optimal.
  - All 51 other `language_*.dart` — these keys already exist in those files; their translations are now stale relative to the new English source. Need re-translation in the next localization pass. Marked in `aso/05-aso-roadmap-90day.md` Week 4+ for the translator pipeline.
- Reversal: each row above is reversible by reverting the single value. None of the changes affect logic.
