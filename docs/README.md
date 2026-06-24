# MediNest — docs/ index

This is the navigation hub for the ASO + growth brain. The root `CLAUDE.md` is the cold-start pointer; **`v1-summary.md` is the single-file session-handoff brief** — read that one first if you're returning to the project.

## Session summaries (versioned)

- **[v1-summary.md](v1-summary.md)** — 2026-05-09. Brain bootstrapped + engineering handbook v1 + 8 features shipped, 1 partial, 3 blocked.

## Read in this order if you're new to the docs

1. `context/app-snapshot.md` — what the app actually does today
2. `context/monetization-snapshot.md` — what we're monetizing and where
3. `aso/03-competitor-analysis.md` — who we're up against
4. `aso/02-keyword-research.md` — which keywords we're going for and why
5. `aso/01-store-listing.md` — the recommended new listing
6. `aso/04-screenshot-strategy.md` — what screenshots to put on the store
7. `aso/05-aso-roadmap-90day.md` — the schedule for all of the above
8. `feature-improvements/feature-roadmap.md` — what to build next, ranked by ASO impact
9. `feature-improvements/ranking-tactics.md` — country-by-country ranking plan
10. `strategies/x/x-strategy.md`
11. `strategies/linkedin/linkedin-strategy.md`
12. `strategies/reddit/reddit-strategy.md`

## When you switch to building features

The marketing brain above tells you *what* to build and *why*. The engineering brain tells you *how* — versioned, tied to the codebase's real conventions:

- `engineering/v1/README.md` — entry point for any implementation session
- `engineering/v1/01-claude-flutter-engineer-role.md` — the role Claude takes when writing code
- `engineering/v1/02-architecture-canon.md` — actual conventions audited from the repo
- `engineering/v1/features/F01–F12.md` — per-feature specs in ship order

Implementation rule of thumb: pick **one** feature, read its spec end-to-end, implement, hand back a diff + manual test plan. Single-thread rule.

## Sprint board

`NEXT-STEPS.md` is the one place that tracks "Claude does X / You do Y." When something gets done, it moves out of NEXT-STEPS and into the relevant doc as a permanent record.

## File-format convention

Strategy docs ship as **both** `.md` and `.html`:

- `.md` = canonical source. Edit this.
- `.html` = the same content, styled for human reading. Regenerated from `.md`. Don't edit by hand.

Context docs (`context/*`, scoring frameworks, action lists) ship as `.md` only.

## Linking convention

Cross-doc links are relative paths from the doc you're in (e.g., from `aso/01-store-listing.md` → `../feature-improvements/feature-roadmap.md`). HTML mirrors use the same relative paths so the site works opened from disk.
