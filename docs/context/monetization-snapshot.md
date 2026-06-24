# Monetization Snapshot

Frozen 2026-05-09. Update when ad placements change or a new IAP product ships.

## AdMob

| Placement | Type | File |
| --- | --- | --- |
| Home | Banner + Interstitial | `lib/ui/home/home_screens.dart`, `lib/ui/home/home_controller.dart` |
| Family Member screen | Banner | `lib/ui/family_member_screen/family_member_screen_view.dart` |

Interstitial fires on a counter (`Preference.getInterstitialAdCount % N`). The exact `N` and which user actions tick the counter live in `home_controller.dart` — audit before any "more installs" push, because frequency × install volume is what drives 1-star reviews.

> Banner ad on the Home screen is the single biggest review-risk in the app. Pill-reminder is a stress / health context. Review sentiment in this category punishes ad density harder than productivity apps. Quantify with a review-keyword scan after step 1 of `NEXT-STEPS.md` is done.

## In-app purchase

Implementation: `lib/in_app_purchase/iap_receipt_data.dart` + `pro_version_controller.dart` (`isSelected true for monthly and false for yearly`).

| Plan | Price | Status |
| --- | --- | --- |
| Monthly | **5 SAR** (~ $1.33 USD) | Live — **being repriced to USD (see below)** |
| Yearly | TBD — fill in from Play Console | Live (assumed) — repricing |

> **US repricing (2026-05-30) — primary market is now the United States.** 5 SAR (~$1.33) is far below the US category norm; US pill-reminder premiums sit at **$4.99–9.99/mo**. **Decided 2026-05-30:** **$3.99/mo · $19.99/yr** (yearly ≈ $1.67/mo, ~58% effective discount). Sits just under Medisafe ($4.99) to aid first-install conversion for a newer app; it's a launch hypothesis to A/B later, not a validated willingness-to-pay number. The code already reads the live store price via `InAppPurchaseHelper.monthlyPriceLabel` (F12 fix), so once Play Console tiers are set the in-app paywall reflects them with no code change. **Action (Abdul):** create the $3.99 monthly + $19.99 yearly tiers in Play Console.

Premium unlocks (per `store_listing_desc.txt`):

- Ad-free
- Unlimited medicines
- Unlimited reminders
- Unlimited journals / notes

### Pricing notes — do not skip

- 5 SAR is a very low price point. Healthy in MENA. **Will distort LTV** if non-MENA installs come in at the same SAR-equivalent. Set Play Console price tiers per region — don't let `auto-convert` ship $1.33 in the US, where pill-reminder competitors charge $4.99–9.99/mo.
- Annual should be priced with ~30–40 % effective discount vs monthly to anchor the upgrade. If the math is off, the upgrade rate stays low regardless of paywall design.
- Play Store's "Compare plans" dialog reads from your IAP product titles + descriptions. They are part of ASO. Currently undocumented here — capture them in this file when you next open Play Console.

## Free-tier paywall triggers

User hits the IAP modal (`CommonSubscriptionDialog`) when:

1. Adding the 11th medicine (`home_controller.dart`)
2. Adding the 11th appointment
3. Hitting medicine-history / appointment-history limits (`*_history_screen_logic.dart`)

Copy used at trigger today:
> "You have reached the limit. Please subscribe to the plan. (In the free version, you only have a limit of 10 medicines and appointments.)"

> This copy is functional but not optimized. Three concrete issues, fix in code (low effort, affects revenue not ASO directly):
> 1. Doesn't say what they get for upgrading — only what they lose.
> 2. Parenthetical is for the developer, not the user.
> 3. No price anchor — user hits a "subscribe" CTA without seeing it's only 5 SAR / month.

These are tracked as `feature-improvements/feature-roadmap.md` → "Paywall copy rewrite".
