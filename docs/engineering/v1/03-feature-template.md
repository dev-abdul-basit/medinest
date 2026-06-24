# Feature Spec Template (v1)

Every feature spec under `features/` follows this exact structure. Copy this file as the starting point.

> Section order is not optional. Skipping a section is a bug; if it's not applicable, write `n/a` rather than removing the heading.

---

```markdown
# F0X · <feature name>

| | |
| --- | --- |
| Roadmap ref | (e.g. QW-1, T1-3) |
| Effort | (½ day · 1 day · 1 week · 2 weeks) |
| Risk | (low · med · high) |
| Schema change | (yes / no — yes requires DB version bump) |
| New package | (yes / no — yes requires Abdul approval before implementation) |
| Premium-gated | (yes / no) |
| ASO signals moved | (R · ★ · KW · CVR · $$ · L) |
| Status | (spec · in-progress · shipped) |

## 1. Why we're shipping it
2–4 sentences. The user / business outcome. Cross-link to the ASO doc that motivated it. No fluff.

## 2. What changes for the user
A user-perspective description. What they see, tap, hear, save, lose. Include before / after if the change is non-obvious.

## 3. What changes in the code
File-by-file delta, in dependency order. Each entry:

- **`relative/path/to/file.dart`** — what changes (one or two lines)

If a new file is created, mark `(new)`. If a file is moved, call it out. Be specific about what's added vs replaced.

## 4. Data model
Tables, columns, prefs, enums affected. If `Schema change` is `no`, write `No schema changes`. If yes, include:

- New columns + types + default values
- Migration SQL (within `database_helper.dart` version-bump block)
- New `Preference` keys + getter/setter signatures

## 5. Locale keys
List every new `txt…` key with its English value:

```
'txtMyNewKey': "My new English string",
```

State explicitly which language files must receive the key (default: all of them, with English fallback).

## 6. Routing
If a new route is added: routing const + GetPage entry block. Otherwise `No routing changes`.

## 7. Implementation steps (linear)
1. Step one (refer to file paths in section 3)
2. Step two
3. ...

These are the exact steps Claude follows during implementation. Each step should be commit-able if interrupted.

## 8. Manual test plan
Tap-by-tap on a real device:

- **Golden path**
  1. Open the app
  2. ... (concrete steps)
  3. Expected: ...

- **Edge case 1: <name>**
  - Steps + expected result

- **Regression check**
  - One adjacent feature to retest. (E.g., if we touch the home controller, we re-test the medicine list filter.)

## 9. Rollout
- Behind a feature flag? (default in v1: no — solo dev codebase, ship-or-don't)
- Targeted release? (e.g., internal track first)
- Roll-back plan: which file to revert + what to expect

## 10. Definition of done
Reference `../04-definition-of-done.md`. Override or add only if necessary.

## 11. Out of scope (for this feature)
What this spec does NOT cover, even if related. Prevents scope creep.

## 12. Open questions
Anything unresolved as of spec freeze. **Must be answered before implementation starts.**

---

## Implemented (filled in after ship)

- Date: YYYY-MM-DD
- versionCode shipped: NN
- Commit SHA: <sha>
- Deviations from spec: <none, or describe>
- Lessons / notes for v2: <optional>
```

---

## How to fill in each section well

### `Why we're shipping it`
Cite **one** signal we're moving. "We think it'll improve retention" is not a why; "review-prompt fires too early — see ../../aso/feature-roadmap.md QW-2 — empirical pattern is review-prompt timing moves rating averages 0.1–0.3 stars" is.

### `What changes for the user`
Write it as if QA is reading it. "User opens Settings → Privacy → toggles X → toast appears." Future-you and Abdul will both refer to this when verifying done-ness.

### `What changes in the code`
Be specific enough that a fresh session of Claude can implement without re-discovering the codebase. Include:

- File paths exact (case-sensitive)
- Whether you're adding a method to an existing class or creating a new one
- Which existing pattern you're matching ("same shape as `medicine_screen_logic.dart`'s `getAllFamilyMembers()` method")

### `Manual test plan`
The single most important section for v1. We have no automated tests. If this section is vague, the feature ships broken. Steps need to fit on a phone screen-by-screen — number them, expect concrete state at each step.

### `Out of scope`
This is where you stop yourself from doing too much. Examples:

> *"This feature changes paywall copy only. It does NOT modify paywall trigger logic — that stays in `home_controller.dart` and is not touched."*

When in doubt, scope down.
