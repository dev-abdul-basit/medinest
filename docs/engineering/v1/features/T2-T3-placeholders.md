# Tier 2 / Tier 3 — Scope Placeholders

These features from `../../../feature-improvements/feature-roadmap.md` are *not* fully spec'd in v1. They will get full specs (in the same template as F01–F12) when they're scheduled, after F01–F12 are mostly done. Listing them here so v1 has forward visibility without committing to designs that will rot before they ship.

> Rule: **don't implement from this file.** Each item below must get its own full spec under `features/F1X-...md` before any code is written.

---

## Tier 2 (months 3–5)

### F13 · Smart Refill Reminder
**Roadmap:** T2-1 · **Effort:** 1 week · **Schema:** YES (new `medicine_table` columns: `pillsRemaining`, `refillThresholdDays`).
**Purpose:** Track pill count, fire a refill notification ~3 days before running out. Claims `prescription refill reminder` keyword.
**Open question:** how does the user input the "starting count"? Wizard at create-time vs. estimate from frequency.

### F14 · Wear OS Companion
**Roadmap:** T2-2 · **Effort:** 2–3 weeks · **Schema:** no.
**Purpose:** Wear OS app showing next dose, tap-to-mark-taken from the wrist. Apple Watch deferred.
**Risk:** Wear OS support in Flutter is non-trivial — likely a separate native module.

### F15 · Multi-Time-Per-Day in One Entry
**Roadmap:** T2-3 · **Effort:** 1 week · **Schema:** likely YES (new linkage in `notification_table`).
**Purpose:** Today, multi-dose meds need separate entries. Audit if true and consolidate.
**Open question:** does the table model already support multiple notification rows per medicine? Confirm before specifying.

### F16 · Backup / Restore (clean export-import flow)
**Roadmap:** T2-4 · **Effort:** 1 week · **Schema:** no.
**Purpose:** Surface the existing Firestore sync as an explicit export/import in Settings, with last-backed-up timestamp visible.
**Premium consideration:** keep free — this is a trust feature, not a revenue feature.

### F17 · Home-Screen Widget
**Roadmap:** T2-5 · **Effort:** 1–2 weeks · **Schema:** no.
**Purpose:** Android widget showing next dose. Modest CVR claim, real D7 retention bump.
**Risk:** Flutter home-screen widget support requires `home_widget` package + native channel work.

---

## Tier 3 (months 5–8+)

### F18 · Real Family Sync (caregiver-patient)
**Roadmap:** T3-1 · **Effort:** 3–4 weeks · **Schema:** YES (multi-tenant model).
**Purpose:** Real-time link between a caregiver's phone and the patient's phone. Caregiver gets a ping when the patient doesn't acknowledge a dose. Premium-only.
**Risk:** privacy + permission model is significant. Needs proper threat-model review before spec'ing.

### F19 · Pharmacy / Prescription Import
**Roadmap:** T3-2 · **Effort:** 6–8 weeks (partnerships involved) · **Schema:** YES.
**Purpose:** Import meds from Walgreens / CVS / regional equivalents. Out of v1 scope.

### F20 · iOS Launch
**Roadmap:** T3-3 · **Effort:** Highly variable depending on iOS-specific bugs from current codebase.
**Decision rule:** don't ship iOS until Android hits the Day-90 targets in `../../aso/05-aso-roadmap-90day.md`.

---

## When something here graduates to a real spec

1. Pull the row out of this file.
2. Create `features/F1X-<slug>.md` using `../03-feature-template.md`.
3. Update `../README.md` table — move from "placeholder" to "spec done".
4. Re-render HTML.

## Why we're not spec'ing them now

Two reasons:

1. **Spec rot.** Specs written 6 months in advance get stale. By the time we ship F18, the codebase, AdMob policies, and Health Connect SDK will have all moved.
2. **Real signal first.** F01–F12 will produce real install / retention / revenue signal. That signal will reorder the priority of T2/T3 features more accurately than today's gut.

So: focus on shipping v1's first 12. Re-rank the rest in 6 months.
