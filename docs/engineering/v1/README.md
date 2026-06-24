# Engineering Handbook · v1

Frozen 2026-05-09. Active.

## Read in this order

1. **[00-overview.md](00-overview.md)** — what v1 covers, what it doesn't, how to use this folder
2. **[01-claude-flutter-engineer-role.md](01-claude-flutter-engineer-role.md)** — the role you (Claude) take when implementing. Read this first when starting an implementation session.
3. **[02-architecture-canon.md](02-architecture-canon.md)** — the actual conventions in this repo, audited from real code. Implementation must match these patterns; do not invent new ones in v1.
4. **[03-feature-template.md](03-feature-template.md)** — the structure every feature spec follows.
5. **[04-definition-of-done.md](04-definition-of-done.md)** — universal DoD checklist for any feature in v1.
6. **[release-cadence.md](release-cadence.md)** — when and how often we ship (F06).
7. **[release-checklist.md](release-checklist.md)** — pre-release sanity check (F06).
8. **[features/](features/)** — per-feature specs, ordered by ship priority.

## Feature specs in v1

In ship order — each one cross-references the corresponding entry in `../../feature-improvements/feature-roadmap.md`.

### Quick wins (sprint 1–2, ½–1 day each)

| ID | Feature | Roadmap ref | Status |
| --- | --- | --- | --- |
| F01 | Paywall copy rewrite | QW-1 | spec done |
| F02 | Review-prompt timing fix | QW-2 | spec done |
| F03 | Reminder action microcopy | QW-3 | spec done |
| F04 | ASO strings on key UI screens | QW-4 | spec done |
| F05 | Privacy policy link verification | QW-5 | spec done |
| F06 | Update-cadence policy | QW-6 | spec done |

### Tier 1 (sprint 2–10, 1–2 weeks each)

| ID | Feature | Roadmap ref | Status |
| --- | --- | --- | --- |
| F07 | Onboarding rewrite (first-reminder-set) | T1-1 | spec done |
| F08 | Adherence streak on home | T1-2 | spec done |
| F09 | Health Connect integration | T1-3 | spec done |
| F10 | "Notes for doctor" PDF export | T1-4 | spec done |
| F11 | Caregiver mode toggle | T1-5 | spec done |
| F12 | Per-region IAP pricing | T1-6 | spec done |

### Tier 2 / Tier 3 — placeholders

Spec deferred until earlier work is done. See **[features/T2-T3-placeholders.md](features/T2-T3-placeholders.md)** for scope-only descriptions.

## Roles

- **Abdul (you)** — product owner, designer, release manager. Reviews specs, approves before code lands, runs Play Console / app builds / device testing.
- **Claude (me)** — Flutter engineer per `01-claude-flutter-engineer-role.md`. Reads the spec, implements, hands back a diff and a manual test plan.

## Working agreement for implementation sessions

1. Pick **one** feature from the `features/` list.
2. Open the spec file. Read the entire spec before touching code.
3. Confirm with Abdul if anything in the spec is ambiguous or contradicts what's now in the codebase (the code is the truth; if the spec is outdated, fix the spec first).
4. Implement following the architecture canon. No new patterns in v1.
5. Walk Abdul through the diff and manual test plan.
6. Abdul builds + tests on device. Bugs found → back to step 4.
7. Spec gets a `### Implemented` block appended at the bottom (date, commit SHA, version code shipped). Move feature row to "shipped" in this README.
