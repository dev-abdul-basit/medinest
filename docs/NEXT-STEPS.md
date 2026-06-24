# NEXT-STEPS — Current Sprint

Updated: 2026-05-09 · Sprint window: **2026-05-09 → 2026-05-23 (2 weeks)**

This is the only place in the brain that tracks who-does-what. Once a step is done, the result it produces gets recorded in the relevant permanent doc and the line is removed from this file.

> Rule: nothing on the live store listing changes until a draft has been reviewed in `docs/aso/` and you have explicitly approved it.

---

## Your side (in Play Console / browser / social) — pull in this order

These unblock my next round of work. Do them in order; don't batch-skip.

### 1. Pull current Play Console data — *blocking everything else*
Inside Play Console → Statistics → "Acquisition" → "Search terms":
- [ ] Export the last 90 days of Search Terms report → save as `docs/aso/_data/search-terms-90d.csv`
- [ ] Export Acquisition by country (last 90 days) → `docs/aso/_data/acquisition-by-country-90d.csv`
- [ ] Note current install count, rating, and review count → paste into `context/app-snapshot.md` under the "Live store metrics" section

Why: I'm flying blind on real demand without these. Search Terms tells us which queries already convert for us. Acquisition by country tells us which localized listings to ship first.

### 2. Pull a baseline competitor screenshot set
- [ ] On a Play Store browser tab (NOT logged into your dev account), search for `pill reminder` from a clean / incognito window. Take a full-page screenshot of the SERP. Save to `docs/aso/_data/serp-pillreminder-en.png`.
- [ ] Repeat for `medication reminder`, `medicine reminder`, `tablet reminder`. Same filename pattern.
- [ ] If you target Saudi/MENA, repeat from a Saudi VPN / Arabic locale browser. Filename suffix `-ar`.

Why: ranking is per-keyword and per-country. Screenshots let me see exactly who is in slots 1–10 for our targets without guessing.

### 3. ~~Decide target country~~ — DECIDED 2026-05-30: **United States**
- [x] Primary target country = **United States** (was Saudi/MENA). All ASO drafts are now US-English-first; the 50-locale rollout is deprioritized behind a perfected en-US listing. See the reshape note in `context/app-snapshot.md`.
- [ ] Set USD subscription price tiers in Play Console (replaces 5 SAR): **$3.99/mo + $19.99/yr** (decided 2026-05-30) — see `context/monetization-snapshot.md`.
- [ ] **Category = Productivity** (decided 2026-05-30) — set on next submission (Health was rejected on the individual account).

### 4. Set up free ASO tooling (one-time, ~15 min)
- [ ] Sign up for **AppFollow** free tier (or **AppTweak** trial) — link MediNest's package `com.mednest.pill.reminder`.
- [ ] Sign up for **Google Search Console** if you also have a website. (Optional but useful — Play algorithm correlates with web search interest.)

### 5. Light social setup (do not post yet)
- [ ] Reserve handles on X, LinkedIn (page), Reddit if not already taken. Suggested: `@medinestapp` / `MediNest` / `u/medinest_app`. Do not start posting until `strategies/*` are reviewed.

---

## My side (Claude tasks) — what I'll do next session

Each of these is blocked by something on your side. The blocker is named.

### A. Validate keyword candidates with real volume data
**Blocked by:** Your-side step 1 (Search Terms CSV) and step 4 (AppFollow set up).
**Output:** Update `aso/02-keyword-research.md` — replace the "estimated demand" column with actual numbers, re-rank the priority list, drop low-volume candidates.

### B. Write the localized store-listing drafts for the top 3 markets
**Blocked by:** Your-side step 1 (acquisition-by-country.csv) and step 3 (target-country decision).
**Output:** `aso/01-store-listing.md` gets new sections for `ar-SA`, `hi-IN`, `id-ID` (or whatever the data points to). Each translated by a native-fluent human, not me — I'll deliver English source + a translation brief.

### C. Map current screenshots against the conversion playbook
**Blocked by:** Your-side step 2 (competitor SERP screenshots).
**Output:** Update `aso/04-screenshot-strategy.md` with a side-by-side: what slot 1–3 competitors lead with vs. what your current 8 screenshots lead with. Then a redesign brief you hand to a designer.

### D. Draft week 1 of social content
**Blocked by:** None — can start as soon as you green-light the strategy docs.
**Output:** Real posts (not templates) in:
- `strategies/x/x-content-30day.md` (post text + day + time + asset note)
- `strategies/linkedin/linkedin-content-30day.md`
- `strategies/reddit/reddit-subreddits.md` annotated with which threads to engage in *first* (no posting our own URL until karma + relevance built — see strategy doc).

### E. First-pass review & rating audit
**Blocked by:** Your-side step 1 (current rating + review count).
**Output:** Update `aso/05-aso-roadmap-90day.md` Week 1 with realistic review-acquisition targets. Without a current baseline, the targets are guesses.

---

## Done in this sprint (move out when complete)

- 2026-05-09 — Initial doc structure scaffolded: `CLAUDE.md`, `docs/README.md`, `docs/NEXT-STEPS.md`, `docs/context/*`, `docs/aso/*`, `docs/strategies/{x,linkedin,reddit}/*`, `docs/feature-improvements/*`. Drafts are first-pass — not yet validated against real volume data.

---

## Parking lot (good ideas, not this sprint)

- Apple App Store listing — `pubspec.yaml` ships iOS targets but Play Store is the active channel. Revisit after Android is climbing.
- Web landing page — only worth the time after social brings ≥2k unique visitors / month, since Play algorithm only weakly weighs web signals for non-branded queries.
- Influencer outreach (TikTok/IG caregivers, "polypharmacy" creators) — strong fit but expensive in time. Sprint 3+.
