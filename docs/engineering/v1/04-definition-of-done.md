# Definition of Done (v1)

A v1 feature is *done* when **all** of these are true. Not most. All.

> If a checkbox isn't honestly checkable, the feature is not done. We don't ship "done-ish".

---

## Code

- [ ] Implementation conforms to `02-architecture-canon.md` — no new patterns introduced
- [ ] No new packages added beyond what the spec approved
- [ ] No `print(...)` in the diff. All logs go through `Debug.printLog`
- [ ] No raw `Color(0xFF...)` in feature code. All colors via `Get.theme.colorScheme.<role>`
- [ ] No magic-number sizes. All via `AppSizes` / `AppFontSize` from `sizer_utils.dart`
- [ ] No hardcoded English strings. All user-visible text via `'txtKey'.tr`
- [ ] All new `txt` keys present in `lib/localization/languages/language_en.dart` AND `language_ar.dart` AND every other locale file (English fallback acceptable as placeholder)
- [ ] Any new `Preference` key has a typed getter/setter pair (no raw `_pref!.read` from feature code)
- [ ] No `// AI generated` or similar markers anywhere
- [ ] `analysis_options.yaml` lints pass (`flutter analyze` — Abdul runs)

## Schema (only if applicable)

- [ ] DB version in `database_helper.dart` bumped
- [ ] Migration SQL in the version-bump block, idempotent and tested manually
- [ ] Existing rows migrate without data loss (verify on a device with pre-existing data)
- [ ] Firestore sync still works after schema change

## UI

- [ ] Light + Dark themes both render acceptably
- [ ] Real device test on Android ≥9 (low end) and Android ≥13 (newer)
- [ ] Arabic (RTL) renders correctly — text alignment, padding, navigation arrows mirrored
- [ ] No layout overflow on small phones (5.5" / 720×1280)
- [ ] No regression on tablets if the feature surfaces on tablet layouts

## Notifications (if affected)

- [ ] Existing pending notifications still fire after the change
- [ ] If notifications were rescheduled: confirm count under cap (Android 400 / iOS 45) via `checkPendingNotificationRequests()`
- [ ] DND / silent / low-battery scenarios manually verified for any notification path the feature touches

## Premium / Ads (if affected)

- [ ] `Preference.shared.getIsPurchase()` correctly suppresses ads / unlocks features
- [ ] `Debug.googleAd = false` path verified — feature works in dev mode without ad SDK
- [ ] AdMob unit IDs still only in `ad_helper.dart`. No leakage.

## Locale & ASO

- [ ] New strings reviewed for keyword surface area against `../../aso/02-keyword-research.md` (when applicable — e.g., onboarding, paywall, feature naming)
- [ ] Translation pipeline note added to `Implemented` block: which keys need native-fluent translation before next release

## Process

- [ ] Spec is updated to match what actually shipped (deviations noted in `Implemented`)
- [ ] Manual test plan run end-to-end by Abdul (not just by Claude)
- [ ] At least **one** regression check on an adjacent feature passed
- [ ] Commit message follows: `feat(F0X): <short description>` or `fix(F0X): ...`
- [ ] versionCode bumped in `pubspec.yaml`
- [ ] Spec's `Implemented` block filled in (date, versionCode, commit SHA, deviations)

## Forbidden in v1 — explicit "do nots"

- No tests added (we have none; one alone creates inconsistency)
- No CI added
- No new top-level `lib/` folders
- No package upgrades unless spec explicitly approved
- No silent dependency on a Play Console state Abdul hasn't verified

---

## When DoD blocks shipping

If a checkbox can't be checked truthfully, you have two options:

1. **Fix it** — almost always the right answer. Most blockers are 30 minutes of additional work.
2. **Document the gap and de-scope** — split the spec, mark the missed item as a follow-up F0Xa, ship what's done.

What you don't do: pretend the box is checked. The DoD is the contract; lying to it makes the contract worthless.
