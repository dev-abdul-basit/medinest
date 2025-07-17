import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/text_form_field.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

import 'forgot_password_screen_logic.dart';

class ForgotPasswordScreenPage extends StatelessWidget {
  const ForgotPasswordScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ForgotPasswordScreenLogic>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Get.theme.colorScheme.onBackground,
          body: Form(
            key: logic.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: AppSizes.fullHeight /4,
                  width: AppSizes.fullWidth,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary,
                    borderRadius: const BorderRadiusDirectional.only(
                      bottomStart: Radius.circular(80),
                      bottomEnd: Radius.circular(80),
                    ),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: AppSizes.height_5,
                        ),
                        CommonText(
                            text: 'txtForgotPassword'.tr,
                            textColor: Get.theme.colorScheme.background,
                            fontWeight: FontWeight.w600,
                            fontSize: AppFontSize.size_22),
                        SizedBox(
                          height: AppSizes.height_2,
                        ),
                        CommonText(
                            text: 'txtEnterYourEmailVerification'.tr,
                            textColor: Get.theme.colorScheme.background,
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w300,
                            fontSize: AppFontSize.size_12),
                      ]),
                ),
                Expanded(
                  child: Container(
                    color: Get.theme.colorScheme.onBackground,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: AppSizes.height_0_8,
                            ),
                            GetBuilder<ForgotPasswordScreenLogic>(
                                id: Constant.idEmailInput,
                                builder: (logic) {
                                  return CommonTextFormFieldWithSuffix(
                                    shouldValidate: true,
                                    controller: logic.emailController,
                                    hintText: 'txtEnterYourEmail'.tr,
                                    fillColor: Get.theme.colorScheme.surfaceVariant,
                                    prefixIcon: Assets.iconsIcEmail,
                                    validatorType: Constant.validationTypeEmail,
                                    validatorText: 'txtEnterValidEmail'.tr,
                                  );
                                }),
                            SizedBox(
                              height: AppSizes.height_3,
                            ),
                            GetBuilder<ForgotPasswordScreenLogic>(builder: (logic) {
                              return CommonButton(
                                  onTap: () {
                                    logic.sendVerificationLink(context);
                                  },
                                  text: 'txtSendVerification'.tr);
                            }),
                            SizedBox(
                              height: AppSizes.height_3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CommonText(
                                    text: 'txtAlreadyHaveAnAccount'.tr,
                                    textColor: Get.theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w300,
                                    fontSize: AppFontSize.size_10),
                                SizedBox(width: AppSizes.height_0_5),
                                InkWell(
                                  onTap: ()=>Get.back(),
                                  child: CommonText(
                                      text: 'txtSignIn'.tr,
                                      textColor: Get.theme.colorScheme.onSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppFontSize.size_12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CommonText(
                        text: 'txtByContinueYouAgree'.tr,
                        textColor: Get.theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w300,
                        fontSize: AppFontSize.size_9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: ()=>Utils.urlLauncher(Constant.privacyPolicyURL),
                          child: CommonText(
                              text: 'txtTerms'.tr,
                              textColor: Get.theme.colorScheme.onSecondary,
                              fontWeight: FontWeight.w700,
                              textDecoration: TextDecoration.underline,
                              decorationColor: Get.theme.colorScheme.onSecondary,
                              fontSize: AppFontSize.size_10),
                        ),
                        CommonText(
                            text: ' & ',
                            textColor: Get.theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w300,
                            fontSize: AppFontSize.size_11),
                        InkWell(
                          onTap: ()=>Utils.urlLauncher(Constant.privacyPolicyURL),
                          child: CommonText(
                              text: 'txtPrivacy'.tr,
                              textColor: Get.theme.colorScheme.onSecondary,
                              fontWeight: FontWeight.w700,
                              textDecoration: TextDecoration.underline,
                              decorationColor: Get.theme.colorScheme.onSecondary,
                              fontSize: AppFontSize.size_10),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSizes.height_4,
                ),
              ],
            ),
          ),
        ),
        GetBuilder<ForgotPasswordScreenLogic>(
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
