import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/onboarding_illustrations.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'introduction_screen_logic.dart';

class IntroductionScreenPage extends StatelessWidget {
  IntroductionScreenPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Get.theme.colorScheme.onBackground,
        body: GetBuilder<IntroductionScreenLogic>(
            id: Constant.idPageView,
            builder: (logic) {
              return Stack(
                children: [
                  Container(
                    height: AppSizes.fullHeight / 1.7,
                    width: AppSizes.fullWidth,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary,
                      borderRadius: const BorderRadiusDirectional.only(
                        bottomStart: Radius.circular(80),
                        bottomEnd: Radius.circular(80),
                      ),
                    ),
                    child: SmoothPageIndicator(
                      controller: logic.pageController,
                      count: pagesImages.length,
                      effect: ExpandingDotsEffect(
                          activeDotColor: Get.theme.colorScheme.onSecondary,
                          dotColor: Get.theme.colorScheme.surface,
                          dotHeight: 5,
                          dotWidth: 5),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: AppSizes.height_15),
                    child: PageView.builder(
                      onPageChanged: logic.onPageChanged,
                      controller: logic.pageController,
                      itemCount: pagesImages.length,
                      itemBuilder: (_, index) {
                        return pagesImages[index % pagesImages.length];
                      },
                    ),
                  ),
                  Positioned(
                    bottom: AppSizes.height_5_8,
                    left: AppSizes.height_3,
                    right: AppSizes.height_3,
                    child: Column(
                      children: [
                        CommonButton(
                          onTap: logic.onTapNext,
                          text: 'Next'.toUpperCase(),
                        ),
                        SizedBox(height: AppSizes.height_5),
                        InkWell(
                          onTap: logic.onTapSkip,
                          child: CommonText(
                              text: 'Skip',
                              textColor: Get.theme.colorScheme.onSecondary,
                              textAlign: TextAlign.center,
                              fontSize: AppFontSize.size_14,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }));
  }

  final pagesImages = List.generate(3, (index) {
    // F07 — generated vector art (copyright-free, theme-aware) + MVP-correct,
    // de-medicalised copy. Slide 2 is the health journal, not "doctor visits".
    const List<OnboardArt> arts = [
      OnboardArt.pill,
      OnboardArt.journal,
      OnboardArt.family,
    ];
    List<String> listIntroText = [
      'txtKeepAllYourMedsInOnePlace'.tr,
      'txtOnboardJournalTitle'.tr,
      'txtSetProfilesForYourLovedOnes'.tr
    ];
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Column(
          children: [
            OnboardingIllustration(
              art: arts[index],
              size: AppSizes.fullWidth / 2.1,
            ),
            SizedBox(
              height: AppSizes.fullHeight / 3.9,
            ),
            CommonText(
              text: listIntroText[index],
              textColor: Get.theme.colorScheme.onPrimary,
              textAlign: TextAlign.center,
              fontSize: AppFontSize.size_23,
              fontWeight: FontWeight.w500,
            )
          ],
        ),
      ),
    );
  });
}
