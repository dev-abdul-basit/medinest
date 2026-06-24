# 90-Day ASO Roadmap

Calendar starts 2026-05-09. Each week has **your tasks** and **my tasks** (Claude). Don't run the next week until current week's blockers clear — out-of-order work creates noise that hides what actually moved the needle.

> Single-variable rule. Each week ships ≤1 listing-changing experiment so we can attribute install / rank movement to a cause. Multiple changes in one week = no signal.

---

## Week 1 (2026-05-09 → 05-15) — Baseline

### Your side
- Pull Play Console Search Terms (90d) → `aso/_data/search-terms-90d.csv`
- Pull Acquisition by country (90d) → `aso/_data/acquisition-by-country-90d.csv`
- Note install/rating/review numbers in `context/app-snapshot.md`
- Take SERP screenshots for `pill reminder`, `medication reminder`, `medicine reminder`, `tablet reminder` from clean / incognito browser. Repeat for one MENA-locale browser.
- Sign up for AppFollow free tier
- Confirm primary target country (Saudi vs worldwide-EN)

### My side
- Validate keyword candidates with the data you pulled, update `02-keyword-research.md` priority list
- Map current screenshots vs. competitor SERP — update `04-screenshot-strategy.md` with the gap analysis

### Exit criteria
We have: real volumes, real ranks for ~20 keywords, real SERP screenshots. No listing changes ship this week.

---

## Week 2 (2026-05-16 → 05-22) — Title experiment

### Your side
- In Play Console → Store Listing Experiments → create test:
  - **Variant A:** v1 title `Medinest: Pill & Med Reminder`
  - **Control:** current title
  - Audience: 50 / 50, all countries
- Reply to every review from the past 30 days that you haven't replied to. Even "thanks!" replies. Play algorithm reads developer-reply-rate as an engagement signal.

### My side
- Draft localized titles for ar-SA, id-ID, hi-IN — sized for Play 30-char limit per locale
- Find a translator (or hand off the brief) — translation work happens Week 3

### Exit criteria
Title experiment running. Review reply rate ≥80 % on last 30 days.

---

## Week 3 (2026-05-23 → 05-29) — Short description + first localization

### Your side
- If title test has ≥95 % confidence, ship the winner. Otherwise let it run another week.
- Start a **separate** experiment: short description v1 vs control.
- Send English source + translation brief to a native fluent translator for ar-SA. Budget $25–50.

### My side
- Audit `home_controller.dart` paywall copy — write a v2 paywall copy, hand to you to ship in next app update. (Doesn't change ASO directly but feeds review sentiment, which does.)
- Build review-prompt timing recommendation — see `feature-improvements/feature-roadmap.md` Quick Wins.

### Exit criteria
Short-description test running. Arabic translation in flight.

---

## Week 4 (2026-05-30 → 06-05) — First localized listing live

### Your side
- Receive ar-SA translation. **Have one other Arabic speaker spot-check it for naturalness.** Translation quality is the #1 reason localized listings underperform.
- In Play Console → Store presence → Translations → add Arabic (Saudi Arabia). Paste title, short, full.
- Upload Arabic screenshots (or skip first round if budget-constrained — English screenshots in an Arabic listing still convert better than no Arabic listing).
- Build app: bump versionCode, ship a release. Even a no-feature update keeps freshness signal alive.

### My side
- Draft id-ID and hi-IN listing copy in English source form, ready to hand to translators in Week 5
- Begin `strategies/x/x-content-30day.md` Week 1 posts (pre-launch teasers)

### Exit criteria
Arabic listing live. Release shipped.

---

## Week 5 (2026-06-06 → 06-12) — Screenshot redesign starts

### Your side
- Hire / brief a designer with `04-screenshot-strategy.md`. Budget $150–400 for the full 8-screenshot set if outsourcing. If DIYing in Figma, expect 6–10 hours.
- Send id-ID + hi-IN copy to translators.
- Begin organic X posting (per `strategies/x/`).

### My side
- Review designer drafts when they arrive (paste image into chat, I'll critique against the strategy doc).
- Begin `strategies/reddit/reddit-subreddits.md` engagement plan — week-by-week subreddit list.

### Exit criteria
Screenshot redesign in progress. Two more localized listings in flight. X presence started.

---

## Week 6 (2026-06-13 → 06-19) — Screenshots ship + Reddit engagement begins

### Your side
- Ship redesigned screenshots as **a Store Listing Experiment** (50/50 vs current screenshots), not direct.
- id-ID listing live (translator should have delivered).
- Begin Reddit engagement — comment-only, no link-drops, in the subreddits flagged in `strategies/reddit/reddit-subreddits.md`.

### My side
- Update `aso/03-competitor-analysis.md` with month-over-month rank deltas observed (you screenshot the SERPs again, I diff).
- Draft LinkedIn posts → `strategies/linkedin/linkedin-content-30day.md` Week 1.

### Exit criteria
Screenshot test running. Two locales live (ar-SA, id-ID). Reddit account warmed.

---

## Week 7 (2026-06-20 → 06-26) — Hindi listing + first social-driven installs

### Your side
- hi-IN listing live.
- Post LinkedIn week 1 content per `strategies/linkedin/`.
- Continue Reddit comments.
- App update: bump versionCode, include any small feature win (e.g., new sound, theme tweak — keeps store-freshness signal).

### My side
- Pull early read on screenshot test — if clear winner (≥95 % CI, ≥10k installs per arm), declare. If not, recommend extending or simplifying variant set.
- Audit reviews from Week 1–6 for keyword opportunities (real users using new terms = real keyword signals to chase).

### Exit criteria
Three localized listings live. App update shipped. Social presence active on X + LinkedIn + Reddit.

---

## Week 8 (2026-06-27 → 07-03) — Iterate

### Your side
- Whatever the screenshot test winner is, ship it everywhere. Then start a new test on a different variable.
- Add ur-PK and tr-TR localized listings (translators briefed last week).
- Reach out to 3 caregiver / chronic-illness creators on X / LinkedIn (list to be in `strategies/x/x-content-30day.md`).

### My side
- Mid-roadmap audit. Update `aso/05-aso-roadmap-90day.md` (this file) — what worked, what didn't, what plan changes.
- Pull current rank for the top 20 keywords vs. baseline. If we have not moved on at least 5, we need to debug.

### Exit criteria
Five localized listings live. First creator outreach sent. Mid-roadmap retro committed.

---

## Weeks 9–12 (2026-07-04 → 07-31) — Compounding

By week 9, every week is the same shape:

- 1 listing experiment running (rotate: title → short → screenshot 1 → screenshot 2 → icon)
- 1 app update / month minimum (bump versionCode even if cosmetic)
- 2 new localized listings every 2 weeks
- 3 social posts per week (X), 1 per week (LinkedIn), 5 Reddit comments per week
- 1 review reply session per week (target ≥90 % reply rate on last 30 days)

I will keep updating this file with the weekly target as we have data.

---

## What success looks like at Day 90

Honest targets, calibrated to what new entrants in this category actually achieve:

| Metric | Day 0 | Day 90 target | Stretch |
| --- | --- | --- | --- |
| Localized listings | 1 (en) | 6 | 10 |
| Tracked keywords ranking top 50 | TBD | +10 | +20 |
| Tracked keywords ranking top 10 | TBD | 3 | 6 |
| Daily organic installs | TBD | +50 % | +150 % |
| Star rating | TBD | hold or +0.1 | +0.2 |
| Review count | TBD | +30 % | +60 % |
| X followers | 0 | 200 | 600 |
| LinkedIn page followers | 0 | 100 | 300 |
| Reddit karma in target subs | 0 | 200 | 500 |

Rank movement is non-linear. Expect nothing in weeks 1–4 (Play algorithm has a baseline period for new listings/changes), small wins weeks 5–8, compounding in weeks 9–12.

---

## What we will *stop doing* if it isn't working

Be ready to kill these:

- Any keyword we are still ≥ rank 100 on at Day 60 (we drop it from the long description).
- Any localized listing with <100 installs at Day 60 (we pause work on more locales until we understand why; don't compound the loss).
- Any social channel below the Day 90 stretch target by Day 60 — we cut to weekly cadence, not 3×/week, and let it ride. Don't burn time chasing a channel that isn't pulling.
