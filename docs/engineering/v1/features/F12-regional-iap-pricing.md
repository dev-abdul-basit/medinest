# F12 · Per-Region IAP Pricing

| | |
| --- | --- |
| Roadmap ref | T1-6 |
| Effort | ½ day in Play Console + ½ day in code |
| Risk | low |
| Schema change | no |
| New package | no |
| Premium-gated | n/a (this *is* the pricing) |
| ASO signals moved | $$ (revenue, not rank) |
| Status | spec |

## 1. Why we're shipping it

Currently a single global IAP price (5 SAR / month) auto-converts in Play. That's purchasing-power-mismatched: too cheap in US/EU, plausibly too expensive in some emerging markets. A 30-minute Play Console job moves revenue 30–60 % per `monetization-snapshot.md`.

This feature is mostly a Play Console operation. The code change is small but real: the in-app paywall must read the **localized** price string from `ProductDetails`, not assume a hardcoded "5 SAR".

## 2. What changes for the user

- A US user sees the monthly plan at $4.99 instead of $1.30.
- A Saudi user still sees 5 SAR.
- An Indian user sees ₹49.
- A Brazilian user sees R$9.90.
- The CTA button (from F01) renders the right currency for the user's Play account country.

Free-tier behavior is unchanged.

## 3. What changes in the code

- **`lib/in_app_purchase/in_app_purchase_helper.dart`** — confirm the helper exposes localized `ProductDetails.price` string. If not, refactor to do so.
- **`lib/ui/pro_version/pro_version_controller.dart`** — read `ProductDetails.price` and `priceCurrencyCode`. Display these on the plan cards.
- **`lib/ui/pro_version/pro_version_screen.dart`** — render localized prices. Don't hardcode "5 SAR" or "$4.99" in copy.
- **`lib/Widgets/common_subscribe_dialog.dart`** — already extended in F01 to accept `priceLabel`. Confirm it's actually populated everywhere from `ProductDetails`.
- **`pubspec.yaml`** — no changes.
- **Play Console** — the actual price-tier setup (Abdul's task, not Claude's).

## 4. Data model

No schema. No new `Preference`.

## 5. Locale keys

Audit existing pro-version copy for hardcoded prices. If any locale string contains a price string ("5 SAR", "$4.99"), replace with placeholder syntax:

```
'txtProMonthlyPriceLabel': "{price} / month",
'txtProYearlyPriceLabel': "{price} / year",
'txtProYearlySavings': "Save {percent}%",
```

`{price}` is interpolated at render time from `ProductDetails`. `{percent}` is computed from monthly vs yearly.

## 6. Routing

No changes.

## 7. Implementation steps (linear)

### Code side

1. Read `lib/in_app_purchase/in_app_purchase_helper.dart`. Confirm the helper queries product details on init and exposes them.
2. Read `pro_version_controller.dart` + `pro_version_screen.dart`. Find any hardcoded price strings or numbers.
3. Refactor: every price displayed comes from `ProductDetails.price`. The string is already locale-formatted by Play.
4. Add the locale keys above. Replicate.
5. Verify no other place in the app shows a price (search the codebase for `SAR`, `USD`, `5 SAR`, `4.99`, `$1`, etc.).
6. The CTA in `CommonSubscriptionDialog` (from F01) already accepts `priceLabel`. Wire the populated value from monthly product details.

### Play Console side (Abdul's task — document here)

1. Play Console → Monetize → Products → Subscriptions → "Premium monthly" → Pricing.
2. Switch from "Single global price" to "Set prices manually for selected countries".
3. Use Play's pricing tier suggestions for these markets:

| Market | Monthly | Yearly | Notes |
| --- | --- | --- | --- |
| US, CA, AU, GB | $4.99 | $39.99 | Anchor against Medisafe ($4.99) |
| EU (DE, FR, IT, ES, NL) | €4.99 | €39.99 | |
| Saudi Arabia | 5 SAR (current) | 49 SAR | Don't raise — it's working |
| UAE, Qatar, Kuwait | 5 AED | 49 AED | MENA parity |
| India | ₹49 | ₹399 | High-volume / low-ARPU |
| Pakistan | ₹279 | ₹1 999 | |
| Indonesia | Rp 19 000 | Rp 149 000 | |
| Brazil | R$ 9.90 | R$ 79 | |
| Mexico | MX$ 35 | MX$ 269 | LATAM anchor |
| Turkey | ₺49 | ₺399 | Inflation-adjust quarterly |
| Egypt | EGP 49 | EGP 399 | |
| Philippines | ₱99 | ₱799 | |
| Nigeria | ₦999 | ₦7 999 | |
| Vietnam | đ 39 000 | đ 299 000 | |
| All other countries | Auto-convert from $4.99 | Auto-convert from $39.99 | Default for unlisted |

4. Save. Submit subscription update.
5. Wait 24 h for Play to propagate. Verify on a real device with a Play account in a different country (or VPN).

## 8. Manual test plan

**Golden path:**

1. Real device with Play account in Saudi Arabia. Open ProVersion.
2. **Expected:** monthly price shows `5 SAR`, yearly shows `49 SAR`.
3. Switch device's Play account to a US-region account. Reopen.
4. **Expected:** monthly shows `$4.99`, yearly shows `$39.99`.

**Edge case 1 — IAP not yet loaded:**

1. Force-quit. Open ProVersion immediately.
2. **Expected:** loading spinner or "Loading prices…" text. No `null` rendered.

**Edge case 2 — Country not in the table:**

1. Play account in Argentina (not listed above).
2. **Expected:** auto-converted price displays correctly. Not "$0.00" or "—".

**Regression check:**

Existing subscription purchase still completes successfully in sandbox.

## 9. Rollout

- Code change ships in next release.
- Play Console pricing change can be made any time and propagates 24 h. Recommend: ship code first, *then* update Play Console pricing — so when the new prices land, the app renders them correctly.
- Roll-back (Play Console): revert to single-price global. Roll-back (code): hardcode currency strings if the dynamic path breaks. Last resort.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:

- No hardcoded price strings in the app
- Real device tests across at least 2 currencies
- Play Console pricing matches the table above (or whatever Abdul ultimately chose — record the final table in `Implemented`)

## 11. Out of scope

- Promotional pricing / launch discounts (separate spec)
- A/B testing prices via Play's "intro pricing" feature — interesting but adds complexity
- Removing the yearly plan from any market — for v1 we offer both everywhere

## 12. Open questions

1. Final pricing table per market — the table above is a starting point; Abdul confirms before Play Console changes.
2. Should the app show the savings on yearly with a calculated percentage ("Save 33 %") or a hardcoded label? Recommend calculated, since price ratios may differ per market once tiers are set.

---

## Implemented — code side DONE; Play Console pricing pending Abdul

- Date: 2026-05-09
- versionCode shipped: pending
- **Code side (DONE):**
  - `lib/ui/pro_version/pro_version_screen.dart` — replaced `'$0.00'` placeholder with `'txtProLoadingPrice'.tr`. Replaced hardcoded `"per month"` with `'txtProPerMonth'.tr` / `'txtProPerYear'.tr`. **Bug fixed in scope:** the price display was always showing `products.last.price` (monthly) regardless of `isMonthlySelected`. Now correctly shows `products.first.price` for yearly. Documented inline.
  - `lib/localization/languages/language_en.dart` — 3 new keys (`txtProPerMonth`, `txtProPerYear`, `txtProLoadingPrice`).
  - 51 other locale files — same 3 keys with English fallback.
  - Final sweep confirmed no other hardcoded prices in `lib/`. The one remaining `"5.00 SAR"` reference is in the docstring comment for `InAppPurchaseHelper.monthlyPriceLabel` (added in F01) — documentation, not a displayed string.
- **Play Console side (pending Abdul):**
  - Set per-region pricing tiers per the table in spec section 7.
  - 24 h propagation expected after Play Console save.
- **Remaining open question (spec section 12):** dynamic "Save N%" calculation on the yearly card. Recommend implementing in a follow-up — adds value but requires real product data to verify the math at runtime.
