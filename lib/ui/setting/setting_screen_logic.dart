import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/ui/get_started_screen/get_started_screen_logic.dart';
import 'package:medinest/ui/home/home_controller.dart';

import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreenLogic extends GetxController {
  bool isDarkTheme = !Utils.isLightTheme();
  final InAppReview inAppReview = InAppReview.instance;

  /// F11 — caregiver mode (Stage 1: settings toggle only).
  bool caregiverMode = Preference.shared.getCaregiverMode();

  void onCaregiverModeChange(bool value) {
    caregiverMode = value;
    Preference.shared.setCaregiverMode(value);
    update([Constant.idSetting]);
  }

  onThemeChange(bool value) {
    isDarkTheme = value;
    Preference.shared.setAppTheme(
      isDarkTheme ? Constant.appThemeDark : Constant.appThemeLight,
    );
    Get.changeThemeMode(isDarkTheme ? ThemeMode.dark : ThemeMode.light);
    Future.delayed(const Duration(milliseconds: 200), () {
      update([Constant.idSetting]);
      Get.find<HomeController>().update([Constant.idHome]);
      Get.forceAppUpdate();
    });
  }

  goToProfile() {
    Get.toNamed(
      AppRoutes.addOrEditProfile,
      parameters: {Constant.idIsEditProfile: "true"},
    );
  }

  /// Whether the user is signed into a cloud account (vs. using the app as a
  /// local guest). Drives the account section in settings.
  bool get isLoggedIn => Preference.shared.getIsUserLogin();

  onTapSingOut() {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: Get.context!,
      builder: (context) => DeleteConformation(
        title: 'txtQLogOut'.tr,
        description: 'txtLogOutDescription'.tr,
        buttonText: 'txtLogOut'.tr,
        image: Utils.isLightTheme()
            ? Assets.icons.icLogoutImg.path
            : Assets.icons.icLogoutImgDark.path,
        imageHeight: AppSizes.height_21,
        imageWidth: AppSizes.height_21,
        onTapDelete: () {
          singOut(context);
        },
      ),
    );
    // Get.dialog(const SignOutDialog(), useSafeArea: false);
  }

  /// Sign out of the cloud account WITHOUT destroying local data.
  ///
  /// Local SQLite is the source of truth — the user keeps every medicine,
  /// reminder, family member and history entry, and can keep using the app as a
  /// guest or sign back in anytime. We only: push any unsynced data up first
  /// (best-effort backup), end the Firebase/Google session, and detach the
  /// account so a guest never reads or writes the previous account's cloud data.
  /// Reminders stay scheduled because the medicines stay on the device.
  singOut(context) async {
    try {
      // Best-effort: flush unsynced local data to the cloud before detaching.
      await Get.find<HomeController>().syncDataToFirebase();
      final FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signOut();
      await Get.put<GetStartedScreenLogic>(
        GetStartedScreenLogic(),
      ).logoutGoogle();
      // Become a guest: end the session and detach the cloud account. Keep
      // isGetStarted, the self profile, and ALL local data + notifications.
      Preference.shared.setIsUserLogin(false);
      await Preference.shared.remove(Preference.firebaseAuthUid);
      await Preference.shared.remove(Preference.firebaseEmail);
      Get.deleteAll(force: true);
      Get.offAllNamed(AppRoutes.getStarted);
      Utils.showToast(context, "toastLogOut".tr);
    } catch (e) {
      debugPrint(e.toString());
      Utils.showToast(context, e.toString());
    }
  }

  /// Guest → signed-in: sign in with Google to back up & sync. Local data is
  /// preserved and pushed to the account once signed in (handled by the login
  /// flow + home sync), so nothing is ever lost.
  signInToBackup(BuildContext context) async {
    await Get.put<GetStartedScreenLogic>(
      GetStartedScreenLogic(),
    ).loginWithGoogle(context);
  }

  goToChangeLanguage() {
    Get.toNamed(
      AppRoutes.changeLanguage,
      parameters: {Constant.idIsEditProfile: "true"},
    );
  }

  onClickRateMyApp() async {
    if (Platform.isIOS) {
      inAppReview.openStoreListing(appStoreId: Constant.appStoreIdentifier);
    } else {
      inAppReview.openStoreListing();
    }
  }

  onClickFeedback() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: Constant.emailPath,
      query: 'subject=Feedback MediNest',
    );

    var value = params.toString();
    var url = Uri.parse(value);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
