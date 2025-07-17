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
