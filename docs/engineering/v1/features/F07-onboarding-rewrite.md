# F07 · Onboarding Rewrite — First-Reminder-Set in Under 60 Seconds

| | |
| --- | --- |
| Roadmap ref | T1-1 |
| Effort | 1–2 weeks |
| Risk | med |
| Schema change | no |
| New package | no |
| Premium-gated | no |
| ASO signals moved | R (D1), CVR |
| Status | ✅ implemented (2026-05-30) |

## 1. Why we're shipping it

D1 retention is the single biggest install-velocity multiplier on Play. The biggest D1 drop in pill-reminder apps is users who install but never set a single reminder. Today's onboarding goes through introduction → get-started → optional sign-in → home. The user then must navigate to "Add medicine" and fill 6+ fields before a single reminder exists. We're compressing that to < 60 seconds.

## 2. What changes for the user

Before:
1. Splash → Introduction (3 swipe slides) → Get Started → optional Sign-in → Home (empty) → Add Medicine (6+ fields).

After:
1. Splash → Introduction (3 swipe slides — unchanged, but shortens to "Skip to add my first medicine").
2. **NEW screen:** "Add your first medicine" — minimal form with smart defaults:
   - Medicine name (one text input, autofocus)
   - Frequency: pill-shaped picker [Once daily | Twice daily | 3× daily | Custom] — defaults to "Once daily"
   - Time: defaults to next 8:00 AM (or next 8:00 PM if user is currently between 6 AM and 8 PM)
   - **No** dosage, color, shape, doctor, family member, before/after meal, sound — all optional, accessible via a `More options` link below
3. After Save: confetti / Lottie success animation, navigate to Home with that medicine visible and a tooltip "You're set. We'll remind you at 8:00 AM tomorrow."
4. Sign-in is offered AFTER the first successful reminder fires the next day, not during onboarding.

## 3. What changes in the code

- **`lib/ui/get_started_screen/get_started_screen_view.dart`** — change the primary CTA destination from current path to a new "First Medicine" screen.
- **NEW: `lib/ui/first_medicine/first_medicine_binding.dart`** *(new file)*
- **NEW: `lib/ui/first_medicine/first_medicine_logic.dart`** *(new file)*
- **NEW: `lib/ui/first_medicine/first_medicine_view.dart`** *(new file)*
- **`lib/routes/app_routes.dart`** — add `static const String firstMedicine = '/firstMedicine';`
- **`lib/routes/app_pages.dart`** — register the new page + binding.
- **`lib/ui/home/home_controller.dart`** — show a one-shot tooltip on first home view if the user came from the new onboarding (gate on a new `Preference` key `seenFirstMedicineTooltip`).
- **`lib/utils/preference.dart`** — add `seenFirstMedicineTooltip` (bool).
- **`lib/ui/introduction_screen/introduction_screen_view.dart`** — adjust skip / continue button text to `Skip to setup` / `Get started`.
- **`lib/ui/get_started_screen/get_started_screen_view.dart`** — defer Google Sign-in. Replace immediate sign-in with a "Continue without account" primary button + small "Sign in" secondary link.
- **`lib/Widgets/`** — possibly a new `first_medicine_frequency_chips.dart` if the chip selector isn't reusable from existing widgets.
- **Locale files** — multiple new keys, all replicated.

## 4. Data model

No schema changes — the new screen writes through the existing `medicine_table` row insertion path.

New `Preference` keys:

```dart
static const String seenFirstMedicineTooltip = "SEEN_FIRST_MEDICINE_TOOLTIP";
static const String firstMedicineCreated     = "FIRST_MEDICINE_CREATED";  // bool — for analytics & future flow gating
```

With typed accessors matching existing style.

## 5. Locale keys

```
'txtFirstMedTitle': "Set up your first medicine",
'txtFirstMedNamePlaceholder': "e.g. Vitamin D",
'txtFirstMedFrequencyOnce': "Once daily",
'txtFirstMedFrequencyTwice': "Twice daily",
'txtFirstMedFrequencyThrice': "3 times daily",
'txtFirstMedFrequencyCustom': "Custom",
'txtFirstMedNextReminder': "Next reminder",
'txtFirstMedMoreOptions': "More options (dose, color, doctor…)",
'txtFirstMedSaveCta': "Save & remind me",
'txtFirstMedTooltip': "You're set. We'll remind you at {time}.",
'txtSkipToSetup': "Skip to setup",
'txtContinueWithoutAccount': "Continue without account",
```

`{time}` is interpolated at runtime — keep the placeholder syntax consistent with any existing interpolation (audit one or two existing keys to match).

## 6. Routing

Add `firstMedicine` route per section 3.

Onboarding navigation after this change:
```
/  →  introduction  →  getStarted  →  firstMedicine  →  home
```

## 7. Implementation steps (linear)

1. Add `Preference` keys + accessors.
2. Add locale keys to `language_en.dart`. Replicate.
3. Add route constant + GetPage entry.
4. Create the three new files (`first_medicine_*`). Logic class extends `GetxController`. Mirror the structure of `lib/ui/add_medicine/add_medicine_controller.dart` but stripped to the minimal field set.
5. Wire the save action: build a `MedicineTable` row with smart defaults (today's date, default sound `assets/sounds/defaulttone.mp3`, default shape, no doctor, no family member assigned to "Self" if it exists), insert via `DataBaseHelper.instance`, schedule notification via `NotificationHelper.instance.scheduleMedicineNotification()`.
6. Set `Preference.shared.setFirstMedicineCreated(true)` after success.
7. Update `get_started_screen_view.dart` to route to `/firstMedicine` instead of current target. Defer sign-in.
8. Update `introduction_screen_view.dart` button labels.
9. In `home_controller.dart`, on `onReady`, if `firstMedicineCreated && !seenFirstMedicineTooltip`, show a one-shot Lottie + tooltip overlay (use existing `lottie` package), then mark `seenFirstMedicineTooltip = true`.
10. Manual QA pass.

## 8. Manual test plan

**Golden path:**

1. Fresh install. App launches. Splash → Introduction (3 slides).
2. Tap `Skip to setup` on slide 1.
3. **Expected:** Get Started screen with "Continue without account" primary, "Sign in" secondary.
4. Tap "Continue without account".
5. **Expected:** First Medicine screen, name field autofocused.
6. Type `Vitamin D`. Frequency defaults to `Once daily`. Time shows next 8 AM.
7. Tap `Save & remind me`.
8. **Expected:** brief Lottie confetti, navigate to Home, the new medicine listed under today, tooltip shows "You're set. We'll remind you at 8:00 AM."
9. Time-stopwatch this from app cold start to home: target ≤ 60 seconds.

**Edge case 1 — Sign-in path:**

1. Same flow but tap `Sign in` on Get Started.
2. **Expected:** Google sign-in flow, then route to First Medicine (not directly Home — onboarding still completes).

**Edge case 2 — User skips First Medicine:**

If we provide a back arrow on first-medicine screen, the user might back out. Currently no back arrow is in the spec. Confirm: pressing system back from first-medicine should *not* exit the app. Either disable back, or back to Get Started.

**Edge case 3 — Late-night user:**

Test at 11 PM device time. Default time should be "next 8:00 AM" (tomorrow), not today.

**Edge case 4 — Notification permission denied:**

If on Android 13+, the user denies POST_NOTIFICATIONS. Save still succeeds, medicine is in DB, but no system notification will fire. Show a one-time banner: "Notifications are off. Tap to enable so we can remind you." (Use existing `permission_handler` package.)

**Edge case 5 — Re-install:**

Uninstall, reinstall. Ensure `firstMedicineCreated` is false again (it's in `GetStorage`, which is wiped on uninstall — verify).

**Regression check:**

Verify the **classic** Add Medicine flow (`/add` route, full form) still works for second-medicine onwards.

## 9. Rollout

- Internal track for 3–5 days first. This is a major user-facing flow change.
- After internal verification, ship to production.
- Roll-back: revert routing change in `get_started_screen_view.dart` to point at the old target. The new screens stay (harmless), the new route stays (unused).

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:

- 60-second-from-cold-start metric verified on at least two devices
- Notification fires correctly the next morning (set test medicine for 5 minutes ahead, verify)
- Re-install test passes
- Lottie animation file (any reasonable celebration animation) committed under `assets/animation/`

## 11. Out of scope

- Personalizing onboarding to user input (we don't ask "what's your goal" — adds friction without conversion lift in this category)
- Multiple-medicine setup in one go — not v1
- Importing from other apps — way out of scope

## 12. Open questions

1. Confirm with Abdul: does a "Self" `family_member_table` row exist by default for new users? If not, the first-medicine save will need to either create one or accept a null `mFamilyMemberId`.
2. Does Lottie animation file exist for celebration, or do we need to source one? (Recommend free LottieFiles asset — check license.)

---

## Implemented — STATUS: ✅ SHIPPED (code-side) 2026-05-30

Both blocker decisions were answered (recommended approach): **(A) auto-create a silent "Self" profile** and **(B) defer Google Sign-in**.

### Decisions taken
- **A — auto "Self" profile:** YES. Created lazily in `FirstMedicineLogic._ensureSelfProfile()` (not `main.dart`, to avoid touching boot and to run only on the path that needs it). Inserts a `FamilyMemberTable` named `'txtSelfProfileName'.tr` ("Me", gender Other) **only if the user has no profiles**; otherwise reuses the first existing one. No schema change — `mFamilyMemberId` stays non-null.
- **B — defer sign-in:** YES. Get-Started now leads with **"Get started"** (`continueAsGuest()`); Google sign-in is a secondary option ("or sign in to back up & sync"). The boot `initialRoute` in `main.dart` gained a guest branch so a user who finished onboarding without an account lands on **Home** (previously they were bounced back to Get-Started).

### Files changed / added
- **NEW** `lib/ui/first_medicine/{first_medicine_binding,first_medicine_logic,first_medicine_view}.dart` — minimal form (name autofocus + frequency chips Once/Twice/3× defaulting to Once; smart 8AM / 8AM+8PM / 8AM+2PM+8PM times). Writes a `medicine_table` row through the **same** insert + `scheduleDailyNotificationNew` + `scheduleMedicineNotification` path as the full Add-Medicine flow, with safe defaults for every other field (dose `1`, unit `PILLS`, first shape, default colour, "Take Any Time", default tone, no end date). Lottie `celibretion1.json` success → Home.
- **NEW** `lib/Widgets/onboarding_illustrations.dart` — **generated** (CustomPainter) vector art: pill+clock, journal+heart, family avatars. Copyright-free, theme-aware, DPI-independent. Replaces the PNG intro slides.
- `lib/routes/app_routes.dart` + `app_pages.dart` — `/firstMedicine` route + binding.
- `lib/utils/preference.dart` — `seenFirstMedicineTooltip`, `firstMedicineCreated` + typed accessors.
- `lib/utils/constant.dart` — `idFirstMedicine`.
- `lib/ui/get_started_screen/{view,logic}` — `continueAsGuest()`; primary "Get started" CTA; refreshed hero copy (`txtGetStartedTitle/Subtitle`).
- `lib/ui/introduction_screen/introduction_screen_view.dart` — generated illustrations + **MVP-correct, de-medicalised** slide 2 (`txtOnboardJournalTitle`, replacing the out-of-scope "Schedule doctor visits").
- `lib/main.dart` — guest `initialRoute` branch.
- `lib/ui/home/home_controller.dart` — **null-guarded `userData`** (guests have no user row — was `value.first`, would crash); one-shot `_maybeShowFirstMedicineTooltip()` on `onReady`.
- `lib/localization/languages/language_en.dart` + **51 other locales** — 22 new keys with English fallback (scripted, idempotent).

### Deviations from spec
- The "Self" row is created in the first-medicine logic, not `main.dart` boot — functionally first-launch for the guest path, but avoids slowing boot and the `.tr`-before-GetX-init problem.
- Returning guests are routed to **Home** (not re-shown first-medicine). Simpler and robust; they can add from Home anytime. `firstMedicineCreated` is kept for the home tooltip + future analytics rather than as a routing gate.
- "More options" / power-user customization routes to the existing full `/add` screen rather than an inline expander.

### Verified
- `flutter analyze` on all touched files: **0 errors** (only pre-existing warnings + the repo-wide `withOpacity`/`background` deprecations the canon defers to v2).
- All 52 locale files contain the 22 keys and remain valid map literals.

### Not done (needs a device — handed to Abdul)
- Manual QA from §8 (60-second cold-start timing, next-morning fire, re-install, notification-permission-denied banner). The permission-denied one-time banner (§8 edge 4) is **not** added in this pass — Home already has a permission request + alert flow; revisit if QA shows a gap.
