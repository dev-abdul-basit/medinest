# Architecture Canon (v1)

This is what the codebase *actually* does, audited from real files. Implementation in v1 conforms to this document. If something here is wrong, fix this file before changing the code.

> When the doc and the code disagree, **the code wins** for v1. Update the doc, then keep going.

---

## Folder layout (under `lib/`)

```
lib/
├── main.dart                    ← app bootstrap, exposes flutterLocalNotificationsPlugin
├── Widgets/                     ← reusable widget catalog. PascalCase folder, Dart files snake_case.
├── connectivity_manager/        ← internet check helper (InternetConnectivity)
├── database/
│   ├── helper/
│   │   ├── database_helper.dart      ← Sqflite singleton: DataBaseHelper.instance
│   │   └── firestore_helper.dart     ← Firestore wrapper: FireStoreHelper()
│   └── tables/<entity>_table.dart    ← model classes (one per entity)
├── date_time_line/              ← infinite calendar widget (in-house)
├── generated/                   ← codegen (assets.dart). Do not hand-edit.
├── google_ads/
│   ├── ad_helper.dart                ← AdMob unit IDs, gated by Debug.googleAd
│   └── custom_ad.dart                ← BannerAdClass widget
├── in_app_purchase/
│   ├── iap_callback.dart
│   ├── iap_receipt_data.dart
│   └── in_app_purchase_helper.dart   ← InAppPurchaseHelper().buySubscription(...)
├── localization/
│   ├── locale_constant.dart
│   ├── localizations_delegate.dart   ← AppLanguages extends Translations (GetX)
│   └── languages/language_<locale>.dart  ← ~50 locales, each is final Map<String, String>
├── notification/
│   └── notification_helper.dart      ← NotificationHelper.instance
├── routes/
│   ├── app_routes.dart               ← string constants
│   └── app_pages.dart                ← GetPage list
├── services/
│   └── google_auth_service.dart
├── themes/
│   ├── app_theme.dart
│   ├── light_theme.dart
│   └── dark_theme.dart
├── ui/                          ← one folder per screen
│   └── <feature>/
│       ├── <feature>_binding.dart
│       ├── <feature>_logic.dart  OR  <feature>_controller.dart
│       └── <feature>_view.dart   OR  <feature>_screen.dart  OR  <feature>_screens.dart
└── utils/
    ├── constant.dart                 ← Constant class — kitchen sink
    ├── preference.dart               ← Preference singleton over GetStorage
    ├── debug.dart                    ← Debug.printLog, feature flags
    ├── enums.dart, asset.dart, color.dart, font_style.dart, sizer_utils.dart
    ├── ringtone_service.dart
    └── utils.dart                    ← Utils.showToast, generic helpers
```

### Naming inconsistencies that are normal here

These exist in the codebase and are part of v1's accepted reality. **Don't refactor.**

- Some screens use `*_logic.dart`, others `*_controller.dart`. Both extend `GetxController`.
- Some screens end in `_view.dart`, others `_screen.dart`, others `_screens.dart`.
- Mixed: `MedicineScreenLogic`, `HomeController`, `ProVersionController`. All are bound the same way.
- New features should pick one of the two patterns and stick with it inside that one feature folder.

---

## State management — GetX

### Controller pattern

```dart
class XxxLogic extends GetxController {
  // public state — plain Dart fields, NOT Rx<T>
  int selectedIndex = 0;
  List<MedicineTable?> medicines = List<MedicineTable?>.empty(growable: true);

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    medicines = await DataBaseHelper.instance.getMedicineData();
    update([Constant.idMedicineList]);   // ← rebuild target, by id
  }
}
```

- **No `Rx<T>` / `Obx`.** State is plain fields; rebuilds are fired with `update([...])`.
- Update IDs are `Constant.idXxx` strings, declared in `lib/utils/constant.dart`.
- `Future.delayed`, `Get.forceAppUpdate()`, and `Debug.printLog` are common in real controllers — match their use.

### Binding pattern

```dart
import 'package:get/get.dart';
import 'xxx_logic.dart';

class XxxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => XxxLogic());
  }
}
```

Always `Get.lazyPut`, never `Get.put` (instantiation on first navigation, freed on `Get.off*`).

### View pattern

```dart
class XxxScreen extends StatelessWidget {
  const XxxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XxxLogic>(
      id: Constant.idXxx,
      builder: (logic) => Scaffold( ... ),
    );
  }
}
```

- `StatelessWidget` is preferred. State lives in the logic class.
- `GetBuilder<T>(id: ..., builder: ...)` for partial rebuilds.
- Multiple `GetBuilder`s can target different `Constant.idXxx` ids inside one screen.

### Routing

Add a route by editing **two** files:

1. `lib/routes/app_routes.dart` — `static const String xxx = '/xxx';`
2. `lib/routes/app_pages.dart` — append to `AppPages.list`:
   ```dart
   GetPage(
     name: AppRoutes.xxx,
     page: () => const XxxScreen(),
     binding: XxxBinding(),
   ),
   ```

Navigate with `Get.toNamed(AppRoutes.xxx)`. Pass arguments via `Get.toNamed(... , arguments: { Constant.idIsEditProfile: true })` and read in `onInit` via `Get.arguments`.

---

## Persistence

### SQLite — `DataBaseHelper`

Singleton at `lib/database/helper/database_helper.dart` accessed via `DataBaseHelper.instance`.

- Tables in `lib/database/tables/<entity>_table.dart`.
- Each table file defines a model class with `toMap()`, `fromMap()`, `toJson()`, `toRawJson()`, `fromJson()`.
- Core tables in v1: `medicine_table`, `medicine_history_table`, `family_member_table`, `notification_table`, `journal_table`, `journal_history_table`, `journal_notification_table`, `doctors_table`, `user_table`, `shape_table`.
- **Schema changes require a database version bump.** Find the current version in `database_helper.dart`. Any spec that touches the schema must explicitly call this out and include the migration plan.

### Firestore — `FireStoreHelper`

Wrapper at `lib/database/helper/firestore_helper.dart`. Used as cloud sync, *not* as source of truth. SQLite is the source of truth.

Pattern:
```dart
if (await InternetConnectivity.isInternetConnect(Get.context!)) {
  FireStoreHelper().addAndUpdateMedicine(id.toString(), data);
}
```

Always wrap in the connectivity check. Never assume online.

### Key/value — `Preference` (GetStorage wrapper)

Singleton at `lib/utils/preference.dart`. Access via `Preference.shared`.

Adding a new pref:

1. Append a `static const String yourKey = "YOUR_KEY";` (UPPER_SNAKE_CASE values).
2. Add a typed getter + setter pair beneath the existing ones, following the existing style:
   ```dart
   Future<void> setYourFlag(bool value) =>
       _pref!.write(yourKey, value);
   bool getYourFlag() => _pref!.read(yourKey) ?? false;
   ```
3. Use via `Preference.shared.setYourFlag(true)` / `Preference.shared.getYourFlag()`.

Don't sprinkle raw `_pref!.read(...)` calls in feature code — always go through a typed accessor.

---

## Notifications

`lib/notification/notification_helper.dart` — `NotificationHelper.instance`.

The plugin instance is **global**, exposed from `main.dart`:

```dart
import 'package:medinest/main.dart';
// ...
await flutterLocalNotificationsPlugin.cancel(notificationId);
```

### Notification ID convention

```dart
final id = notification.nId! + Constant.notificationStartID;  // 1000 + nId
```

Always use `Constant.notificationStartID` (1000) as the offset. Direct integer IDs are fragile.

### Scheduling

- Medicine reminders: `NotificationHelper.instance.scheduleMedicineNotification()`
- Appointment reminders: `NotificationHelper.instance.reScheduleAppointmentNotification()` (called from medicine schedule)
- Both read from SQLite, cancel-all, then re-create. **Never schedule directly without going through the helper.**
- Android cap: 400 pending notifications. iOS cap: 45 (and 100 for appointments). Helper enforces these via `limit:` parameter — don't bypass.

### Timezone

Uses `package:timezone/timezone.dart` as `tz`. Convert `DateTime` → `tz.TZDateTime(tz.local, …)` before scheduling. Helper does this; if you schedule outside the helper (don't), you must too.

---

## Localization

GetX-based. The translation map lives in `lib/localization/localizations_delegate.dart` (`AppLanguages extends Translations`), pulling per-locale maps from `lib/localization/languages/language_<locale>.dart`.

### Adding a new string

1. Decide the key. Format: `txtCamelCase`. Be specific and avoid clashes (`txtTaken` exists; use `txtMarkAsTaken` if you need a separate verb).
2. Add to `lib/localization/languages/language_en.dart`:
   ```dart
   'txtMyNewKey': "My new English string",
   ```
3. **Add the same key to every other language file** with at minimum a placeholder English fallback. v1 expects all locales to have all keys present. Leaving a key missing in `language_ar.dart` causes the Arabic UI to render the raw key. The translation pipeline (Fiverr/Upwork native-fluent reviewer) takes the English fallback and replaces it.

### Using the string

```dart
CommonText(text: 'txtMyNewKey'.tr)        // GetX extension
Text('txtMyNewKey'.tr)
Utils.showToast(Get.context!, 'txtMyNewKey'.tr)
```

Hardcoded English strings in UI are bugs in this codebase.

---

## AdMob

`lib/google_ads/ad_helper.dart` — only place where unit IDs live. Gated by `Debug.googleAd`.

### Banner

Use `BannerAdClass()` from `lib/google_ads/custom_ad.dart` — already wraps logic for premium users (no ad if `Preference.shared.getIsPurchase()`).

```dart
const Align(alignment: Alignment.bottomCenter, child: BannerAdClass())
```

Don't inline a fresh `AdWidget` anywhere.

### Interstitial

Pattern lives in `lib/ui/home/home_controller.dart`. Counter-gated via `Preference.shared.getInterstitialAdCount()` and `Constant.interstitialCount` (= 5).

Only the home controller currently fires interstitials. **Don't add interstitial fires from other controllers without an explicit spec.** Frequency caps are global, not per-controller.

---

## In-app purchases

`lib/in_app_purchase/in_app_purchase_helper.dart` — `InAppPurchaseHelper()`.

- Product IDs: `Constant.productIdAndroid` / `Constant.productIdiOS` / `Constant.productIdiOSYearly`
- Premium check: `Preference.shared.getIsPurchase()` returns bool
- Gate code with `if (!Preference.shared.getIsPurchase()) { ... }`
- Use the existing `CommonSubscriptionDialog` widget (`lib/Widgets/common_subscribe_dialog.dart`) for paywall presentations — don't roll your own modal.

**Do not modify `in_app_purchase_helper.dart` substantively without a spec that calls out the IAP change.** Receipt validation logic in particular is touchy.

---

## Theming

- Always: `Get.theme.colorScheme.<role>` — never raw `Color(0xFF...)` in feature code.
- Available roles in current theme files (`lib/themes/light_theme.dart`, `dark_theme.dart`): `primary`, `onBackground`, `onPrimary`, `onTertiary`, `surfaceVariant`, `onSecondary`, `background`.
- New colors require an addition in **both** `light_theme.dart` and `dark_theme.dart`. v1 does not allow color use that only exists in one theme.

### Sizing

`lib/utils/sizer_utils.dart` exposes `AppSizes.height_2`, `AppSizes.fullWidth`, `AppFontSize.size_12`, etc. Use these. No magic numbers in widgets.

### Fonts

Four families registered in `pubspec.yaml`: Poppins, NunitoSans, LexendDeca, Righteous. New strings should pick from these — don't bring in new fonts for v1.

### Liquid Glass design system (added 2026-05-30)

iOS-style "liquid glass" surfaces are a shared, theme-driven system — **don't hand-roll `BackdropFilter` per screen.**

- **Tokens:** `lib/utils/glass_tokens.dart` (`GlassTokens`). All blur sigmas, tint/border/sheen opacities, radii, shadow, and motion (duration + curve) live here. **Only dimensionless / opacity tokens — never colours.** Colours always come from `Get.theme.colorScheme` at the call site, so glass adapts to light/dark automatically.
- **Primitive:** `lib/Widgets/glass/liquid_glass.dart` (`LiquidGlass`). The single frosted-panel building block (clip → `BackdropFilter` blur → theme-tinted translucent fill → edge highlight → optional sheen + shadow). Build every glass surface (bars, cards, dialogs) from this.
- **Bottom nav:** `lib/Widgets/glass/liquid_glass_bottom_nav.dart` (`LiquidGlassBottomNav` + `GlassNavItem`). Floating frosted bar with an animated "liquid" indicator and per-item ripple. It's a **pure presentation widget** — it owns no state; the parent passes `selectedIndex` + `onSelected`, so it drops over the existing GetX tab flow (`selectedTabIndex` / `onTabSelected`) without changing it. This is the pattern for adding glass without touching state management.
- **Ripple:** interactive glass uses `Material(color: Colors.transparent)` + `InkWell` with `splashColor`/`highlightColor` from `colorScheme.primary`. Don't use bare `GestureDetector` for tappable surfaces — every tap should ripple.
- **Note:** glass blur only visibly samples content when the surface overlays scrollable content (`Scaffold.extendBody` + per-screen bottom insets). In fixed slots it renders as a frosted translucent panel (tint + sheen + border + shadow) — still on-brand. Don't enable `extendBody` without giving each affected screen a bottom content inset, and don't let it cover the banner ad.

---

## Logging

```dart
import 'package:medinest/utils/debug.dart';
Debug.printLog("a useful message: $variable");
```

- Never `print(...)`.
- `Debug.googleAd`, `Debug.printLog`, etc. — flags in `lib/utils/debug.dart` gate testability.

---

## Toasts & dialogs

- Toast: `Utils.showToast(Get.context!, 'txtSomething'.tr);`
- Confirm dialog: see `CommonDeleteConfirmation` in `lib/Widgets/common_delete_conformation.dart`
- Subscribe paywall: `CommonSubscriptionDialog`
- Generic info: prefer adding a new common widget over inlining `showDialog`-spaghetti, but only if the same dialog will be reused 3+ places.

---

## Linter / formatter

- `analysis_options.yaml` is lenient. We don't enforce strict-mode null safety beyond Flutter defaults.
- Lints we follow without ceremony:
  - `prefer_const_constructors` — yes
  - Trailing commas in collection literals — yes
  - `dart format` is not enforced; match the surrounding file's style
- `flutter_lints: ^5.0.0` is on; warnings are tolerated, not errors.

---

## Logging-as-truth: things that already work

These are working patterns you can lean on:

- `Get.arguments` for passing data between screens
- `Get.back(result: ...)` for returning a value
- `Get.bottomSheet(...)` for the modals in `Widgets/common_*_dialog.dart`
- Connectivity check via `InternetConnectivity.isInternetConnect(Get.context!)`
- Image picker via `image_picker` package, wrapped in `Widgets/pick_form_dialog.dart`
- `lottie` for the splash and error states (already wired)

---

## What does NOT exist (don't reach for it)

- No GraphQL, no REST API client beyond `dio` (which is barely used)
- No analytics SDK in v1 (Firebase Analytics is *not* wired even though `firebase_core` is)
- No DI container beyond GetX `Bindings`
- No code-gen build_runner step (assets.dart is committed; nothing else is generated)
- No iOS-only code paths beyond what `Platform.isIOS` checks already handle

If a spec asks for any of these, the spec is wrong — flag it.
