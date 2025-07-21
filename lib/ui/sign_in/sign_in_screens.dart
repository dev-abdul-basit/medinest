import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/text_form_field.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/ui/sign_in/sign_in_controller.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

class SignInScreen extends StatelessWidget {
  final SignInController controller = Get.put(SignInController());

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Get.theme.colorScheme.onBackground,
          body: Form(
            key: controller.formKey,
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
                          height: AppSizes.height_2_5,
                        ),
                        CommonText(
                            text: 'txtWelcomeBack'.tr,
                            textColor: Get.theme.colorScheme.background,
                            fontWeight: FontWeight.w600,
                            fontSize: AppFontSize.size_24),
                        SizedBox(
                          height: AppSizes.height_1,
                        ),
                        CommonText(
                            text: 'txtSigningToYourAccount'.tr,
                            textColor: Get.theme.colorScheme.background,
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
                              height: AppSizes.height_1,
                            ),
                            GetBuilder<SignInController>(
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
                            // const TextField(),
                            SizedBox(
                              height: AppSizes.height_2,
                            ),
                            GetBuilder<SignInController>(
                                id: Constant.idPasswordInput,
                                builder: (logic) {
                                  return CommonTextFormFieldWithSuffix(
                                    shouldValidate: true,
                                    controller: logic.passwordController,
                                    hintText: 'txtEnterYourPassword'.tr,
                                    validatorText: 'txtEnterValidPassword'.tr,
                                    validatorType: Constant.validationTypePassword,
                                    fillColor: Get.theme.colorScheme.surfaceVariant,
                                    obscureText: logic.isShowPassword,
                                    prefixIcon: Assets.iconsIcPassword,
                                    suffixIcon: logic.isShowPassword
                                        ? Assets.iconsIcShow
                                        : Assets.iconsIcHide,
                                    onTapSuffix: logic.toggleShowHidePassword,
                                  );
                                }),
                            SizedBox(
                              height: AppSizes.height_2,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: ()=>Get.toNamed(AppRoutes.forgotPassword),
                                child: CommonText(
                                    text: 'txtForgotPassword'.tr,
                                    textColor: Get.theme.colorScheme.onSecondary,
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppFontSize.size_12),
                              ),
                            ),
                            SizedBox(
                              height: AppSizes.height_6_6,
                            ),

                            GetBuilder<SignInController>(builder: (logic) {
                              return CommonButton(
                                  onTap: () {
                                    logic.login(context);
                                  },
                                  text: 'txtSignIn'.tr);
                            }),
                            SizedBox(
                              height: AppSizes.height_3,
                            ),
                            orDivider(),
                            SizedBox(
                              height: AppSizes.height_2_5,
                            ),
                            const SocialLogin(),
                            SizedBox(
                              height: AppSizes.height_3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CommonText(
                                    text: 'txtDontHaveAnAccount'.tr,
                                    textColor: Get.theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w300,
                                    fontSize: AppFontSize.size_11),
                                SizedBox(width: AppSizes.height_0_5),
                                InkWell(
                                  onTap: ()=>Get.offNamed(AppRoutes.signUp),
                                  child: CommonText(
                                      text: 'txtSignUp'.tr,
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
        GetBuilder<SignInController>(
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
  const SocialLogin({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInController>(builder: (logic) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => logic.loginWithGoogle(context),
            child: Image.asset(
                Assets.imagesImgGoogle,
                height: AppSizes.height_7,
                width: AppSizes.height_7),
          ),
          if (Platform.isIOS)SizedBox(
            width: AppSizes.width_3,
          ),
          // if (Platform.isIOS)InkWell(
          //   onTap: ()=>logic.loginWithApple(context),
          //   child: Image.asset(Assets.imagesImgApple,
          //       height: AppSizes.height_7,
          //       width: AppSizes.height_7),
          // ),
        ],
      );
    });
  }
}

Widget orDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    child: Row(
      children: [
        Flexible(
          child: Container(
            height: 1,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CommonText(
                text: 'txtOrContinueWith'.tr,
                textColor: Get.theme.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
                fontSize: AppFontSize.size_10)),
        Flexible(
          child: Container(
            height: 1,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
      ],
    ),
  );
}


