# F06 · Update-Cadence Policy

| | |
| --- | --- |
| Roadmap ref | QW-6 |
| Effort | ¼ day (process, not code) |
| Risk | low |
| Schema change | no |
| New package | no |
| Premium-gated | no |
| ASO signals moved | Algorithm freshness |
| Status | spec |

## 1. Why we're shipping it

Google Play algorithm down-weights apps that look abandoned. Versioning monthly (even if cosmetic) signals an active app. Solo devs commonly ship in bursts then go quiet for 3 months — that pattern is the silent killer of organic install velocity.

This isn't a feature. It's a **policy** that ships as documentation + a small commit hook.

## 2. What changes for the user

Nothing directly. But over months, the user sees occasional "What's new" notes in Play Store that signal the app is alive.

## 3. What changes in the code

- **NEW: `docs/engineering/v1/release-cadence.md`** *(new file — see template at end of this spec)* — the policy itself, kept in the engineering folder so it's versioned with the rest of v1.
- **`pubspec.yaml`** — bump `versionCode` discipline: never ship a `versionName` change without a `versionCode` increment. (Already standard, but write it down.)
- **NEW: `docs/engineering/v1/release-checklist.md`** *(new file)* — pre-release checklist that includes localized "What's new" string updates.

## 4. Data model

No schema changes.

## 5. Locale keys

This spec doesn't add keys, but it locks a process for adding "What's new" copy in Play Console for every release. That copy:

- Is plain English (the localized listings will translate via the same translator pipeline)
- Is between 100–500 characters
- Names the user-visible change in non-engineer language
- Skips marketing-speak ("blazing fast 🚀")

Example from a future release:

> *Faster reminders that don't dismiss themselves when you put your phone down. Plus the option to mark a dose with a single tap from the lock screen. (And a smaller, friendlier paywall.)*

## 6. Routing

No routing changes.

## 7. Implementation steps (linear)

1. Create `docs/engineering/v1/release-cadence.md` with the policy text below.
2. Create `docs/engineering/v1/release-checklist.md` with the checklist below.
3. Add a one-line link from `../../README.md` to both new files (we will batch this when v1 is finalized).
4. Add a calendar reminder for Abdul to ship at least one release every 4 weeks (Abdul's task; not code).

### Policy text for `release-cadence.md`

```markdown
# Release Cadence Policy (v1)

## Hard rules
- **Ship at least once every 4 weeks**, even if the change is one string fix or a `versionCode`-only bump.
- **Never** edit `versionName` without bumping `versionCode`.
- **Never** ship two consecutive releases with the same "What's new" copy. If nothing changed, don't ship.

## Soft rules
- Bigger releases land on Tuesday or Wednesday — best window for review prompts and Play algorithm visibility.
- Avoid Friday releases unless rolling back a prior release; weekend monitoring is poor.
- Before a release, post on X build-in-public account (`docs/strategies/x/`) — install velocity from social aligned with release timing reads as healthy momentum.

## What counts as a 4-week release
- A real bug fix
- A real string improvement (visible to users)
- A real new feature, however small
- A localized listing update + matching `versionCode` bump
- A dependency upgrade with a release-note worth one sentence

## What does NOT count
- A version bump with no diff
- A copy change that nobody outside the team will notice
- A change that benefits only the developer (refactor)

## When to break the rule
- Real outage or critical bug → ship out-of-cadence immediately
- Extended dev work on a Tier-1 feature spanning 6+ weeks → still ship a small release in week 4 (split a tiny improvement off the trunk)
```

### Checklist text for `release-checklist.md`

```markdown
# Pre-Release Checklist (v1)

Run before every Play Console release.

## Code
- [ ] `pubspec.yaml`: `versionCode` incremented
- [ ] `pubspec.yaml`: `versionName` follows `MAJOR.MINOR.PATCH` and reflects scope
- [ ] No new packages added without a corresponding spec entry
- [ ] `flutter analyze` clean (or only known warnings)
- [ ] Tested on Android 9 device + Android 13/14 device
- [ ] Tested in Light AND Dark theme
- [ ] Tested in English AND Arabic (RTL)

## Listing
- [ ] "What's new" copy written (English, 100–500 chars)
- [ ] If localized listings are live: "What's new" copy translated for each locale (use the translator pipeline, NOT machine translation)
- [ ] Screenshots still match the current build (no UI regressions vs screenshots)

## Play Console
- [ ] Privacy policy URL still loads
- [ ] Data safety form still accurate (any new permissions or data collected this release?)
- [ ] Internal track tested first when feature is non-trivial; promote to production after manual smoke

## Post-release
- [ ] Watch crash-free rate for 48 h. Roll back if < 99 %.
- [ ] Reply to first 10 reviews of the new release
- [ ] Update `aso/05-aso-roadmap-90day.md` notes with release date
- [ ] Bump `versionCode` reference in any feature spec that shipped, in their `Implemented` block
```

## 8. Manual test plan

This feature has no code change to test. Verification:

1. Open `release-cadence.md` and `release-checklist.md` in a browser/Markdown viewer.
2. Walk through the checklist mentally for the next planned release.
3. Confirm Abdul has a calendar reminder set for the 4-week mark.

## 9. Rollout

- Documents land in the next commit. No release needed.

## 10. Definition of done

- Both files committed
- Linked from `v1/README.md`
- Abdul has acknowledged the policy

## 11. Out of scope

- Automating versionCode bumps (a script in `tools/`) — could be a v2 nice-to-have
- CI integration of any kind

## 12. Open questions

None.

---

## Implemented

- Date: 2026-05-09
- Files added:
  - `docs/engineering/v1/release-cadence.md`
  - `docs/engineering/v1/release-checklist.md`
- `docs/engineering/v1/README.md` updated with two new entries in the read-order list (after `04-definition-of-done.md`).
- Out of code path entirely; pure documentation. The behavioral change (4-week cadence) is on Abdul's side — set a recurring calendar reminder.
