import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/main.dart';
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

  onTapSingOut() {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: Get.context!,
      builder: (context) => DeleteConformation(
        title: 'txtQLogOut'.tr,
        description: 'txtLogOutDescription'.tr,
        buttonText: 'txtLogOut'.tr,
        image: Utils.isLightTheme()
            ? Assets.iconsIcLogoutImg
            : Assets.iconsIcLogoutImgDark,
        imageHeight: AppSizes.height_21,
        imageWidth: AppSizes.height_21,
        onTapDelete: () {
          singOut(context);
        },
      ),
    );
    // Get.dialog(const SignOutDialog(), useSafeArea: false);
  }

  singOut(context) async {
    try {
      await Get.find<HomeController>().syncDataToFirebase();
      final FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signOut();
      await Get.put<GetStartedScreenLogic>(
        GetStartedScreenLogic(),
      ).logoutGoogle();
      Preference.shared.setIsUserLogin(false);
      Preference.shared.setProfileAdded(false);
      await DataBaseHelper.instance.deleteAppointmentNotificationData();
      await DataBaseHelper.instance.deleteAppointment();
      await DataBaseHelper.instance.deleteAppointmentHistory();
      await DataBaseHelper.instance.deleteMedicineData();
      await DataBaseHelper.instance.deleteMedicineHistory();
      await DataBaseHelper.instance.deleteNotificationData();
      await DataBaseHelper.instance.deleteFamilyMemberData();
      await DataBaseHelper.instance.deleteDoctor();
      await DataBaseHelper.instance.deleteUser();
      await flutterLocalNotificationsPlugin.cancelAll();
      Get.deleteAll(force: true);
      Get.offAllNamed(AppRoutes.getStarted);
      Utils.showToast(context, "toastLogOut".tr);
    } catch (e) {
      debugPrint(e.toString());
      Utils.showToast(context, e.toString());
    }
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
