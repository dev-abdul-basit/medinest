# F01 · Paywall Copy Rewrite

| | |
| --- | --- |
| Roadmap ref | QW-1 |
| Effort | ½ day |
| Risk | low |
| Schema change | no |
| New package | no |
| Premium-gated | no (this *is* the paywall) |
| ASO signals moved | $$, ★ |
| Status | spec |

## 1. Why we're shipping it

Current paywall copy reads developer-style, doesn't name the upgrade benefit, and never anchors price. See `../../../context/monetization-snapshot.md` for the analysis. Three concrete issues identified there make this an obvious upgrade-rate lift; rewrite is half a day.

## 2. What changes for the user

User hits the medicine-count or appointment-count cap and sees `CommonSubscriptionDialog`.

**Before:** *"You have reached the limit. Please subscribe to the plan. (In the free version, you only have a limit of 10 medicines and appointments.)"*

**After (English source — translators handle the rest):**

- **Title:** *"Unlock unlimited medicines"*
- **Body:** *"You're using all 10 free medicines. Upgrade to Premium for unlimited medicines, unlimited reminders, and an ad-free experience."*
- **CTA button:** *"Upgrade — only 5 SAR / month"* (Note: do NOT hardcode the SAR price into the string. See section 5 for the fix.)
- **Secondary line below CTA:** *"Cancel anytime. No charge until you confirm."*

A second variant is needed for the appointment-cap path:

- **Title:** *"Unlock unlimited appointments"*
- **Body:** *"You're using all 10 free appointments. Upgrade to Premium for unlimited appointments, unlimited journals, and an ad-free experience."*

## 3. What changes in the code

- **`lib/Widgets/common_subscribe_dialog.dart`** — extend the existing widget so it can show a CTA button label and a secondary subtext. Currently it accepts `title`, `description`, `image`, `buttonText`, `onTapDelete` (sic — keep the existing param name to avoid breaking callers; rename in v2). Add: `ctaSubtext` (optional), `priceLabel` (optional, dynamic — rendered next to `buttonText`).
- **`lib/ui/home/home_controller.dart`** — replace the two existing `CommonSubscriptionDialog` invocations (medicine-cap, appointment-cap) with the new copy via locale keys. **Do not touch the trigger logic.**
- **`lib/ui/medicine_history_screen/medicine_history_screen_logic.dart`** — same change to its `CommonSubscriptionDialog` call.
- **`lib/ui/appointment_history_screen/appointment_history_screen_logic.dart`** — same.
- **`lib/localization/languages/language_en.dart`** — new keys (section 5).
- **`lib/localization/languages/language_*.dart`** — new keys with English fallback (every other locale file).

## 4. Data model

No schema changes. No new `Preference` keys.

## 5. Locale keys

Add to `language_en.dart` and replicate (with English fallback) into every other `language_*.dart`:

```
'txtPaywallTitleMedicines': "Unlock unlimited medicines",
'txtPaywallBodyMedicines': "You're using all 10 free medicines. Upgrade to Premium for unlimited medicines, unlimited reminders, and an ad-free experience.",
'txtPaywallTitleAppointments': "Unlock unlimited appointments",
'txtPaywallBodyAppointments': "You're using all 10 free appointments. Upgrade to Premium for unlimited appointments, unlimited journals, and an ad-free experience.",
'txtPaywallCtaUpgrade': "Upgrade",
'txtPaywallCtaSubtext': "Cancel anytime. No charge until you confirm.",
```

Note: the price (`5 SAR`) is **not** in any locale string. Reason: Play Store renders the user's local price automatically once the dialog reads the IAP product price from `InAppPurchaseHelper`. The CTA renders as `"Upgrade — {localizedPrice} / month"` in code, where `{localizedPrice}` comes from the `ProductDetails.price` field already exposed by the IAP helper.

If `ProductDetails.price` is unavailable at the time the dialog opens (e.g., IAP not initialized), fall back to rendering the CTA as just `txtPaywallCtaUpgrade` without the price suffix. **Do not show a placeholder like "$X.XX".**

## 6. Routing

No routing changes.

## 7. Implementation steps (linear)

1. Read `lib/Widgets/common_subscribe_dialog.dart` end-to-end to confirm the parameter names.
2. Add two optional params to `CommonSubscriptionDialog`: `ctaSubtext` (String?) and `priceLabel` (String?). Render `ctaSubtext` below the CTA button; render `priceLabel` appended to `buttonText` if non-null.
3. Add the 6 locale keys to `language_en.dart` (in alphabetical / logical block — match existing style).
4. Replicate the 6 keys into every other `language_*.dart` file with the English value as fallback. Bash one-liner is acceptable here:
   ```bash
   for f in lib/localization/languages/language_*.dart; do
     [ "$f" = "lib/localization/languages/language_en.dart" ] && continue
     # insert the 6 keys near the top of the map
   done
   ```
   Hand-verify Arabic and Hindi — those files are non-trivial.
5. Update the medicine-cap call site in `home_controller.dart`:
   - `title: 'txtPaywallTitleMedicines'.tr`
   - `description: 'txtPaywallBodyMedicines'.tr`
   - `buttonText: 'txtPaywallCtaUpgrade'.tr`
   - `ctaSubtext: 'txtPaywallCtaSubtext'.tr`
   - `priceLabel: ` — pull from `InAppPurchaseHelper`'s monthly product details. If null, pass null.
6. Same for the appointment-cap call site (use `txtPaywallTitleAppointments` / `txtPaywallBodyAppointments`).
7. Same for the medicine-history and appointment-history call sites.
8. Run `flutter analyze`. Address warnings on touched files only.

## 8. Manual test plan

**Golden path (medicine cap):**

1. Fresh install, sign in.
2. Add 10 medicines (any names, any times).
3. Tap "Add medicine" again.
4. **Expected:** dialog with title `Unlock unlimited medicines`, body about all 10 free medicines used, CTA `Upgrade — {price} / month` if IAP loaded else `Upgrade`, subtext `Cancel anytime. No charge until you confirm.`
5. Tap CTA → routed to `proVersion` screen (existing behavior, unchanged).

**Golden path (appointment cap):**

1. Same approach, add 10 appointments.
2. **Expected:** dialog with appointment-specific title and body.

**Edge case 1 — IAP product not yet loaded:**

1. Force quit the app, immediately reopen, immediately trigger paywall (e.g., add 11th medicine while offline).
2. **Expected:** CTA shows `Upgrade` without price. No layout glitch. No null exception.

**Edge case 2 — Premium user:**

1. Subscribe (real purchase, sandbox account).
2. Try to hit the cap.
3. **Expected:** no paywall, all features unlocked.

**Edge case 3 — Arabic locale:**

1. Switch app locale to Arabic from Settings → Language.
2. Trigger paywall.
3. **Expected:** dialog renders RTL, no truncation, key fallback works (English text shown until translator delivers Arabic, but no raw `txtPaywall...` keys visible).

**Regression check:**

Open the paywall through the medicine-history screen path. Verify no other dialog uses of `CommonSubscriptionDialog` (e.g., delete confirmations) broke. Specifically: trigger a medicine-delete; the `CommonDeleteConfirmation` widget is separate but uses similar visual language — confirm no shared style regressed.

## 9. Rollout

- Ship in the next release (versionCode bump). No flag.
- Roll-back: revert the four call-site files; revert the locale-key additions. Widget changes are additive (new optional params) so reverting only the callers leaves the widget tolerant of old-style calls.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically must hold:

- All 6 locale keys present in every `language_*.dart`
- `priceLabel` null-safe path verified manually
- Arabic (RTL) layout still works

## 11. Out of scope

- Paywall trigger logic (when to show) — unchanged
- Free tier limits (10/10) — unchanged
- IAP receipt validation — unchanged
- Adding analytics on paywall-shown / paywall-dismissed — separate spec, see future v2

## 12. Open questions

None — spec is unblocked. Implementation can begin.

---

## Implemented

- Date: 2026-05-09
- versionCode shipped: pending Abdul's release
- Commit SHA: pending Abdul's commit
- Deviations from spec:
  - Added one accessor to `InAppPurchaseHelper` — `String? get monthlyPriceLabel`. Spec said avoid substantive IAP changes; this is a one-line read-only getter, additive. Justified for clean call sites.
  - The `buttonText` parameter on `CommonSubscriptionDialog` was previously **declared but unused** — the CTA hardcoded `txtSubscribeNow`. Fixed it to actually use `buttonText` when provided, falling back to `txtSubscribeNow`. This is a latent-bug fix scoped to F01's intent.
- Files changed:
  - `lib/Widgets/common_subscribe_dialog.dart` — added `ctaSubtext` and `priceLabel` params, rendered subtext block, made `buttonText` honored, appended price label to CTA.
  - `lib/in_app_purchase/in_app_purchase_helper.dart` — added `monthlyPriceLabel` getter.
  - `lib/localization/languages/language_en.dart` — added 6 keys.
  - `lib/localization/languages/language_*.dart` × 51 — same 6 keys with English fallback (commented `// F01 — paywall copy rewrite (English fallback — translate)` marker).
  - `lib/ui/home/home_controller.dart` — both medicine-cap and appointment-cap call sites use new keys + price label.
  - `lib/ui/medicine_history_screen/medicine_history_screen_logic.dart` — call site updated (added IAP helper import).
  - `lib/ui/appointment_history_screen/appointment_history_screen_logic.dart` — same.
- Translation pipeline note: 6 new keys × 51 locale files need native-fluent translation. Top priority for ar-SA, id-ID, hi-IN, ur-PK, es-419, pt-BR per the localization roadmap.
- Pre-existing diagnostic noted (not changed): `home_controller.dart:592` unused `appointmentDataList` — predates F01.
- Lessons / notes for v2: the dialog's `image: Assets.images.imgSuscription.path` is still hardcoded across 4 call sites. Acceptable in v1 — same image always shown — but worth a single default if more call sites appear.
