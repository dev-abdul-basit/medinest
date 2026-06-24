# App Snapshot — MediNest

Last updated 2026-05-11 (MVP scope amended; previous snapshot was 2026-05-09 against repo HEAD `4d4cbf2`). This file is the factual baseline. ASO copy and feature claims must be checkable against what is in this file. If something here is wrong, fix it — don't write around it.

> **MVP scope (2026-05-10):** product pillars are **pill reminder** + **health journal**, with family-medication support across multiple profiles. Doctor profiles and appointment reminders were **removed from the MVP** and moved to the future roadmap (`docs/feature-improvements/feature-roadmap.md`). The code in `lib/ui/add_or_edit_doctor_screen/`, `lib/ui/doctors_screen/`, `lib/ui/appointment_history_screen/`, `lib/ui/full_screen_appointment_notification/` may still exist, but those features are not advertised, not in the store listing, and not part of the MVP product story. Confirm code-state separately before counting on these screens being live.

> **Reshape (2026-05-30) — two binding constraints:**
> 1. **Play category = non-Health.** Google rejected the Health category on this **individual** developer account (Health/Medical categories effectively require an organization account with D-U-N-S verification). MediNest ships in **Productivity** (recommended). Search ranking for `pill reminder` / `medication reminder` is keyword-driven and is unaffected; only browse / top-charts placement changes. Store copy must avoid medical/diagnostic *claims* (no "treat", "diagnose", "manage your condition") — describe it as a reminder/organizer. **Health Connect (F09) is killed** — it depends on health declarations an individual account cannot make.
> 2. **Primary audience = United States** (was Saudi/MENA). Drives: USD-first pricing, a perfected en-US listing first, and a US competitor set (Medisafe, MyTherapy, Round Health, Sevenlogics Pill Reminder). The 50-locale store-listing rollout is **deprioritized** behind the en-US listing.

---

## Identity

| | |
| --- | --- |
| Public name | Medinest – Pill Reminder |
| Android package | `com.mednest.pill.reminder` |
| Version | 1.0.8 (versionCode 11) |
| Min SDK / Target SDK | Android 26 / 36 |
| iOS | Targets exist (`pubspec.yaml`); Play Store is the active channel |
| Stack | Flutter 3 · Dart · GetX · Sqflite · Firebase (Auth, Firestore, Storage, FCM, App Check) |
| Play category | **Productivity** (recommended) — Health category rejected on individual account, 2026-05-30 |
| Developer account | **Individual** (not organization) — blocks Health/Medical categories + Health Connect |
| Primary market | **United States** (was Saudi/MENA) — drives USD pricing + en-US-first listing |

## Live store metrics

> **Empty — pending you pasting from Play Console.** See `NEXT-STEPS.md` step 1.

| Metric | Value | Date checked |
| --- | --- | --- |
| Total installs | TBD | — |
| Active installs | TBD | — |
| Star rating | TBD | — |
| Review count | TBD | — |
| Crash-free rate | TBD | — |
| ANR rate | TBD | — |

## Feature inventory

### Reminders & medications (MVP pillar 1)
- Add medicine with name, dosage, time(s), frequency
- Daily and custom schedules
- 11 built-in alert sounds in `assets/sounds/` (`analogwatch`, `bells`, `cartoon`, `clock`, `defaulttone`, `google`, `iphone`, `kids`, `silent`, `telephone`, `vip`)
- Local notifications via `flutter_local_notifications` (timezone-aware via `flutter_timezone`)
- Full-screen reminder (lockscreen-style) — see `lib/ui/full_screen_notification/`
- Medicine history log — see `lib/ui/medicine_history_screen/`

### Health journal (MVP pillar 2)
- Free-form notes — no template, attached to a specific medicine or standalone
- Source files: `lib/ui/add_or_edit_appointment/add_or_edit_journal_view.dart`, `lib/ui/appointment_screen/journal_list_screen.dart` (file paths inherited from the legacy appointment-screen; rename pending)
- Positioned in marketing as "the note that helps the next doctor visit" — the journal is what differentiates MediNest from category leaders

### Multi-profile (MVP pillar 3 — supports both)
- Family-member profiles (`lib/ui/add_or_edit_family_member_screen/`, `lib/ui/family_member_screen/`)
- User profile (`lib/ui/add_or_edit_profile_screen/`)

### Removed from MVP — future roadmap
The following features exist in code but are NOT in the current MVP scope. Do not advertise them in the store listing or social copy. Tracked as future-roadmap items in `docs/feature-improvements/feature-roadmap.md`.

- **Doctor profiles** — `lib/ui/add_or_edit_doctor_screen/`, `lib/ui/doctors_screen/`. Linkable to medicines. Returning post-MVP once the doctor-export PDF feature (currently F10) is shipped.
- **Appointment reminders** — `lib/ui/add_or_edit_appointment/`, `lib/ui/appointment_history_screen/`, `lib/ui/full_screen_appointment_notification/`. Returning post-MVP once we have data on whether users want a unified reminder surface or two separate ones.

### Account & sync
- Sign in with Google (`google_sign_in`)
- Firebase Auth + Firestore for cloud sync
- Sqflite local DB → source of truth, Firebase = backup/sync
- App Check enabled

### UX & content
- Onboarding: `lib/ui/get_started_screen/`, `lib/ui/introduction_screen/`
- Settings (theme, language, sounds, premium): `lib/ui/setting/`
- Lottie animations
- Screenshot + share-plus
- In-app review prompts (`in_app_review`)

### Localization
The in-app UI is **already translated into ~50 languages** (see `lib/localization/languages/`). Confirmed locales include:

`en_US, zh_CN, ar_SA, fr_FR, de_DE, hi_IN, ja_JP, pt_PT, ru_RU, es_ES, ur_PK, vi_VN, id_ID, bn_IN, ta_IN, te_IN, tr_TR, ko_KR, pa_IN, it_IT, zh_TW, az, be, bg, cs, el, fa, fil, gu, ha, hr, hu, jv, kn, la, ml, mn, mr, my, my_MY, nb, nl, or, pl, ro, sq, su, sv, th, uk, yo, zu`

> **Implication for ASO:** the Play Store listing currently ships in English only. Each localized store listing is a separate index in Google Play search. We are leaving every non-English query on the table. See `aso/05-aso-roadmap-90day.md` Week 4–8.

## Free vs. premium gates

Hardcoded in code, not server-driven (so changing the gates ships in a release):

| Limit | Free cap | Source |
| --- | --- | --- |
| Medicines | 10 | `home_controller.dart` paywall trigger |
| Appointments | 10 (legacy — feature out of MVP) | `appointment_history_screen_logic.dart` |
| Ads | shown | banner + interstitial |
| Journal entries | shown as "unlimited" in current copy — verify in code | `pro_version_screen.dart` |

> Marketing implication: only the medicines cap (10) is referenced in MVP store/listing copy. The appointment cap exists in code but is not part of the user-facing MVP story. Listing copy frames Premium as: ad-free, unlimited medicines, priority support — journal stays free.

> Action: confirm whether journals/notes have a free cap in code. If the listing claims "unlimited journals on Premium" but free is also unlimited, that line is wasted real estate.

## Tech-debt / risk that affects ASO

- **No analytics on paywall hits** — we can't tell what user behaviour drives the upgrade. Fix logged in `feature-improvements/feature-roadmap.md`.
- **Interstitial frequency** — capped via `Preference.getInterstitialAdCount`, but the cap value isn't documented. If aggressive, this hurts review sentiment ("too many ads"), which hurts rankings. Audit before scaling installs.
- **Min SDK 26** — excludes pre-Android 8 devices. Real risk in India / Pakistan where older devices are common. Quantify exclusion via Play Console "Device catalog" before deciding to lower.
