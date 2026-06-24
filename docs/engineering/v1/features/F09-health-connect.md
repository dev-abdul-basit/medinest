# F09 · Google Health Connect Integration

| | |
| --- | --- |
| Roadmap ref | T1-3 |
| Effort | 1 week |
| Risk | med |
| Schema change | no |
| New package | YES — requires Abdul approval |
| Premium-gated | no (basic write) — extended read in v2 |
| ASO signals moved | KW (`health connect`, `google fit`), ★ |
| Status | ❌ **KILLED (2026-05-30)** — category constraint |

> ## ❌ KILLED 2026-05-30 — do not implement
>
> Google rejected the **Health** category for MediNest because it ships under an **individual** developer account, not an organization account. Health Connect integration depends on the same health-data declarations / Play "Health apps" program that the rejection blocks, so this feature is **dead for the foreseeable future**, not merely deferred.
>
> **What this changes:** the F09 blocker decision in `docs/v1-summary.md` is now resolved as **No**. No `health` package, no `AndroidManifest` health permissions, no `HealthConnectService`. Remove the `health connect` / `google fit` keyword surface from ASO targets — we cannot earn the "Health Connect compatible" badge without the category.
>
> **Revisit trigger:** only if Abdul converts to an **organization** developer account (registered business + D-U-N-S number). At that point re-open this spec; the implementation below is still valid.
>
> The original spec is retained below for that future scenario.

## 1. Why we're shipping it

Google Health Connect is the centralized health-data layer on Android (replacing Google Fit's apps-side API). Apps that integrate get a "Health Connect compatible" badge in Play Store and access to the `health connect` keyword surface. Implementation is thinner than expected — we only need to write a "medication taken" record per dose. Reading data from Health Connect is *not* in v1 scope.

## 2. What changes for the user

- New Settings → "Connect to Health Connect" toggle.
- On enable: OS-level Health Connect permission flow.
- Once granted: each dose marked taken in MediNest writes a record to Health Connect's medication log. User can view their MediNest doses inside Health Connect alongside other health apps.
- No change to app behavior if the user doesn't enable it.

## 3. What changes in the code

- **`pubspec.yaml`** — add `health: ^X.Y.Z` (current stable). Confirm version with Abdul before editing. Recommended: `^11.x` or whatever is latest at implementation time.
- **`android/app/src/main/AndroidManifest.xml`** — Health Connect permissions block. Required entries (per Health Connect docs):
  ```xml
  <uses-permission android:name="android.permission.health.WRITE_HYDRATION" />
  <!-- adjust based on what we actually write; medication is in some SDK versions, hydration as a placeholder is wrong -->
  ```
  **Note:** as of writing, Health Connect's "medication" data type is in beta. If unavailable in the `health` plugin version we choose, we proxy by writing to "Notes" or "Other" with a typed payload. Confirm at implementation time. If the data type isn't available, **stop and discuss with Abdul** before writing a workaround.
- **`android/app/src/main/AndroidManifest.xml`** — add the intent-filter for Health Connect permissions screen as required by the docs.
- **NEW: `lib/services/health_connect_service.dart`** *(new file)* — wraps the `health` package. Methods:
  - `Future<bool> isAvailable()`
  - `Future<bool> requestPermissions()`
  - `Future<void> recordDoseTaken({required String medicineName, required DateTime takenAt})`
- **`lib/utils/preference.dart`** — add `healthConnectEnabled` bool.
- **`lib/ui/setting/setting_screen_view.dart`** — new toggle row.
- **`lib/ui/home/home_controller.dart`** — when "Taken" is tapped (existing handler), additionally call `HealthConnectService().recordDoseTaken(...)` if `healthConnectEnabled`. Wrap in try/catch — Health Connect write failure must not block the local save.
- **`lib/ui/full_screen_notification/full_screen_notification_view.dart`** — same.
- **Locale files** — new keys.

## 4. Data model

No SQLite schema changes.

New `Preference` key:

```dart
static const String healthConnectEnabled = "HEALTH_CONNECT_ENABLED";
Future<void> setHealthConnectEnabled(bool v) => _pref!.write(healthConnectEnabled, v);
bool getHealthConnectEnabled()              => _pref!.read(healthConnectEnabled) ?? false;
```

## 5. Locale keys

```
'txtHealthConnectTitle': "Health Connect",
'txtHealthConnectSubtitle': "Sync your medication doses with Google Health Connect.",
'txtHealthConnectEnable': "Enable",
'txtHealthConnectDisable': "Disable",
'txtHealthConnectNotAvailable': "Health Connect is not available on this device.",
'txtHealthConnectPermissionDenied': "Permission denied. You can enable later from Settings.",
```

## 6. Routing

No new route. The setting toggle handles the OS permission flow inline.

## 7. Implementation steps (linear)

1. Confirm with Abdul: package choice, version, AndroidManifest changes are OK to make.
2. Run `flutter pub add health@^<version>` (Abdul does this; Claude does not run pub).
3. Update `AndroidManifest.xml` with required permissions and Health Connect activity intent-filter.
4. Add `Preference` key + accessors.
5. Add locale keys + replicate.
6. Implement `HealthConnectService` with the three methods. Handle "not available" (older Android, Health Connect not installed) and "permission denied" branches gracefully.
7. Add the Settings toggle. On tap-enable: call `isAvailable()`, then `requestPermissions()`, then `setHealthConnectEnabled(true)`. On tap-disable: just `setHealthConnectEnabled(false)` (revoking the permission requires the user to do it from Health Connect's app — reflect in copy if needed).
8. In all "Taken" tap handlers: best-effort write to Health Connect, swallow exceptions, log via `Debug.printLog`.
9. Test on Android 14 device with Health Connect installed, Android 11 device without.

## 8. Manual test plan

**Golden path:**

1. Android 14 device, Health Connect installed.
2. Settings → Toggle Health Connect ON.
3. **Expected:** OS permission screen. Grant permissions.
4. Add a medicine. Mark a dose taken.
5. Open Health Connect app → Medications (or the data type we wrote to). Verify the dose record exists with correct medicine name and timestamp.

**Edge case 1 — Health Connect not installed:**

1. Older Android device or fresh device without Health Connect.
2. Tap toggle.
3. **Expected:** toast / message: `Health Connect is not available on this device.` Toggle does not flip. No crash.

**Edge case 2 — Permission denied:**

1. Tap toggle. On the OS prompt, deny.
2. **Expected:** toggle stays off. Message shown.

**Edge case 3 — Health Connect write fails after permission granted:**

1. Force a write failure (e.g., revoke permission via Health Connect app while MediNest is foregrounded).
2. Mark a dose taken.
3. **Expected:** local save succeeds, dose appears in MediNest history. Health Connect write logged as failure but does not crash.

**Edge case 4 — Premium vs free:**

This feature is free in v1 (it's a trust signal, not a monetization point). Confirm both free and premium can use it.

**Regression check:**

Take a dose with toggle OFF. Local history still works. No background writes happen.

## 9. Rollout

- Internal track first.
- After internal QA, full production.
- Roll-back: revert toggle (the settings row), keep package + service code in place. Less destructive than removing the package.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:

- Real Health Connect write verified in HC app
- Failure cases all handled gracefully
- AndroidManifest changes documented in the `Implemented` block

## 11. Out of scope

- Reading medication data from Health Connect (importing meds set up in another app)
- Writing other data types (sleep, weight, etc.)
- iOS / Apple Health equivalent (separate spec, F-future)
- Dynamic permission revocation handling — beyond best-effort try/catch

## 12. Open questions

1. Exact data type to write — confirm Health Connect SDK supports "Medication" record. If not, fallback design is needed.
2. Wording around "Disable" — if it doesn't actually revoke OS permission, the copy must say "Stop syncing" rather than "Disable" to be honest.
3. Privacy policy update — if we write to Health Connect, our privacy policy must say so. Update in tandem with F05.

---

## Implemented — STATUS: BLOCKED on package + AndroidManifest approval

- Date of attempt: 2026-05-09
- versionCode shipped: **none**
- **Why blocked:** the spec explicitly calls these out as requiring Abdul's approval *before* implementation:
  1. Adding `health: ^11.x` (or current stable) to `pubspec.yaml`
  2. Modifying `android/app/src/main/AndroidManifest.xml` with Health Connect permissions + intent-filter
- The role doc explicitly forbids Claude from making these decisions silently.
- **What I did NOT do (deliberately):**
  - Did not edit `pubspec.yaml` to add the package
  - Did not modify any file under `android/`
  - Did not create the `HealthConnectService` shell — without the package, the file would not compile, polluting the codebase
- **What I'm asking from you to unblock F09:**
  1. Decide: ship Health Connect support in v1 or defer to v2? (Realistic: this is a 1-week feature with regulatory implications. The store-listing benefit is real but small.)
  2. If yes: confirm package version (`health: ^X.Y.Z`) — recommend using whatever's current at implementation time. Confirm the `medication` data type is supported in that version.
  3. If yes: review the AndroidManifest changes I'll propose before they land.
- **Recommended next session:** confirm decision, then I implement service + settings toggle + tap-handler wiring in one focused pass. Estimate: 1 day with the package and manifest sign-off in hand.
