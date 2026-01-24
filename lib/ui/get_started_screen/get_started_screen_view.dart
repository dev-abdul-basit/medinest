import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/ui/get_started_screen/get_started_screen_logic.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';

import '../../Widgets/progress_dialog.dart';
import '../../utils/constant.dart';
import '../../utils/utils.dart';

class GetStartedScreenPage extends StatelessWidget {
  const GetStartedScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Get.theme.colorScheme.onBackground,
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: AppSizes.fullHeight / 1.6,
                    width: AppSizes.fullWidth,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary,
                      borderRadius: const BorderRadiusDirectional.only(
                        bottomStart: Radius.circular(80),
                        bottomEnd: Radius.circular(80),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: AppSizes.height_3_5),
                        Image.asset(
                          Assets.imagesGetStarted,
                          width: AppSizes.fullWidth / 1.55,
                          fit: BoxFit.cover,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: AppSizes.height_5_5),
                            CommonText(
                              text: 'txtWelcomeBack'.tr,
                              textColor: Get.theme.colorScheme.background,
                              fontWeight: FontWeight.w600,
                              fontSize: AppFontSize.size_28,
                            ),
                            SizedBox(height: AppSizes.height_1),
                            CommonText(
                              text: 'txtSigningToYourAccount'.tr,
                              textColor: Get.theme.colorScheme.background,
                              fontWeight: FontWeight.w300,
                              fontSize: AppFontSize.size_14,
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),

                  SizedBox(height: AppSizes.height_5),
                  CommonText(
                    text: 'Continue With Google'.tr,
                    textColor: Get.theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.size_20,
                  ),
                  SizedBox(height: AppSizes.height_2),
                  const SocialLogin(),

                  SizedBox(height: AppSizes.height_3),

                  SizedBox(height: AppSizes.height_6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CommonText(
                        text: 'txtByContinueYouAgree'.tr,
                        textColor: Get.theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w300,
                        fontSize: AppFontSize.size_12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () =>
                                Utils.urlLauncher(Constant.privacyPolicyURL),
                            child: CommonText(
                              text: 'txtTerms'.tr,
                              textColor: Get.theme.colorScheme.onSecondary,
                              fontWeight: FontWeight.w700,
                              textDecoration: TextDecoration.underline,
                              decorationColor: Get.theme.colorScheme.onSecondary,
                              fontSize: AppFontSize.size_13,
                            ),
                          ),
                          CommonText(
                            text: ' & ',
                            textColor: Get.theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w300,
                            fontSize: AppFontSize.size_12,
                          ),
                          InkWell(
                            onTap: () =>
                                Utils.urlLauncher(Constant.privacyPolicyURL),
                            child: CommonText(
                              text: 'txtPrivacy'.tr,
                              textColor: Get.theme.colorScheme.onSecondary,
                              fontWeight: FontWeight.w700,
                              textDecoration: TextDecoration.underline,
                              decorationColor: Get.theme.colorScheme.onSecondary,
                              fontSize: AppFontSize.size_13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        GetBuilder<GetStartedScreenLogic>(
          id: Constant.idProVersionProgress,
          builder: (logic) {
            return ProgressDialog(
              inAsyncCall: logic.isShowProgress,
              child: const SizedBox(),
            );
          },
        ),
      ],
    );
  }
}

class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GetStartedScreenLogic>(
      builder: (logic) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => logic.loginWithGoogle(context),
              child: Image.asset(
                Assets.imagesImgGoogle,
                height: AppSizes.height_7,
                width: AppSizes.height_7,
              ),
            ),
            if (Platform.isIOS) SizedBox(width: AppSizes.width_3),
            // if (Platform.isIOS)InkWell(
            //   onTap: ()=>logic.loginWithApple(context),
            //   child: Image.asset(Assets.imagesImgApple,
            //       height: AppSizes.height_7,
            //       width: AppSizes.height_7),
            // ),
          ],
        );
      },
    );
  }
}
