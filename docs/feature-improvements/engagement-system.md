# Engagement & Retention System

How MediNest keeps a user past install — designed against what the codebase already has, not a generic retention listicle. The honest headline: **the whole phase-1 system ships with zero backend.** `zonedSchedule()` fires even when the app is killed, and every app-open can cancel/reschedule. FCM is a phase-2 luxury, not a prerequisite.

This doc is the **overview + roadmap**. Each notification family below becomes (or maps to) a per-feature spec under `../engineering/v1/features/` (F15+). It does not duplicate the streak math — that lives in `F08-adherence-streak.md` and `lib/services/adherence_service.dart`.

| | |
| --- | --- |
| North-star metric | **D7 retention** + **notification opt-in rate** (not DAU) |
| Backend required | No (phase 1) · FCM optional (phase 2) |
| Category constraint | Productivity · US market · no medical/diagnostic claims (per `../context/app-snapshot.md`) |
| Status | spec — awaiting review before any `lib/` change |

---

## 1. The retention model we're designing against

Retention here isn't one problem, it's four failure points along a lifecycle. Every notification in §4 maps to exactly one.

| Stage | When | Failure mode | The lever |
| --- | --- | --- | --- |
| **Activation** | Day 0–1 | Didn't finish setup / denied notification permission → app never delivers value | Permission rescue + finish-setup nudge |
| **Habituation** | Day 2–14 | Reminders feel naggy or mistimed → user disables notifications (silent churn — worse than uninstall, undetectable) | Reminder quality + adherence nudges + quiet hours |
| **Stickiness** | Week 2–4 | Course ended OR habit formed → "I don't need the app" | Streaks, milestones, journal hook |
| **Resurrection** | Day 7+ idle | Stopped opening | Local win-back notification |

The core tension: **medicine reminders are already frequent.** Stacking engagement notifications on top is how you get fatigue → user disables notifications → the retention backbone dies. So the first thing we build is a guardrail, not a feature.

---

## 2. The guardrail: an engagement notification budget (build this first)

The most important and most-skipped piece. Every **non-medicine** notification must pass through one gatekeeper before it fires.

**Rules — all local, all enforced in one `EngagementService`:**

- **Quiet hours** — default 21:00–08:00. No engagement notifications fire. Medicine reminders are exempt (user-set times).
- **Cap** — max **1** engagement notification/day, max **3**/week.
- **Spacing** — never fire within **90 min** of a scheduled medicine reminder. Every reminder's `nNotificationTimeStamp` is already in `lib/database/tables/notification_table.dart` — query it.
- **Priority** — if two are eligible the same day, fire the higher-priority one and drop the other: `resurrection > milestone > journal > adherence-tip`.

Powered by two new `Preference` keys: `lastEngagementNotifTs` and a rolling weekly counter. Without this, every feature below backfires.

---

## 3. Channels available today

| Channel | State | Use for |
| --- | --- | --- |
| Local scheduled notifications | ✅ Built — `lib/notification/notification_helper.dart`, `zonedSchedule()` with taken/skip/snooze actions | Everything in phase 1 |
| In-app cards / prompts | ✅ Built — `lib/Widgets/adherence_card.dart` on Home | Permission rescue, milestone celebration, finish-setup |
| In-app review | ✅ Built + well-gated — `lib/services/review_prompt_service.dart` | Leave as-is; do not touch its gates |
| FCM push | ⚠️ Token collected in `lib/ui/get_started_screen/` — no backend, no handler, no topics | Phase 2 only |

---

## 4. The notification catalogue

Grouped by lifecycle stage. Copy is US-market, Productivity-safe (no "treat / diagnose / manage your condition" — all framed as reminders/organizing, per reshape constraints). Every row is gated by §2 unless it's a medicine reminder.

### A. Activation (Day 0–1)

| ID | Trigger | Timing | Powered by | Copy |
| --- | --- | --- | --- | --- |
| **A1 · Permission rescue** | OS notification permission denied | Next app open, in-app card (not a notification) | `home_controller.dart` `_requestPermissions()` result | *"Reminders are off — MediNest can't remind you without notifications."* → deep-link to OS settings |
| **A2 · Finish setup** | Onboarding done, 0 medicines added | T+3h local notif; cancel on first medicine add | `Preference.firstMedicineCreated` | *"Add your first medicine to start getting reminders 💊"* → opens `lib/ui/first_medicine/` |

A1 is the highest-leverage fix in the whole doc: a denied permission silently kills every other notification here.

### B. Habituation (Day 2–14)

| ID | Trigger | Timing | Powered by | Copy |
| --- | --- | --- | --- | --- |
| **B1 · Adherence tip** | Today partial AND an untaken dose remains | ~19:30 (pre-quiet-hours) | `AdherenceService` today's % | *"You took 2 of 3 today. One left to stay on track."* |
| **B2 · Journal prompt** | No journal entry in 7 days | Weekly, gentle | `JournalTable` + new `Preference.lastJournalTs` | *"How have you been feeling this week? Add a quick note."* |

B2 re-enables the journal reminder code currently **commented out** in `notification_helper.dart`. Journaling is the emotional hook that survives "my course ended" — the reason MyTherapy retains.

### C. Stickiness (Week 2–4)

| ID | Trigger | Timing | Powered by | Copy |
| --- | --- | --- | --- | --- |
| **C1 · Streak milestone** | Hit 3 / 7 / 14 / 30 / 100-day streak | On compute, same day | `AdherenceService.currentStreak` | *"🔥 7-day streak! You've stayed on track a full week."* |
| **C2 · Streak-at-risk** | `streak >= 3` AND untaken dose by evening | ~19:45 | `AdherenceService` | *"Don't break your 6-day streak — 1 dose left today."* |

C1 is celebration, not a nag — your highest-leverage stickiness tool; pair with an in-app moment on `adherence_card.dart`. C2 uses loss-aversion (outperforms gain framing) but must be rare — gate hard.

### D. Resurrection (Day 7+ idle) — the offline win-back

| ID | Trigger | Timing | Powered by | Copy |
| --- | --- | --- | --- | --- |
| **D1 · We miss you** | App not opened | Reschedule to now+5d on every open; fires only if user goes dark | new `Preference.lastOpenTs` + cancel/reschedule on resume | *"Your reminders are waiting. Pick up where you left off."* |
| **D2 · Soft restart** | Still idle | now+14d, then stop | same | *"Start a fresh streak today — it only takes a tap."* |

The mechanism: on every app open, cancel D1 and reschedule for now+5 days. Active users never see it; dark users do. **No backend.** Stop after D2 — chasing a 30-day-gone user earns an uninstall.

---

## 5. What actually needs FCM (phase 2, defer)

Everything above is local. FCM only buys what local can't:

- **Remote-controlled / A-B-tested copy** without an app update.
- **Broadcast campaigns** (feature announcements, seasonal).
- **Dynamic content** ("3 people in your family circle have reminders today").

Needs a Cloud Function + a campaign table. Worth it only *after* the local system proves it moves D7. Token is already collected — nothing blocks starting later.

---

## 6. Instrumentation (you can't tune what you don't measure)

Add a small local events surface (reuse `Preference` counters where possible) so next iteration tunes cadence against data, not guesses:

- `lastOpenTs`, `openCount`, weekly session count → D1/D7/D30 retention.
- Notification permission state (granted/denied) → activation ceiling.
- Per-notification-type scheduled-vs-tapped → kill any type with a low tap rate.
- Adherence-% and streak-length distributions (already derivable from `AdherenceService`).

---

## 7. Build order (by ROI, lowest effort first)

1. **Engagement budget + quiet hours** (§2) — the guardrail. Must come first.
2. **A1 permission rescue + D1 win-back** — highest retention ROI, ~1 day combined.
3. **C1 milestones + C2 at-risk** — reuses existing streak math.
4. **B1 adherence tip** — reuses `AdherenceService`.
5. **B2 journal prompt** — uncomment + gate.
6. **Instrumentation** (§6) — so we can iterate.
7. **FCM campaigns** (§5) — phase 2, only after 1–6 prove out.

Each numbered item becomes a feature spec (F15 = engagement budget, F16 = permission-rescue + win-back, …) under `../engineering/v1/features/`, written just-in-time before its implementation.

---

## 8. Out of scope

- Gamification beyond calm streaks — no points, badges, leaderboards (same stance as F08).
- Social sharing of streaks — privacy concern, irrelevant to install funnel.
- Aggressive "you broke your streak!" guilt notifications — hurts review sentiment in a Productivity listing.
- Server-driven anything in phase 1.

---

## 9. Decisions (locked 2026-06-16)

Operator delegated these calls; rationale recorded so we can revisit with data.

1. **Quiet hours: 21:00–08:00**, single global window. Not per-user in v1 — a settings toggle is scope creep before evidence anyone wants it.
2. **Cap: 1/day, 3/week.** Conservative on purpose — easier to loosen later than to win back a muted user.
3. **Journal re-engagement (B2): parked for v1.** Half-built feature; re-enabling is real work and would stall the guardrail. Guardrail + win-back + streak nudges deliver most of the lift without it.
4. **Milestone ladder: 3 / 7 / 14 / 30 / 100 days** — matches F08's existing streak math, no new computation.

These are encoded as constants (not magic numbers) so a future data-driven change is a one-line edit.

---

## 10. The split

**Claude does:**
- ✅ `F15-engagement-budget.md` — the §2 guardrail spec + `EngagementService` foundation (shipped, unwired, analyzer-clean).
- ✅ `F16-winback-notifications.md` — D1/D2 offline win-back (shipped: `scheduleWinBackNotifications()` on the reschedule path + tap guards + 4 locale keys × 52 files).
- ✅ `F17-permission-rescue.md` — A1 (shipped: rewrote the broken placeholder denial dialog into a real explain + `openAppSettings()` deep-link; 4 locale keys × 52 files).
- ✅ `F18-streak-milestone-celebration.md` — C1 (shipped: `EngagementScheduler` — first real consumer of `canFire`/`recordFired`; gated by quiet hours + caps).
- ✅ `F19-evening-nudges.md` — B1 + C2 (shipped: scheduled evening tip / streak-at-risk; first scheduled consumer of the budget; shares the 1/day cap with milestones).
- ✅ `F20-instrumentation.md` — §6 (shipped: local `openCount` + engagement-tap counters via `InstrumentationService`; Firebase Analytics forwarding deferred pending package approval).
- ✅ `F21-fcm-client-wiring.md` — §5 client half (shipped: background handler, token refresh, topic subscribe, foreground display — **inert until a backend sends a push**).
- On request, draft the full local-notification copy set (all IDs × A/B variants) ready to drop into locale files.

**The whole local engagement system (build-order #1–6) is now wired.** What remains is genuinely external:
- **FCM backend sender** — a Cloud Function / campaign table to actually send pushes. Needs operator decisions (what backend, first campaign). Only pays off after the local system proves it moves D7.
- **Firebase Analytics** — approve the package to get real D1/D7/D30 funnels instead of local counters.

**You do:**
- Review F15–F21 (all ship safely — local-only, additive; FCM client is inert without a sender).
- Decide if/when to build the FCM backend sender + approve `firebase_analytics`.
