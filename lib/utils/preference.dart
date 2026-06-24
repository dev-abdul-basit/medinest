import 'dart:async';

import 'package:get_storage/get_storage.dart';
import 'package:medinest/utils/constant.dart';


class Preference {
  static const String authorization = "AUTHORIZATION";

  static const String selectedLanguage = "LANGUAGE";
  static const String selectedCountryCode = "SELECTED_COUNTRY_CODE";
  static const String isSOUND = "SOUND";
  static const String isMusic = "Music";

  static const String isFirstTimeOpenApp = "IS_FIRST_TIME_OPEN_APP";
  static const String isUserLogin = "isUserLogin";
  static const String isGetStarted = "isGetStarted";
  static const String isIntroduction = "isIntroduction";
  static const String isProfileAdded = "isProfileAdded";
  static const String isRememberMe = "isRememberMe";
  static const String appTheme = "APP_THEME";
  static const String firebaseAuthUid = "FIREBASE_AUTH_UID";
  static const String firebaseEmail = "FIREBASE_AUTH_EMAIL";
  static const String isPurchasePremium = "IS_PURCHASE_PREMIUM";
  static const String interstitialAdCount = "INTERSTITIAL_AD_COUNT";
  static const String fcmToken  = "fcmToken";
  static const String notificationTimeStamp = "notificationTimeStamp";

  // F02 — review-prompt gating
  static const String dosesMarkedTaken   = "DOSES_MARKED_TAKEN";
  static const String lastReviewPromptTs = "LAST_REVIEW_PROMPT_TS";
  static const String firstInstallTs     = "FIRST_INSTALL_TS";
  static const String lastPaywallTs      = "LAST_PAYWALL_TS";

  // F08 — adherence card visibility
  static const String adherenceCardHidden = "ADHERENCE_CARD_HIDDEN";

  // F15 — engagement notification budget (guardrail for all non-medicine notifs)
  static const String lastEngagementNotifTs = "LAST_ENGAGEMENT_NOTIF_TS";
  static const String engagementWeekStartTs = "ENGAGEMENT_WEEK_START_TS";
  static const String engagementWeekCount   = "ENGAGEMENT_WEEK_COUNT";
  static const String lastOpenTs            = "LAST_OPEN_TS";

  // F18 — highest streak milestone already celebrated (so each fires once)
  static const String lastCelebratedMilestone = "LAST_CELEBRATED_MILESTONE";

  // F11 — caregiver mode
  static const String caregiverModeEnabled = "CAREGIVER_MODE_ENABLED";

  // F07 — onboarding (first-medicine in <60s)
  static const String seenFirstMedicineTooltip = "SEEN_FIRST_MEDICINE_TOOLTIP";
  static const String firstMedicineCreated     = "FIRST_MEDICINE_CREATED";

  // Self profile — fId of the implicit "Me" FamilyMemberTable row that owns the
  // current user's own medicines/appointments. Persisted so "self" is never
  // hardcoded to a brittle fId == 1 assumption.
  static const String selfMemberId = "SELF_MEMBER_ID";

  // The account (Firebase uid) that owns the current local data. Null = data was
  // created as a guest and is not yet claimed by any account. Used to isolate
  // accounts: when a DIFFERENT uid signs in, the local data is swapped for that
  // account's data (the previous owner's data stays safe in their own cloud).
  static const String dataOwnerUid = "DATA_OWNER_UID";




  /// ------------------ SINGLETON -----------------------
  static final Preference _preference = Preference._internal();

  factory Preference() {
    return _preference;
  }

  Preference._internal();

  static Preference get shared => _preference;

  static GetStorage? _pref;


  FutureOr<GetStorage?> instance() async {
    if (_pref != null) return _pref;
    await GetStorage.init().then((value) {
      if (value) {
        _pref = GetStorage();
      }
    }).catchError((onError) {
      _pref = null;
    });
    return _pref;
  }

  String? getString(String key) {
    return _pref!.read(key);
  }

  Future<void> setString(String key, String value) {
    return _pref!.write(key, value);
  }

  int? getInt(String key) {
    return _pref!.read(key);
  }

  Future<void> setInt(String key, int value) {
    return _pref!.write(key, value);
  }

  bool? getBool(String key) {
    return _pref!.read(key);
  }

  Future<void> setBool(String key, bool value) {
    return _pref!.write(key, value);
  }

  double? getDouble(String key) {
    return _pref!.read(key);
  }

  Future<void> setDouble(String key, double value) {
    return _pref!.write(key, value);
  }

  List<String>? getStringList(String key) {
    return _pref!.read(key);
  }

  Future<void> setStringList(String key, List<String> value) {
    return _pref!.write(key, value);
  }

  /// In app purchase
  Future<void> setIsPurchase(bool value) {
    return _pref!.write(isPurchasePremium, value);
  }

  bool getIsPurchase() {
    return _pref!.read(isPurchasePremium) ?? false;
  }

  /// google ad
  int getInterstitialAdCount() {
    return _pref!.read(interstitialAdCount) ?? 1;
  }
  Future<void> setInterstitialAdCount(int value) {
    return _pref!.write(interstitialAdCount, value);
  }


  ///IsUserLogin

  Future<void> setIsUserLogin(bool value) {
    return _pref!.write(isUserLogin, value);
  }

  bool getIsUserLogin() {
    return _pref!.read(isUserLogin) ?? false;
  }

  ///IsGetStarted

  Future<void> setIsGetStarted(bool value) {
    return _pref!.write(isGetStarted, value);
  }

  bool getIsGetStarted() {
    return _pref!.read(isGetStarted) ?? false;
  }

  ///IsIntroduction

  Future<void> setIsIntroduction(bool value) {
    return _pref!.write(isIntroduction, value);
  }

  bool getIsIntroduction() {
    return _pref!.read(isIntroduction) ?? false;
  }

  ///IsProfileAdded

  Future<void> setProfileAdded(bool value) {
    return _pref!.write(isProfileAdded, value);
  }

  bool getProfileAdded() {
    return _pref!.read(isProfileAdded) ?? false;
  }

  ///IsGetStarted

  Future<void> setIsRememberMe(bool value) {
    return _pref!.write(isRememberMe, value);
  }

  bool getIsRememberMe() {
    return _pref!.read(isRememberMe) ?? false;
  }
  /// App Theme
  Future<void> setAppTheme(String value) {
    return _pref!.write(appTheme, value);
  }

  String getAppTheme() {
    return _pref!.read(appTheme) ?? Constant.appThemeLight;
  }

///MedicineID

  int getLastNotificationTimeStamp() {
    return _pref!.read(notificationTimeStamp) ?? 1;
  }
  Future<void> setLastNotificationTimeStamp(int value) {
    return _pref!.write(notificationTimeStamp, value);
  }


  /// F02 — review-prompt gating accessors
  int getDosesMarkedTaken() => _pref!.read(dosesMarkedTaken) ?? 0;
  Future<void> setDosesMarkedTaken(int value) =>
      _pref!.write(dosesMarkedTaken, value);

  int getLastReviewPromptTs() => _pref!.read(lastReviewPromptTs) ?? 0;
  Future<void> setLastReviewPromptTs(int value) =>
      _pref!.write(lastReviewPromptTs, value);

  int getFirstInstallTs() => _pref!.read(firstInstallTs) ?? 0;
  Future<void> setFirstInstallTs(int value) =>
      _pref!.write(firstInstallTs, value);

  int getLastPaywallTs() => _pref!.read(lastPaywallTs) ?? 0;
  Future<void> setLastPaywallTs(int value) =>
      _pref!.write(lastPaywallTs, value);

  /// F08 — adherence card visibility
  bool getAdherenceCardHidden() =>
      _pref!.read(adherenceCardHidden) ?? false;
  Future<void> setAdherenceCardHidden(bool value) =>
      _pref!.write(adherenceCardHidden, value);

  /// F15 — engagement notification budget accessors
  int getLastEngagementNotifTs() => _pref!.read(lastEngagementNotifTs) ?? 0;
  Future<void> setLastEngagementNotifTs(int value) =>
      _pref!.write(lastEngagementNotifTs, value);

  int getEngagementWeekStartTs() => _pref!.read(engagementWeekStartTs) ?? 0;
  Future<void> setEngagementWeekStartTs(int value) =>
      _pref!.write(engagementWeekStartTs, value);

  int getEngagementWeekCount() => _pref!.read(engagementWeekCount) ?? 0;
  Future<void> setEngagementWeekCount(int value) =>
      _pref!.write(engagementWeekCount, value);

  int getLastOpenTs() => _pref!.read(lastOpenTs) ?? 0;
  Future<void> setLastOpenTs(int value) =>
      _pref!.write(lastOpenTs, value);

  /// F18 — streak milestone celebration
  int getLastCelebratedMilestone() => _pref!.read(lastCelebratedMilestone) ?? 0;
  Future<void> setLastCelebratedMilestone(int value) =>
      _pref!.write(lastCelebratedMilestone, value);

  /// F11 — caregiver mode
  bool getCaregiverMode() => _pref!.read(caregiverModeEnabled) ?? false;
  Future<void> setCaregiverMode(bool value) =>
      _pref!.write(caregiverModeEnabled, value);

  /// F07 — onboarding (first-medicine in <60s)
  bool getSeenFirstMedicineTooltip() =>
      _pref!.read(seenFirstMedicineTooltip) ?? false;
  Future<void> setSeenFirstMedicineTooltip(bool value) =>
      _pref!.write(seenFirstMedicineTooltip, value);

  bool getFirstMedicineCreated() => _pref!.read(firstMedicineCreated) ?? false;
  Future<void> setFirstMedicineCreated(bool value) =>
      _pref!.write(firstMedicineCreated, value);

  /// Self profile — fId of the "Me" family-member row. Null until resolved.
  int? getSelfMemberId() => _pref!.read(selfMemberId);
  Future<void> setSelfMemberId(int value) =>
      _pref!.write(selfMemberId, value);
  Future<void> clearSelfMemberId() => _pref!.remove(selfMemberId);

  /// Account that owns the current local data (null = unclaimed guest data).
  String? getDataOwnerUid() => _pref!.read(dataOwnerUid);
  Future<void> setDataOwnerUid(String value) =>
      _pref!.write(dataOwnerUid, value);
  Future<void> clearDataOwnerUid() => _pref!.remove(dataOwnerUid);

  Future<void> remove(key, [multi = false]) async {
    GetStorage? pref = await instance();
    if (multi) {
      key.forEach((f) async {
        return await pref!.remove(f);
      });
    } else {
      return await pref!.remove(key);
    }
  }


  static Future<bool> clear() async {
    _pref!.getKeys().forEach((key) async {
      await _pref!.remove(key);
    });

    return Future.value(true);
  }

  static Future<bool> clearLogout() async {
    return Future.value(true);
  }

}
