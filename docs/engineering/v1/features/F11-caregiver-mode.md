# F11 · Caregiver Mode Toggle

| | |
| --- | --- |
| Roadmap ref | T1-5 |
| Effort | 1–2 weeks |
| Risk | low |
| Schema change | no |
| New package | no |
| Premium-gated | no (claims a keyword + a positioning lane; gating it would defeat the purpose) |
| ASO signals moved | KW (`caregiver app`, `family medication app`), $$, R |
| Status | spec |

## 1. Why we're shipping it

We already have multi-profile family-member support, but we don't *call* it caregiver mode anywhere. The keyword `caregiver app` has Tier-2 demand (`../../aso/02-keyword-research.md`) and we're already a perfect match. This is mostly a copy + onboarding flow change with one flag.

## 2. What changes for the user

- During onboarding (`F07` already lands), a new question: **"Who is this for?"** with two options:
  - "Just me" — current default behavior
  - "Me and my family" / "I'm helping someone else" — switches the app into caregiver mode
- In caregiver mode:
  - The home tab shows a profile switcher more prominently
  - The "Add medicine" flow defaults the `family member` field instead of skipping it
  - Settings has an "I'm a caregiver" toggle (changeable any time)
  - Specific copy adjusts (`Your medicines` → `Their medicines` when viewing a family-member profile)
- A free 8-page in-app guide ("Tips for caregivers") is unlocked — content sourced separately, lives as a single locale-string-based static screen.

## 3. What changes in the code

- **`lib/utils/preference.dart`** — add `caregiverModeEnabled` bool.
- **`lib/utils/constant.dart`** — add `Constant.idCaregiverMode` GetX update id.
- **`lib/ui/first_medicine/first_medicine_view.dart`** *(from F07)* — add the "Who is this for?" question before the medicine input.
- **`lib/ui/setting/setting_screen_view.dart`** — add toggle row.
- **`lib/ui/home/home_screens.dart`** — when caregiver mode is on, render the family-member tab strip more prominently (larger avatars, profile names visible — currently subtle).
- **`lib/ui/medicine_screen/medicine_screen_view.dart`** — title-line copy adjusts based on selected family member ("Your meds" / "Mom's meds").
- **NEW: `lib/ui/caregiver_tips/caregiver_tips_view.dart`** *(new file)* — static scrollable view with 8 short tip pages (locale-key driven).
- **`lib/routes/app_routes.dart`** + **`app_pages.dart`** — register caregiver tips route.
- **Locale files** — new keys, including the 8 tip pages.

## 4. Data model

No SQLite schema changes.

New `Preference` key:

```dart
static const String caregiverModeEnabled = "CAREGIVER_MODE_ENABLED";
Future<void> setCaregiverMode(bool v) => _pref!.write(caregiverModeEnabled, v);
bool getCaregiverMode()              => _pref!.read(caregiverModeEnabled) ?? false;
```

## 5. Locale keys

Onboarding question:

```
'txtCaregiverIntroQuestion': "Who is MediNest for?",
'txtCaregiverIntroOptionMe': "Just me",
'txtCaregiverIntroOptionFamily': "Me and my family",
'txtCaregiverIntroOptionOther': "I'm helping someone else",
```

Settings + UI:

```
'txtCaregiverModeSettingTitle': "Caregiver mode",
'txtCaregiverModeSettingSubtitle': "Show family-member features more prominently.",
'txtCaregiverHisMeds': "{name}'s medicines",
'txtCaregiverYourMeds': "Your medicines",
'txtCaregiverTipsLink': "Tips for caregivers",
```

Tips content (8 pages × ~60 words each — sourced separately, placeholders here):

```
'txtCaregiverTip1Title': "Set up the app for them, not for you",
'txtCaregiverTip1Body':  "[60-word body]",
... through txtCaregiverTip8.
```

## 6. Routing

Add `caregiverTips` route.

## 7. Implementation steps (linear)

1. Add `Preference` accessors.
2. Add `Constant.idCaregiverMode`.
3. Add locale keys (onboarding + settings + 8 tip pages). Replicate.
4. Update `first_medicine_view.dart` (from F07): inject the "Who is MediNest for?" prompt. On selection, set `caregiverModeEnabled` accordingly.
5. Add settings toggle.
6. In `home_screens.dart`: visual treatment of the family-member tab strip switches based on `caregiverModeEnabled`.
7. Adjust `medicine_screen_view.dart` title line.
8. Create `caregiver_tips_view.dart` with a `PageView` of 8 cards. Use existing widget primitives.
9. Wire route + Settings entry point ("Tips for caregivers" link, only visible when `caregiverModeEnabled`).
10. QA.

## 8. Manual test plan

**Golden path:**

1. Fresh install, onboarding.
2. On "Who is MediNest for?" choose "Me and my family".
3. **Expected:** caregiver-mode flag set; Home tab shows enhanced profile switcher; Settings has the toggle ON.

**Edge case 1 — Switch back:**

1. Settings → toggle OFF.
2. **Expected:** UI reverts. Family-member profiles are still in the database (don't delete them); they're just less prominent.

**Edge case 2 — Just-me user discovers caregiving need later:**

1. "Just me" user. Two months in, a parent gets sick. Settings → toggle ON.
2. **Expected:** caregiver mode UI activates. Tips link appears. No data loss.

**Edge case 3 — Tips content readability:**

1. Open Tips screen. Swipe through all 8.
2. **Expected:** all readable, no truncation, RTL works for Arabic.

**Regression check:**

Family member CRUD still works in both modes.

## 9. Rollout

- Standard release.
- Roll-back: revert toggle path. Setting key remains in storage harmlessly.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:

- All 8 tip pages have real content (not lorem ipsum)
- Onboarding answer correctly sets the preference
- Caregiver-mode UI difference is *noticeable but calm* (not gimmicky)

## 11. Out of scope

- "Caregiver-mode-only" features behind a new paywall (don't gate this; gating defeats the keyword claim)
- Real-time sync between caregiver and patient devices — that's F18 (`family-sync`)
- Voice / speech features for accessibility — separate spec

## 12. Open questions

1. Source of the 8 caregiver tips content. Recommendation: write internally based on real caregiver Reddit threads (per the strategies doc). Don't copy-paste from web articles. ~60 words each, helpful tone.
2. Should the "Tips for caregivers" link be visible to non-caregiver-mode users too (as discoverability for the feature)? Recommendation: no — would clutter Settings for solo users.

---

## Implemented — STAGE 1 (foundation only)

- Date: 2026-05-09
- versionCode shipped: pending
- **Stage 1 (this pass) — DONE:**
  - `lib/utils/preference.dart` — `caregiverModeEnabled` key + `getCaregiverMode/setCaregiverMode` accessors
  - `lib/localization/languages/language_en.dart` — `txtCaregiverModeSettingTitle`, `txtCaregiverModeSettingSubtitle`
  - 51 other locale files — same 2 keys with English fallback
  - `lib/ui/setting/setting_screen_logic.dart` — `caregiverMode` field + `onCaregiverModeChange()`
  - `lib/ui/setting/setting_screen_view.dart` — toggle row in the General section with `Assets.icons.icFamilyMember`
- **Stage 2 (deferred — needs your input):**
  - 8 caregiver tips content. Spec is explicit: do NOT generate from web articles or LLM. Source from real Reddit threads in r/Caregivers per `docs/strategies/reddit/`. Estimate 2 hours of writing time.
  - Caregiver tips screen (`lib/ui/caregiver_tips/`) + route + binding — straightforward once content exists.
  - UI prominence shift in `home_screens.dart` family-member tab strip when `caregiverMode == true` — needs design decision (bigger avatars? different layout?).
  - Conditional copy in `medicine_screen_view.dart` ("Mom's medicines" vs "Your medicines") — depends on `family_member_table.name` being set; needs UX agreement.
  - Onboarding question — blocked by F07.
- The Stage-1 toggle is functional: it persists and is queryable from anywhere via `Preference.shared.getCaregiverMode()`. Future code can gate features on this without further infra. The user just doesn't see any in-UI difference yet beyond the toggle itself.
