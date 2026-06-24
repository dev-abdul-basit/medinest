# F13 · ProVersion Screen Copy Refresh (extends F01 pattern)

| | |
| --- | --- |
| Roadmap ref | follow-up to F01 (paywall copy rewrite) |
| Effort | ½ day |
| Risk | low |
| Schema change | no |
| New package | no |
| Premium-gated | n/a |
| ASO signals moved | $$, ★ |
| Status | spec |

## 1. Why we're shipping it

F01 rewrote the bottom-sheet paywall (`CommonSubscriptionDialog`). But the **full Subscription screen** at `AppRoutes.proVersion` — where users land after tapping the F01 CTA, OR via Settings → Subscribe — still has the old developer-style copy:

- A hardcoded English `MOST POPULAR` badge (not localized)
- Only **2 benefits** shown vs the **3** F01 promises
- A weak `Apply Now` CTA without price anchor
- A short `Cancel Anytime` line that doesn't carry the trust copy F01 introduced

This is a copy-only follow-up to F01, applying the same pattern to the screen the user actually buys from.

## 2. What changes for the user

Before:
- Card shows `MOST POPULAR` (English-only) → `Monthly` → `SAR 5.79` → `per month` → 2 benefit pills (Remove Ads, Add Unlimited Medicines)
- Button says `Apply Now`
- Below button: small `Cancel Anytime`

After:
- Card shows localized "Most Popular" badge → `Monthly` → `SAR 5.79` → `per month` → **3 benefit pills** (Remove Ads, Add Unlimited Medicines, Add Unlimited Appointments — matching F01's promises)
- Button says `UPGRADE — SAR 5.79` (or just `UPGRADE` if price not loaded — same fallback as F01)
- Below button: `Cancel anytime. No charge until you confirm.` (F01 subtext, reused)

## 3. What changes in the code

- **`lib/ui/pro_version/pro_version_screen.dart`**:
  - Replace hardcoded `'MOST POPULAR'` (line ~224) with `'txtMostPopular'.tr`
  - Duplicate the existing benefit-pill container once more, using `'txtAddUnlimitedAppointment'.tr` (key already exists; used by F01 dialog)
  - Replace `text: 'txtApplyNow'.tr` with the F01 `_buildCtaText`-style: `'txtPaywallCtaUpgrade'.tr` + price suffix from `InAppPurchaseHelper().monthlyPriceLabel`
  - Replace `'txtCancelAnytime'.tr` line with `'txtPaywallCtaSubtext'.tr` (already added in F01 to all 52 locales)
- **`lib/localization/languages/language_en.dart`**: add `txtMostPopular`: "Most Popular"
- **`lib/localization/languages/language_*.dart`** × 51: same key with English fallback

No other files touched.

## 4. Data model

No schema. No new prefs.

## 5. Locale keys

One new key:

```
'txtMostPopular': "Most Popular",
```

Reused (already added in F01):
- `txtPaywallCtaUpgrade`
- `txtPaywallCtaSubtext`

Reused (existed before F01):
- `txtAddUnlimitedAppointment`

## 6. Routing

No routing changes.

## 7. Implementation steps

1. Add `txtMostPopular` to `language_en.dart`.
2. Replicate to 51 non-en locale files with English fallback (Node injection script, same shape as F01 / F08).
3. Edit `pro_version_screen.dart`:
   - Replace `'MOST POPULAR'` literal with `'txtMostPopular'.tr`
   - Duplicate the second benefit-pill block once with `txtAddUnlimitedAppointment`
   - Update the CommonButton: build CTA text with price suffix (use `InAppPurchaseHelper().monthlyPriceLabel`)
   - Update the cancel-anytime CommonText to use `txtPaywallCtaSubtext` instead of `txtCancelAnytime`
4. Verify in-app on emulator/device.

## 8. Manual test plan

**Golden path:**
1. Open Settings → Subscribe (or hit medicine cap → tap UPGRADE in F01 dialog).
2. **Expected:** card with `Most Popular` badge (in current locale), `Monthly`, `SAR X.XX`, `per month`, three benefit pills (Remove Ads, Unlimited Medicines, Unlimited Appointments).
3. **Expected:** CTA reads `UPGRADE — SAR X.XX` if products loaded, else `UPGRADE`.
4. **Expected:** subtext below CTA reads `Cancel anytime. No charge until you confirm.`

**Edge case 1 — IAP not loaded:**
1. Force quit, immediately open ProVersion.
2. **Expected:** price area shows `Loading price…` (already F12 behavior); CTA reads `UPGRADE` without price suffix; no crash.

**Edge case 2 — Arabic:**
1. Switch to ar locale.
2. **Expected:** RTL layout, English fallback strings render until translator delivers.

## 9. Rollout

- Ship in next versionCode bump.
- Roll-back: revert the screen file; the new locale key remains in storage harmlessly.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:
- No more hardcoded English on this screen
- 3 benefits match the F01 dialog promises
- CTA uses F01 pattern

## 11. Out of scope

- Restoring the yearly card. It's commented out in this file (lines 371-501). Bringing it back requires layout work + `onChangePlanSelection(false)` wiring; tracked separately as **F13a**.
- Visual redesign (gradient, badges) — keep current visual identity.
- Removing the unused `txtCancelAnytime` key — leave it (might be referenced elsewhere; cleanup pass for v2).
- Removing `txtApplyNow` key — same reasoning.

## 12. Open questions

None.

---

## Implemented

- Date: 2026-05-10
- versionCode shipped: pending
- Files changed:
  - `lib/ui/pro_version/pro_version_screen.dart`:
    - Added `InAppPurchaseHelper` import
    - `'MOST POPULAR'` literal → `'txtMostPopular'.tr.toUpperCase()`
    - CTA: `'txtApplyNow'.tr` → `Builder` block computing `'UPGRADE — {price}'` from `InAppPurchaseHelper().monthlyPriceLabel`, fallback to plain `UPGRADE`
    - Subtext: `'txtCancelAnytime'.tr` (small centered) → `'txtPaywallCtaSubtext'.tr` wrapped in horizontal `Padding` with `TextAlign.center`
    - Added third benefit pill (`txtAddUnlimitedAppointment`) duplicating the visual style of the existing two
  - `lib/localization/languages/language_en.dart` — added `txtMostPopular`: "Most Popular"
  - 51 other locale files — `txtMostPopular` with English fallback
- Reused existing keys (no new translation work for these): `txtPaywallCtaUpgrade`, `txtPaywallCtaSubtext`, `txtAddUnlimitedAppointment`
- 2 new deprecation warnings on the duplicated third-benefit block — they match the existing two benefit rows exactly. Per canon: do not isolate-fix.
- Pre-existing keys NOT removed: `txtApplyNow`, `txtCancelAnytime`. Left in 52 locale files as harmless dead keys; cleanup pass for v2.
