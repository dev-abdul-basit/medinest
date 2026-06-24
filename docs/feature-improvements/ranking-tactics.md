# Ranking Tactics — Where, How, and Why

Companion to `../aso/05-aso-roadmap-90day.md`. The roadmap is *when*; this is *where, how, why*.

---

## Where to rank — country priority, with reasoning

We do not chase global #1. We chase **#1–10 in 6–10 markets where we can actually win**, then defend.

### Tier A — primary markets (focus all of Q1)

#### Saudi Arabia (ar-SA)
- **Why first:** pricing already in SAR. App already translated to ar-SA. Lower competitor density vs en-US.
- **Target keywords:** `تذكير بالدواء`, `منبه الدواء`, `pill reminder` (English-fluent users still search in English on Saudi store)
- **Realistic Day-90 target:** top 10 on `تذكير بالدواء`, top 25 on `pill reminder`
- **Tactic:** localized listing in Week 4. Focus first 4 weeks of social on MENA-friendly times (post 8–10 pm Saudi time = high engagement window).

#### Indonesia (id-ID)
- **Why second:** highest install volume / lowest competition ratio in this category. Very high engagement, low ARPU but reliable ad revenue.
- **Target keywords:** `pengingat obat`, `pengingat minum obat`, `obat reminder`
- **Realistic Day-90 target:** top 10 on `pengingat obat`, top 5 on long-tail
- **Tactic:** localized listing in Week 6. Engagement on r/indonesia. Indonesian X is small for healthtech — focus is store-side.

#### India (hi-IN, en-IN)
- **Why third:** enormous volume, real competition, but the long tail is wide open. en-IN listing should be separate from en-US.
- **Target keywords:** `दवा रिमाइंडर`, `medicine reminder` (en-IN), `tablet reminder`
- **Realistic Day-90 target:** top 25 on `medicine reminder` (en-IN), top 10 on Hindi long-tail
- **Tactic:** localized listing in Week 7. Reddit r/india is active for this niche. Pricing tier set very low (e.g., ₹49/mo).

### Tier B — secondary markets (Q2)

#### Pakistan (ur-PK, en-PK)
- **Why:** very low competition, real demand, brand-overlap with Indian audience helps.
- **Realistic target:** top 10 on `medicine reminder` and Urdu equivalents.

#### Philippines (en-PH)
- **Why:** uses en-US listing largely, but a localized en-PH variant + Filipino mention can lift CVR 20–40 %.
- **Realistic target:** top 25 on `pill reminder`.

#### Mexico + LATAM (es-419)
- **Why:** large Spanish-speaking population, separate listing from Spain's es-ES.
- **Realistic target:** top 15 on `recordatorio de medicamentos` (es-419).

#### Brazil (pt-BR)
- **Why:** distinct market from Portugal. Strong healthtech engagement. App must be localized.
- **Realistic target:** top 15 on `lembrete de remédios`.

### Tier C — defensible long-term (Q3+)

Turkey, Egypt, Bangladesh, Vietnam, Nigeria. Each has the same shape: large mobile-first user base, low competitor density, low ARPU (which suits ads + low-priced premium).

### Tier D — defer (do not chase in Year 1)

US-EN, UK-EN, AU-EN, DE-DE, FR-FR, JP-JP. Reason: Medisafe / MyTherapy / Round / Mango / CareClinic dominate. We compete here on Year 2 once we've built a real review base + features in Tier A markets.

---

## How to rank — the four levers, in priority order

### Lever 1 — Listing relevance (40 % of effort)

Direct keyword match in the **right field weight**:
- Title (highest weight): one head term + brand
- Short description (next): two head terms + benefit verb
- Long description: structured around 5–7 keywords, ≤5 occurrences each
- Localized: title + short + long for each Tier-A locale

This is what `../aso/01-store-listing.md` and `../aso/02-keyword-research.md` are for.

### Lever 2 — Conversion rate (30 % of effort)

Play Store algorithm rewards listings that *convert* impressions to installs. Listings that show in 1 000 results and get 60 installs outrank listings that show in 1 000 and get 20.

Levers in our control:
- Hero screenshot quality (`../aso/04-screenshot-strategy.md`)
- Title clarity
- Star rating (visible above the fold)
- Localized creatives in non-English markets
- Feature graphic quality

A 1 % CVR lift moves rank more reliably than a 30 % keyword-density change.

### Lever 3 — Velocity & retention (20 % of effort)

Algorithm watches:
- Installs per day (especially from search results, not from direct/branded traffic)
- Uninstalls per day
- D1 / D7 / D30 retention
- Sessions per user
- ANR / crash rate

You can't fake velocity, but you can:
- Time releases to align with social pushes (a content week with a release looks like real momentum to the algorithm)
- Fix the onboarding flow — D1 retention is the single biggest force multiplier
- Reply to every review (engagement signal)

### Lever 4 — Reviews & ratings (10 % of effort)

Ratings volume + freshness, not just average. A 4.6 with 30 reviews in the last 30 days outranks a 4.8 with 4 reviews in the last 30 days for most keywords.

How to move:
- QW-2 in `feature-roadmap.md` (review-prompt timing)
- Reply to every review, especially negative ones — Play boosts apps with high developer reply rate
- Never buy reviews. Sitewide ban risk.

---

## Why these levers and not others

Things that don't matter as much as ASO advice claims:

- **Backlinks to Play Store URL.** Marginally indexed. Not worth a link-building campaign.
- **Press mentions.** Help velocity *if* they drive installs that day; don't help rank otherwise.
- **App size / install size.** Affects organic install rate ~3–5 %. Real but not a primary lever.
- **Number of permissions.** Affects trust, indirectly affects rating. Not a direct ranking signal.
- **Update frequency.** Real signal but binary — apps that update are above apps that don't. Beyond monthly, no extra benefit.

Things that matter more than people think:

- **Localization quality.** Native-fluent translation can 2–5× rank in non-English markets. Machine translation doesn't move it at all.
- **Time-of-day install patterns.** Healthy apps install across the day. Apps that install at 3 am are flagged. Don't run incentivized install campaigns.
- **Country pricing.** Pricing too high in low-ARPU countries depresses install velocity, which hurts rank.
- **Replying to negative reviews.** Some users edit their 1-star to 4-star after a developer reply. Real and trackable.

---

## Specific tactical plays per lever

### Tactical: how to claim a long-tail keyword we don't currently rank for

1. Confirm the keyword has ≥100 estimated monthly searches in the target country (AppFollow).
2. Add it to long description, exactly **two times**, in different sections.
3. Add it to one screenshot caption if it fits naturally.
4. Run it for 2 weeks. Check rank.
5. If we haven't moved into top 100 for that keyword in 2 weeks, increase to **three** mentions and add to short description if it fits.
6. If still no movement at week 4, drop the keyword and pick another.

### Tactical: how to defend a keyword once we hit top 10

1. Don't change the listing for that keyword.
2. Keep update cadence ≥monthly (freshness).
3. Make sure new screenshots, when we rotate them, still feature the keyword visually.
4. Reply to every review that mentions or implies that keyword — review text feeds the same index.

### Tactical: handling a 1-star review storm

If we ever get hit (it happens — a Play update breaks notifications and 30 users 1-star us in 2 days):

1. Don't panic. Reply to each review with a clear acknowledgment, the timeline for the fix, and a way to reach you directly.
2. Push the fix as a release within 7 days.
3. After fix is live, reply again on each review with a release-version reference, ask the user to consider re-rating.
4. Some will. ~20–40 % is the typical recovery rate.
5. Run a "thank you" review-prompt cycle on retained users to add positive reviews on top.

This is real recovery; not theoretical.

### Tactical: getting featured by Play

Play "Editor's Choice" / featured collections are largely opaque, but patterns we know:

- Apps in active categories with a clean compliance record get considered.
- Submitting via the [Google Play Editorial form](https://play.google.com/console/about/programs/editorial/) (real link — use it) gives visibility to the editorial team.
- The angle that lands: "solo developer, multi-locale, accessibility-friendly, family use case." That's exactly MediNest's positioning.

Submit by Day 60. Even a single feature placement can do 50–500k installs.

---

## What we will NOT do to rank

Listed so we're explicit:

1. **Buy installs.** Detected. Banned. Sitewide.
2. **Buy reviews.** Detected. Banned.
3. **Use install bots.** Detected. Banned. Permanently.
4. **Cross-promote with apps that look like ours.** Looks like incentivized installs to Google. Risky.
5. **Aggressive review-pumping (showing review prompt on every open).** Drops average rating because annoyed users 1-star you.
6. **Stuff keywords in long description.** Detected. Penalized.
7. **Hide pricing or use dark-pattern paywalls.** Triggers manual review and 1-star reviews.

These shortcuts kill apps. Don't be one of them.

---

## Seasonality notes

Pill-reminder installs are weakly seasonal. Patterns I'd watch for as we accumulate data:

- **January spike** — New Year health resolutions. Real, ~15–25 % above baseline.
- **Cold/flu season** (NH winter) — small lift, mostly via people on antibiotic courses.
- **Ramadan** — significant behavior change in MENA. Medication routines shift around fasting hours. Listing copy in Arabic could highlight this *during Ramadan only*. Worth a tactical seasonal listing variant.
- **September** (back-to-school) — mild lift, kids' meds.

Plan releases and social pushes around these.
