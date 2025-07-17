import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

class GetStartedScreenPage extends StatelessWidget {
  const GetStartedScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.onBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: AppSizes.fullHeight / 1.7,
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
              child: Image.asset(Assets.imagesGetStarted,
                  width: AppSizes.fullWidth / 1.55, fit: BoxFit.cover),
            ),
            SizedBox(height: AppSizes.height_5_5),
            CommonText(
                text: 'txtWellComeToYour'.tr,
                textColor: Get.theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
                fontSize: AppFontSize.size_23),
            Image.asset(Utils.isLightTheme()?Assets.imagesImgPillmodeLight:Assets.imagesImgPillmodeDark,width: AppSizes.fullWidth/2.9,),
            // Padding(
            //   padding: EdgeInsetsDirectional.fromSTEB(0,
            //        AppSizes.height_0_5,
            //        AppSizes.height_1,
            //        AppSizes.height_1),
            //   child: RichText(
            //     textAlign: TextAlign.center,
            //     text: TextSpan(
            //       children: <TextSpan>[
            //         TextSpan(
            //             text: 'P',
            //             style:AppFontStyle.styleBlackRighteous25_400),
            //         TextSpan(
            //             text: 'i',
            //             style: AppFontStyle.styleOrangeRighteous25_400),
            //         TextSpan(
            //             text: 'll',
            //             style: AppFontStyle.styleBlackRighteous25_400),
            //         TextSpan(
            //             text: 'Mode',
            //             style: AppFontStyle.styleOrangeRighteous25_400),
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(height: AppSizes.height_2_8),
            CommonButton(
              onTap: () {
                Preference.shared.setIsGetStarted(true);
                Get.offAllNamed(AppRoutes.signUp);
              },
              text: 'Get Started'.toUpperCase(),
            ),
            SizedBox(height: AppSizes.height_4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonText(
                    text: 'txtAlreadyHaveAnAccount'.tr,
                    textColor: Get.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w300,
                    fontSize: AppFontSize.size_11),
                SizedBox(width: AppSizes.height_0_5),
                InkWell(
                  onTap: () {
                    Preference.shared.setIsGetStarted(true);
                    Get.toNamed(AppRoutes.signIn);
                  },
                  child: CommonText(
                      text: 'txtSignIn'.tr,
                      textColor: Get.theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSize.size_12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
