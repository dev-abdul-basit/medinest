# v1 — Overview

## What v1 is

A frozen contract between Abdul (product owner) and Claude (Flutter engineer) for shipping the next ~6 months of MediNest features. v1 is intentionally tight: it locks the conventions that already exist in the codebase so we don't burn engineering hours debating where a controller goes — and it spells out 12 features in enough detail that Claude can implement each one without re-asking architectural questions.

## What v1 explicitly does NOT cover

- **No architectural rewrites.** GetX stays. Sqflite stays. Mixed `*_logic.dart` / `*_controller.dart` naming stays (we don't refactor working code in v1).
- **No new state management.** No `Riverpod`, no `Bloc`, no `Provider`. Even if a feature would benefit, v1 keeps the existing pattern.
- **No new languages or frameworks.** Dart + Flutter only. No Kotlin/Swift native code unless the feature spec explicitly says so (Health Connect is one such case).
- **No new tests infrastructure.** v1 does not introduce `test/` setup or CI. We rely on **manual device QA** as the gate (see `04-definition-of-done.md`). We add tests in v2 only if v1 ships at least 8 features without a critical regression.

## Why this works

The codebase is solo-developer Flutter — moderate complexity, no test suite, manual release workflow. The biggest risk to velocity isn't bugs; it's **invented conventions**. Every time a contributor (human or LLM) creates a new pattern, the codebase fragments and future changes cost 2× more.

v1 fixes that risk by writing down what exists and refusing to deviate.

## How to use this folder

### Starting a new implementation session

Tell Claude:

> *"Read `docs/engineering/v1/01-claude-flutter-engineer-role.md`, then implement `docs/engineering/v1/features/F0X-...md`."*

Claude will:
1. Reload the role
2. Read the architecture canon to refresh conventions
3. Read the spec
4. Confirm scope with you
5. Implement
6. Hand back the diff + manual test plan

### When a spec is wrong or outdated

The codebase is the truth. If a spec references a file that no longer exists or a pattern that has changed, **fix the spec first** before implementing. Keeping specs accurate is part of the work.

### Adding a new feature to v1

Don't, unless it's truly scope-equivalent to something already in `features/`. Larger features go in `v2/` to avoid invalidating frozen specs. If you're not sure: ask before adding.

## Estimating

Each feature spec includes an **effort** field (`½ day`, `1 day`, `1 week`, `2 weeks`). These are *senior solo dev* estimates, assuming:

- Working from the spec, no design churn
- No test suite to write
- Single platform (Android Play Store)
- One round of QA on physical device

Multiply by 1.5–2× if you ship to iOS in the same cycle.

## Single-thread rule

**Implement one feature at a time.** Two features in flight = unattributable bugs and review-thread chaos. Even quick wins go through one at a time. Kill any pull-toward-parallelism.

## What "version code" means in this folder

Every feature, when shipped, names the **Android `versionCode`** it landed in (e.g., `versionCode 12`). This is the unambiguous reference for "which build did X go out in". Don't use `versionName` (1.0.9, 1.0.10) for this — `versionName` can lie; `versionCode` cannot.

Current `versionCode` at v1 freeze: **11** (`pubspec.yaml`: `version: 1.0.8+11`).
