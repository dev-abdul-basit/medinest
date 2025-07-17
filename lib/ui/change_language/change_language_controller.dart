import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/localization/localizations_delegate.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/preference.dart';

class ChangeLanguageController extends GetxController {
  LanguageModel? languagesChosenValue;
  String? prefLanguageCode;
  String? prefCountryCode;

  @override
  void onInit() {
    getLanguageData();
    super.onInit();
  }

  getLanguageData() {
    prefLanguageCode = Preference.shared.getString(Preference.selectedLanguage) ?? 'en';
    prefCountryCode = Preference.shared.getString(Preference.selectedCountryCode) ?? 'US';
    languagesChosenValue =
        languages.where((element) => (element.languageCode == prefLanguageCode && element.countryCode == prefCountryCode)).toList()[0];
    update([Constant.idChangeLanguage]);
  }

  onLanguageSave() {
    Preference.shared.setString(Preference.selectedLanguage, languagesChosenValue!.languageCode);
    Preference.shared.setString(Preference.selectedCountryCode, languagesChosenValue!.countryCode);
    Get.updateLocale(Locale(languagesChosenValue!.languageCode, languagesChosenValue!.countryCode));
    Get.back();
  }

  onChangeLanguage(LanguageModel value) {
    languagesChosenValue = value;
    update([Constant.idChangeLanguage]);
  }
}
