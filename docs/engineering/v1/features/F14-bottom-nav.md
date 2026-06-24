# F14 · Bottom-navigation refactor

| | |
| --- | --- |
| Roadmap ref | new (post-MVP pivot; navigation surface for the 3 pillars) |
| Effort | 1 day |
| Risk | med — touches Home, removes drawer, embeds Family screen as a tab |
| Schema change | no |
| New package | no |
| Premium-gated | no |
| ASO signals moved | R (journal discoverability), ★ (modern feel) |
| Status | in-progress |

## 1. Why we're shipping it

The MVP product pillars are Pill Reminder + Health Journal + Family Medication Support (see `docs/context/app-snapshot.md` "MVP scope"). The current side-menu (drawer) hides the journal behind a hamburger and demotes Family to a "settings-style" list, which is the wrong shape for three equal pillars. Bottom navigation with three tabs gives each pillar permanent surface area and naturally promotes the journal as the second pillar — the discoverability fix the MVP pivot needs.

## 2. What changes for the user

Before:
- Tap the hamburger top-left → drawer slides in → tap a destination
- Top of Home has a 2-tab pill bar (Medicine · Journal)

After:
- No drawer. No hamburger.
- App bar shows the current tab title and a Settings gear icon top-right
- Bottom navigation bar with 3 tabs: **Reminders** · **Journal** · **Family**
- FAB stays contextual:
  - Reminders tab → `+` (Add Medicine)
  - Journal tab → pencil (Add Journal)
  - Family tab → `+` (Add Family Member)
- Tap the Settings gear → opens the Settings screen (which already holds Profile, History, Theme, Language, Privacy, About, Logout, Subscribe)

## 3. What changes in the code

- **`lib/ui/home/home_binding.dart`** — add `Get.put(FamilyMemberScreenLogic())` so the Family tab body can `Get.find` its logic.
- **`lib/ui/home/home_controller.dart`** — bump `TabController(length: 2)` to `length: 3`. Remove `isDrawerOpen` field and `onDrawerChanged()` (no more drawer to track). Trim `onWillPop()` to drop the drawer branch. Add `gotoAddFamilyMember()` for the new tab-2 FAB. Mark `gotoDoctorScreen()` as `@deprecated` in a comment (out of MVP) but keep the method since notification deep-links may still reach it.
- **`lib/ui/home/home_screens.dart`** — full rewrite of `HomeScreen.build`. Replace the inline drawer + top TabBar with:
  - `appBar: CommonAppBar(title: <tab title>, actionWidget: settings icon, onActionTap: goToSetting)`
  - `bottomNavigationBar: NavigationBar(selectedIndex: selectedTabIndex, onDestinationSelected: onTabSelected, destinations: [...3 destinations])`
  - `body: TabBarView(controller: mainTabController, physics: NeverScrollableScrollPhysics(), children: [MedicineScreenPage, JournalScreenPage, FamilyMemberScreenPage])`
  - FAB switch handles 3 cases.
  - **Delete** the `NavigationDrawer`, `_DrawerHeader`, `_DrawerItem`, `_LogoutRow`, `_AvatarFallback` classes from this file.
- **`lib/localization/languages/language_en.dart`** — add `'txtFamily': "Family"` and `'txtReminders': "Reminders"`. Existing `txtJournal` reused.
- **`lib/localization/languages/language_*.dart` (×51 non-en)** — inject the same two keys with English fallback, idempotent (skip if already present).
- **`lib/utils/constant.dart`** — keep `idHome`. `idDrawerSheet` becomes dead but is kept (other code in `home_controller.dart` still calls `update([Constant.idDrawerSheet])` from `getCurrentTheme`/`syncDataToFirebase`/`onSuccessPurchase`; removing those updates is out of scope here).

## 4. Data model

No schema changes. No new prefs.

## 5. Locale keys

```
'txtFamily': "Family",
'txtReminders': "Reminders",
```

Both must be present in every `language_*.dart`. English fallback for non-en locales — translator pipeline picks them up next pass.

## 6. Routing

No new routes. `AppRoutes.familyMember` and `AppRoutes.setting` remain; the bottom-nav surface uses screens inline (Family) or via gear navigation (Settings).

## 7. Implementation steps (linear)

1. Update `home_binding.dart` to also put `FamilyMemberScreenLogic`.
2. Update `home_controller.dart`: `TabController(length: 3)`, remove `isDrawerOpen` field + `onDrawerChanged()` method, trim `onWillPop()`, add `gotoAddFamilyMember(BuildContext)` calling `Get.toNamed(AppRoutes.addOrEditFamilyMember)` then refreshing the family list.
3. Rewrite `home_screens.dart` — delete drawer classes, build app bar + bottom nav + TabBarView. Three tabs: MedicineScreenPage, JournalScreenPage, FamilyMemberScreenPage. Contextual FAB per tab.
4. Add `txtFamily` and `txtReminders` to `language_en.dart`.
5. Idempotently inject same keys (English fallback) into the 51 non-en locale files.
6. Manual test plan.

## 8. Manual test plan

- **Golden path**
  1. Fresh launch (or hot-restart) → land on Home.
  2. Bottom nav visible with 3 tabs: Reminders · Journal · Family. App bar title says "Reminders".
  3. No hamburger icon top-left. Top-right shows a gear icon.
  4. Tap **Journal** tab → app bar title updates, journal list shows, FAB icon is pencil.
  5. Tap **Family** tab → app bar title updates, family list shows. FAB icon is `+`.
  6. Tap FAB on Family tab → navigates to Add Family Member screen. Add a member. Return → list shows the new member.
  7. Tap **Settings** gear → opens Settings screen. All previous drawer items (Profile, History, Theme, Language, Privacy, About, Logout, Subscribe) reachable from here.
  8. Back gesture from Home → press-back-again-to-exit toast appears (the existing onWillPop behavior).

- **Edge case: deep-link from full-screen notification**
  - Trigger a medicine reminder. Tap the notification. Verify routing still works (the notification handler in `main.dart` should be untouched).

- **Edge case: tab persistence across orientation / theme change**
  - Switch to dark theme from Settings → return to Home → currently-active tab is preserved.

- **Regression check**
  - Adherence card: when on Reminders tab, the adherence card still renders above the medicine list. Take a dose → return → card updates. (F08 functionality unaffected.)
  - Paywall: add 10 medicines, attempt 11th → paywall fires as before.

## 9. Rollout

- No feature flag (per canon, solo dev). Ship in next versionCode bump.
- Roll-back: revert the four touched files (`home_binding.dart`, `home_controller.dart`, `home_screens.dart`, `language_en.dart`) + revert the locale-injection script.

## 10. Definition of done

Per `../04-definition-of-done.md`.

## 11. Out of scope (for this feature)

- iOS-style visual pass (Cupertino components, frosted glass) — covered in F15.
- Caregiver Mode Stage 2 prominence shift — covered in F11 Stage 2.
- Journal file-path rename (`add_or_edit_appointment/` → `journal/`) — covered in F16.
- Removing `idDrawerSheet` update calls from HomeController — cosmetic, deferred to v2 cleanup.
- Removing the deprecated `gotoDoctorScreen()` method — kept in code per the "code may still exist for out-of-MVP screens" call.

## 12. Open questions

None. Decisions confirmed 2026-05-11:
- 3 tabs + Settings gear (vs 4 tabs with Settings as tab)
- Bottom nav (vs drawer)
- iOS Medium scope deferred to F15

---

## Implemented (filled in after ship)

- Date: 2026-05-11
- versionCode shipped: (pending Abdul commit)
- Commit SHA: (pending)
- Files changed:
  - `lib/ui/home/home_binding.dart` — added FamilyMemberScreenLogic to Get.put
  - `lib/ui/home/home_controller.dart` — TabController length 3, drawer state removed, gotoAddFamilyMember added
  - `lib/ui/home/home_screens.dart` — full rewrite: drawer removed, bottom nav added, app bar with gear
  - `lib/localization/languages/language_en.dart` — txtFamily + txtReminders added
  - `lib/localization/languages/language_*.dart` (51 non-en) — same two keys injected idempotently with English fallback
- Deviations: none
