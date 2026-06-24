# Release Cadence Policy (v1)

## Hard rules
- **Ship at least once every 4 weeks**, even if the change is one string fix or a `versionCode`-only bump.
- **Never** edit `versionName` without bumping `versionCode`.
- **Never** ship two consecutive releases with the same "What's new" copy. If nothing changed, don't ship.

## Soft rules
- Bigger releases land on Tuesday or Wednesday — best window for review prompts and Play algorithm visibility.
- Avoid Friday releases unless rolling back a prior release; weekend monitoring is poor.
- Before a release, post on the X build-in-public account (`docs/strategies/x/`) — install velocity from social aligned with release timing reads as healthy momentum.

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
