import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/utils/preference.dart';

class IntroductionScreenLogic extends GetxController {
  final pageController = PageController(viewportFraction: 1.0, keepPage: true);
  int currantPageIndex = 0;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void onPageChanged(int value) {
    currantPageIndex = value;
  }

  void onTapNext() {
    if (currantPageIndex == 2) {
      Preference.shared.setIsIntroduction(true);
      Get.offNamed(AppRoutes.getStarted);
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    }
  }

  void onTapSkip() {
    Preference.shared.setIsIntroduction(true);
    Get.offNamed(AppRoutes.getStarted);
  }
}
