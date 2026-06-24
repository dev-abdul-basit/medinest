# CLAUDE.md — MediNest ASO & Growth Brain

This file is the entry point for any future session. It is intentionally short. The detailed work lives in `docs/`.

> Treat this file as the index. Treat `docs/` as the brain.

---

## 1. What this project is

**MediNest – Pill Reminder** is a Flutter pill-reminder + health-journal app shipping on Android (Google Play). Package: `com.mednest.pill.reminder`. Current public version: **1.0.8 (build 11)**.

Stack: Flutter 3 · GetX · Firebase (Auth, Firestore, Storage, FCM, App Check) · Sqflite (offline-first) · `flutter_local_notifications` · `google_mobile_ads` · `in_app_purchase`.

**MVP scope (2026-05-10):** product pillars are **pill reminder + health journal + family medication support**. Doctor profiles and appointment reminders were removed from MVP and moved to the future roadmap. Code for the removed screens may still exist in `lib/ui/add_or_edit_doctor_screen/`, `lib/ui/doctors_screen/`, `lib/ui/appointment_history_screen/`, `lib/ui/full_screen_appointment_notification/`, but those features are not part of the MVP product story and must not appear in store / social copy.

**Major reshape (2026-05-30) — two binding constraints:**
1. **Play category = non-Health.** Google rejected the *Health* category because this is an **individual** developer account, not an organization account (Health/Medical categories effectively require org verification). MediNest ships in a non-health category — recommended **Productivity**. Search ranking for `pill reminder` / `medication reminder` is keyword-driven and is *not* lost; only browse/top-charts placement changes. Store copy must avoid medical/diagnostic *claims* ("treat", "diagnose", "manage your condition") — frame it as a reminder/organizer. **Consequence: Health Connect (F09) is killed, not deferred** — it depends on health-data declarations an individual account cannot make. (Long-term unlock: convert to an organization account — needs a registered business + D-U-N-S number — to reclaim Medical/Health & Fitness. Parked.)
2. **Primary audience = United States** (was Saudi/MENA). Drives: **USD-first pricing** (5 SAR ≈ $1.33 is far below the US norm of $4.99–9.99/mo), a perfected **en-US store listing before** the 50-locale push, and a **US competitor set** (Medisafe, MyTherapy, Round Health). See `docs/context/app-snapshot.md` + `docs/context/monetization-snapshot.md`.

Live monetization:
- **AdMob** — banner on Home + Family Member screens; interstitial gated on Home (frequency-capped via `Preference.getInterstitialAdCount`).
- **Subscription** — monthly + yearly plans (`InAppPurchaseHelper.buySubscription`). Was **5 SAR / month**; **being repriced to USD tiers for the US market** (see reshape note above + monetization snapshot).
- **Free tier hard cap** — 10 medicines before paywall in MVP copy (see `home_controller.dart`, `medicine_history_screen_logic.dart`). The legacy 10-appointments cap exists in `appointment_history_screen_logic.dart` but is no longer referenced in marketing.

Important to remember: the in-app UI **already supports ~50 locales** (`lib/localization/languages/`). The Play Store listing currently only ships in English. Post-reshape (2026-05-30) the 50-locale rollout is **deprioritized** behind a perfected **en-US** listing; non-English localized listings return once the US listing is converting.

---

## 2. The goal of this engagement

Grow MediNest organically:

1. **ASO on Google Play** — climb on a defined keyword set, not "all of them".
2. **Off-store growth** — X (Twitter), LinkedIn, Reddit. No paid ads in scope.
3. **Feature work that moves rankings** — only features that affect retention, reviews, or keyword surface area.

The user is the developer + operator. I (Claude) am the senior ASO collaborator. Output should be honest, testable, and grounded in real Play Store mechanics — not generic "AI listicle" advice.

---

## 3. Repository map (where to find what)

```
CLAUDE.md                        ← you are here. Index only.
docs/
├── README.md                    ← navigation hub. Start there in a new session.
├── NEXT-STEPS.md                ← current sprint. "Claude does X / You do Y" split.
├── context/
│   ├── app-snapshot.md          ← feature inventory, free-vs-premium gates, locale list
│   └── monetization-snapshot.md ← AdMob placements, IAP product IDs, paywall triggers
├── aso/
│   ├── store_listing_desc.txt   ← current LIVE listing (v0, do not edit, kept for diff)
│   ├── 01-store-listing.md/.html      ← recommended NEW listing (title/short/full)
│   ├── 02-keyword-research.md/.html   ← real keyword candidates + scoring framework
│   ├── 03-competitor-analysis.md/.html
│   ├── 04-screenshot-strategy.md/.html
│   └── 05-aso-roadmap-90day.md/.html
├── strategies/
│   ├── x/
│   │   ├── x-strategy.md/.html
│   │   └── x-content-30day.md
│   ├── linkedin/
│   │   ├── linkedin-strategy.md/.html
│   │   └── linkedin-content-30day.md
│   └── reddit/
│       ├── reddit-strategy.md/.html
│       └── reddit-subreddits.md
├── feature-improvements/
│   ├── feature-roadmap.md/.html       ← features ranked by ASO impact
│   └── ranking-tactics.md/.html       ← where + how to rank, country-by-country
├── engineering/                 ← versioned implementation handbook
│   ├── README.md/.html              ← version index
│   └── v1/                          ← active version
│       ├── README.md/.html              ← v1 entry point
│       ├── 00-overview.md/.html
│       ├── 01-claude-flutter-engineer-role.md/.html ← agent role for impl sessions
│       ├── 02-architecture-canon.md/.html
│       ├── 03-feature-template.md/.html
│       ├── 04-definition-of-done.md/.html
│       └── features/                    ← per-feature specs F01–F12 + T2/T3 placeholders
└── MediNest/                    ← graphics (existing, not generated)
    ├── Medinest Playstore grahics/
    └── sp_icon.png
```

**Why two formats?** `.md` is what I read when working with you (cheap context). `.html` is what *you* read when reviewing — formatted, scannable, printable.

---

## 4. Working agreement

- **No AI fluff.** No "In today's fast-paced digital world…". Every claim names a mechanism (a Play Store algorithm signal, a known competitor pattern, a measurable metric) or it gets deleted.
- **Honest about limits.** I cannot pull live keyword search-volume numbers. What I can do: give the candidate set, explain why each candidate matters, and tell you exactly which free/paid tool to validate it in. That's how a real ASO consultant works — they have a framework + tools, not memorized volumes.
- **Counter-check before recommending.** If a recommendation would change the live store listing, it lands in `docs/aso/` first, gets reviewed, then you copy it into Play Console manually.
- **Separate Claude steps from your steps.** Every action plan ends with two columns: what I (Claude) do next session, what you do in Play Console / on social.
- **One source of truth per topic.** No duplicating the keyword list across files. Other docs link to `02-keyword-research.md`.

---

## 5. State as of 2026-05-09

| Area | Status |
| --- | --- |
| Live store listing | English only · v0 in `docs/aso/store_listing_desc.txt` |
| Recommended new listing | Drafted in `docs/aso/01-store-listing.md` — **awaiting your review** before any Play Console change |
| Keyword research | Candidate list + scoring framework written. Volumes not yet validated. **You** to pull volumes from Google Play Console "Search terms" report + a free tool (recommended: AppFollow free tier or Google Keyword Planner as a proxy). |
| Localized listings | 0 of 50 locales the app already supports. Highest-leverage gap. |
| Reviews | Not yet audited. Need current count + rating. **You** to paste from Play Console. |
| Social presence | None confirmed. Strategies in `docs/strategies/*` assume cold start. |

---

## 6. How to resume in a new session

**Single-file cold start:** read **`docs/v2-summary.md`** first (latest engineering brief — self-profile unification, add-medicine + home redesign, emerald theme, guest/login data safety + account isolation), then `docs/v1-summary.md` for the earlier ASO/growth + feature work. The newest summary always supersedes for engineering state.

If you (the user) open a fresh chat, the prompt is:

```
Read docs/v1-summary.md.
I want to: (a) commit + QA the 8 shipped features
        OR (b) answer blocker decisions for F07/F09/F10/F11
        OR (c) keep doing ASO work
        OR (d) [describe]
```

If I (Claude) am picking up cold and no prompt is given, my first move is `Read docs/v1-summary.md` — it points me at everything else.

For pure ASO/marketing work, then read `docs/NEXT-STEPS.md` for the active sprint.

For implementation work, then read `docs/engineering/v1/01-claude-flutter-engineer-role.md` and `docs/engineering/v1/02-architecture-canon.md` before touching `lib/`.

---

## 7. What this file is *not*

Not a feature spec. Not a marketing pitch. Not a copy of the docs.

When something detailed needs to be said, it goes in `docs/`. This file just points at it.
