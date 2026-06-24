# v2 — Session Summary & Cold-Start Brief

> **Read this first when resuming.** It captures the UX/architecture work done after v1 (self-profile, add-medicine + home redesign, theme rebrand, guest/login data safety + account isolation). It points at the real files — it does not duplicate code. v1's brief is still valid for the ASO/growth + earlier feature work; this file layers the newer engineering work on top.

| | |
| --- | --- |
| Session window | 2026-06-06 → 2026-06-07 |
| Author | Abdul (product owner) + Claude (engineer) |
| Build status | `dart analyze lib` → **0 errors** (only pre-existing deprecation infos: `withOpacity`/`surfaceVariant`/`onBackground`/`background`/`MaterialStateProperty`) |
| Commit status | **Uncommitted** — Abdul commits. Nothing pushed. |
| Tests | Manual QA only (codebase has no test suite). Per-area test steps below. |

---

## TL;DR

Five coordinated workstreams, all UI/UX + data-safety, **no core functionality changed** (DB schema, MedicineTable, notification scheduling, member/doctor links, edit/soft-delete, paywall 10-med cap, ads all intact):

1. **Self profile unification** — the "Me" `FamilyMemberTable` row is the single profile for the current user; editable from Settings → Edit Profile AND a pinned "You" card on the Family tab.
2. **Add-Medicine redesign** — fewer required fields (Name + Dose + Time), progressive disclosure, outline section cards, dosage entry sheet, Cupertino date/time pickers, dropdowns → bottom sheets.
3. **Home / Reminders revamp** — a "Today" engagement card + cleaner medicine cards.
4. **Theme rebrand** — accent went amber → blue → teal → **emerald `#10B981`** (final, user-chosen).
5. **Guest/login data architecture** — local data is never lost on sign-out, and **account isolation** swaps data when a different account signs in.

Persistent context also lives in the **memory files** (loaded automatically each session) — see `MEMORY.md` index; the four most relevant: `project_self_profile_unification.md`, `project_theme_and_addmedicine.md`, `project_guest_login_data.md`, plus this file.

---

## 1. Self profile unification ("Me")

**Problem:** the current user existed as two disconnected records — `UserTable` (Edit Profile) vs. an implicit "Me" `FamilyMemberTable` row that actually owns the user's medicines. Edit Profile was broken offline/for guests; the Family tab hid the self row (`fId == 1`), so the user couldn't manage themselves.

**Solution:** the "Me" `FamilyMemberTable` row is the source of truth for the profile; `UserTable` is a mirror. Self identity is resolved/persisted via `Preference.selfMemberId` (no more `fId == 1`).

Key files:
- `lib/database/helper/database_helper.dart` — `ensureSelfMember({selfName})` (get-or-create + back-compat); default `getFamilyMemberData()` now filters soft-deleted.
- `lib/utils/preference.dart` — `selfMemberId` accessors.
- `lib/ui/add_or_edit_profile_screen/add_or_edit_profile_screen_logic.dart` — Edit Profile is the offline-safe self editor (reads/writes self row, mirrors UserTable).
- `lib/Widgets/self_profile_card.dart` + `lib/ui/family_member_screen/family_member_screen_{logic,view}.dart` — pinned "You" card.
- `lib/ui/first_medicine/first_medicine_logic.dart`, `lib/ui/home/home_controller.dart` — ensure self exists on onboarding/home.
- Member rename/add/delete now refresh the home medicine/journal chips (`add_or_edit_family_member_screen_logic.dart`, `family_member_screen_logic.dart`, `medicine_screen_logic.dart`).

Detail: `memory/project_self_profile_unification.md`.

---

## 2. Add-Medicine redesign

- **Required fields = Name + Dose + Time only.** Everything else is pre-filled with editable defaults on open. See `applyDefaults()` / `_ensureSaveDefaults()` and relaxed validation in `lib/ui/add_medicine/add_medicine_controller.dart`.
- **Progressive disclosure + outline cards** — view rewrite in `lib/ui/add_medicine/add_medicine_screens.dart` (Medicine / Schedule / Who open; end-date, sound, doctor, status under "Advanced options"). Cards are **outline-only** (glass background shade removed per request).
- **Dosage sheet** — `lib/Widgets/dosage_bottom_sheet.dart` (`showDosageSheet`): amount stepper + presets + unit chips, behind one "Dosage" field. Replaced the confusing bare "Add Dosage" text field + unit dropdown.
- **Cupertino date/time pickers** — `lib/Widgets/cupertino_pickers.dart` (`showAppDatePicker` / `showAppTimePicker`); wired into start/end date + time in the controller.
- **Dropdowns → bottom sheets** — `lib/Widgets/picker_bottom_sheet.dart` (`showSelectionSheet` + `PickerField`). `custom_drop_down.dart`, `custom_drop_down_select_member.dart`, `custom_drop_down_select_doctor.dart` were rewritten to open it (same public APIs → all call sites unchanged: add-medicine, profile, family). `custom_drop_down_minutes.dart` (appointment, non-MVP) left as native.

Detail: `memory/project_theme_and_addmedicine.md`.

---

## 3. Home / Reminders revamp

- **"Today" card** — `lib/Widgets/today_plan_card.dart` + `lib/services/today_plan_service.dart` (scheduled-today + next dose), reusing `lib/services/adherence_service.dart` (taken-today + streak). Wired via `home_controller.refreshAdherence` / `home_screens.dart` (replaced the old `AdherenceCard` slot; refreshes after any add/edit/delete).
- **Medicine cards** — redesigned in `lib/ui/medicine_screen/medicine_list_screen.dart`: per-medicine colour as a left accent bar + pill avatar, info chips, a "Next: HH:MM" line. Tap → detail/edit/delete + paywall ad unchanged.

---

## 4. Theme / colour system  ⚠ read before any colour work

- Accent is driven by **two constants** in `lib/utils/color.dart`: `colorSecondaryLight` (= `#10B981` emerald) + `colorSecondaryDark` (`#059669`). They feed `secondary`/`onSecondary`/`onTertiary` in `themes/light_theme.dart` **and** `primary` in `themes/dark_theme.dart` (dark-mode primary IS the accent). Change those two to re-skin the app.
- **GOTCHA:** in `light_theme.dart`, `onPrimary == primary` (navy) and `onSecondary == secondary` (accent) — the "on" colours are NOT contrasting. For text/icons on a primary/secondary fill use explicit `Colors.white`. Do NOT "fix" `onPrimary`/`onSecondary` in the theme — ~12 screens reuse them as navy/accent text on light surfaces.
- `whiteText:true` in `setting_screen_view.menuItem` now uses `Colors.white` (was `colorScheme.error` = black → invisible).
- Accent = selection/active states (toggles, checkboxes, selected chips/segments, time chips, dosage chips). Navy = primary actions (Save, FAB, titles).

---

## 5. Guest / login data architecture + account isolation  ⚠ data safety

**Invariant: local SQLite is the source of truth and is NEVER deleted on sign-out.** Cloud (Firestore) is backup/sync only.

- **Sign out** (`lib/ui/setting/setting_screen_logic.dart` `singOut`): best-effort push → cloud, end Firebase/Google session, `setIsUserLogin(false)`, remove `firebaseAuthUid`/`firebaseEmail`. Keeps ALL local data + notifications + self profile. (Previously wiped everything → guest data loss; that was the original bug.)
- **Role-aware settings card** (`setting_screen_view.dart`): signed-in → "Log out"; guest → "Sign in to back up & sync" (`signInToBackup`).
- **Returning guest** (`get_started_screen_logic.continueAsGuest`): goes straight Home if already onboarded (no re-onboarding).
- **Account isolation** (`get_started_screen_logic._isolateLocalDataForAccount`, runs on Google sign-in before sync): `Preference.dataOwnerUid` records who owns local data (null = guest). If a **different** uid signs in → `DataBaseHelper.clearAllUserData()` + cancel notifications + clear self + pull that account's cloud. Same/guest → keep + claim + push. `home_controller.onInit` backfills `dataOwnerUid` for pre-existing logins.
- Guest medicine writes are gated by `getIsUserLogin()` in `add_medicine_controller` (no writes to a null/stale account).

Detail: `memory/project_guest_login_data.md`.

**Known acceptable edges:** (a) data created offline-while-logged-in then logged-out is cleared if a *different* account then signs in; (b) merge-by-id collisions are pre-existing `insertOrUpdate` behavior. Both are narrow; dominant flows are correct. A collision-safe sync keying (UUIDs) is a possible future hardening.

---

## Localization

Every user-visible string goes through `'txtKey'.tr` and must exist in **all 52** `lib/localization/languages/language_*.dart` files (English fallback ok). New keys added this round (anchored after `txtSelfProfileName`): `txtYou`, `txtTapToCompleteProfile`, `txtAdvancedOptions`, `txtMealAfter/Before/Any`, `txtNoTimesYet`, `txtToday`, `txtDosesToday`, `txtAllDoneToday`, `txtNoDosesToday`, `txtNext`, `txtTomorrow`, `txtNoData`, `txtDone`, `txtSignInBackupTitle`, `txtSetDosage`, `txtDosageSheetTitle`, `txtUnit`.

---

## How to resume

1. Read this file + the four memory files named above (auto-loaded).
2. `dart analyze lib` should be 0 errors before starting.
3. For colour work, re-read §4 (the `onPrimary`/`onSecondary` gotcha).
4. For auth/data work, re-read §5 (never auto-delete on sign-out).

### Manual QA checklist (after a fresh build, light + dark)
- **Add medicine:** only Name/Dose/Time empty; Dosage opens the sheet; date/time use Cupertino wheels; Unit/Person/Doctor open bottom sheets; cards are outline-only; accents emerald, no black/invisible text. Save + edit-prefill work.
- **Family:** "You" card pinned; editing it updates the medicine chips + Edit Profile.
- **Today card:** taken/scheduled + next dose + streak; updates after add/take.
- **Auth:** A signs in → adds med → logs out → B signs in → B sees only B's data → A signs back in → A's data restored. Guest add → sign-in keeps + backs up.
- **Settings:** Log out text white on emerald; guest sees "Sign in to back up".

---

## Versioning note
This is **v2-summary.md**. Per repo convention, do not edit v1/v2 in place — write **v3-summary.md** when the state next changes substantively. Old summaries are the audit trail.
