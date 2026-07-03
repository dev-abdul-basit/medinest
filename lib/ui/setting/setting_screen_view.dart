import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button_with_image.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/ui/setting/setting_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

class SettingScreenPage extends StatelessWidget {
  const SettingScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingScreenLogic>(
        id: Constant.idSetting,
        builder: (logic) {
          return Scaffold(
              backgroundColor: Get.theme.colorScheme.onBackground,
              appBar: CommonAppBar(title: 'txtSettings'.tr),
              body: SafeArea(top: false, child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 35, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(!Preference.shared.getIsPurchase())CommonButtonWithImage(
                      onTap: () {
                        Get.toNamed(AppRoutes.proVersion);
                      },
                      icon: Assets.icons.icKing.path,
                      width: AppSizes.fullWidth - 50,
                      iconSize: AppSizes.width_9,
                      fontSize: AppFontSize.size_16,
                      text: "txtSubscribeNow".tr.toUpperCase(),
                    ),
                    SizedBox(
                      height: AppSizes.height_2,
                    ),
                    CommonText(
                        text: 'txtGeneral'.tr.toUpperCase(),
                        textColor: Get.theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.size_14),
                    SizedBox(
                      height: AppSizes.height_2,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surfaceVariant,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                            color: Get.theme.colorScheme.secondaryContainer
                                .withOpacity(0.2),
                            spreadRadius: 0.5,
                            blurRadius: 7,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Wrap(
                        children: [
                          menuItem(
                              icon: Assets.icons.icEditProfile.path,
                              text: "txtEditProfile".tr,
                              onTap: () {
                                logic.goToProfile();
                              }),
                          SizedBox(
                            height: AppSizes.height_6_5,
                          ),
                          menuItem(
                              icon: Assets.icons.icLanguages.path,
                              text: "txtChangeLanguages".tr,
                              isLast: true,
                              onTap: () {
                                logic.goToChangeLanguage();
                              }),
                          // F11 — caregiver mode toggle hidden until it has
                          // real functionality (no behaviour wired yet).
                          //TODO: 1:Uncomment to enable Dark/light theme
                          // SizedBox(
                          //   height: AppSizes.height_6_5,
                          // ),
                          // GetBuilder<SettingScreenLogic>(
                          //     id: Constant.idDarkThemSwitch,
                          //     builder: (logic) {
                          //       return menuItem(
                          //           icon: Assets.icons.icTheme.path,
                          //           text: "txtDarkTheme".tr,
                          //           isLast: true,
                          //           onTap: () {},
                          //           isSwitch: true,
                          //           switchValue: logic.isDarkTheme,
                          //           onChanged: (value) {
                          //             logic.onThemeChange(value);
                          //           });
                          //     })
                        ],
                      ),
                    ),
                    SizedBox(
                      height: AppSizes.height_2,
                    ),
                    CommonText(
                        text: 'txtSupportUs'.tr.toUpperCase(),
                        textColor: Get.theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.size_14),
                    SizedBox(
                      height: AppSizes.height_2,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surfaceVariant,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                            color: Get.theme.colorScheme.secondaryContainer
                                .withOpacity(0.2),
                            spreadRadius: 0.5,
                            blurRadius: 7,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Wrap(
                        children: [
                          menuItem(
                              icon: Assets.icons.icFeedback.path,
                              text: "txtSendUsFeedBack".tr,
                              onTap: () {
                                logic.onClickFeedback();
                              }),
                          SizedBox(
                            height: AppSizes.height_6_5,
                          ),
                          menuItem(
                              icon: Assets.icons.icRateUs.path,
                              text: "txtRateThisApp".tr,
                              onTap: () {
                                logic.onClickRateMyApp();
                              }),
                          SizedBox(
                            height: AppSizes.height_6_5,
                          ),
                          menuItem(
                              icon: Assets.icons.icTermsCondition.path,
                              text: "txtTermConditions".tr,
                              onTap: () {
                                Utils.urlLauncher(
                                    Constant.termsAndConditionURL);
                              }),
                          SizedBox(
                            height: AppSizes.height_6_5,
                          ),
                          menuItem(
                              icon: Assets.icons.icPrivacyPolicy.path,
                              text: "txtPrivacyPolicy".tr,
                              onTap: () {
                                Utils.urlLauncher(Constant.privacyPolicyURL);
                              }),
                          SizedBox(
                            height: AppSizes.height_6_5,
                          ),
                          menuItem(
                              icon: Assets.icons.icAboutus.path,
                              text: "txtAboutUs".tr,
                              onTap: () {
                                Utils.urlLauncher(Constant.aboutUsURL);
                              },
                              isLast: true),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: AppSizes.height_3,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: logic.isLoggedIn
                            ? Get.theme.colorScheme.onSecondary
                            : Get.theme.colorScheme.primary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                            color: Get.theme.colorScheme.secondaryContainer
                                .withOpacity(0.2),
                            spreadRadius: 0.5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                      // Signed-in users can log out (non-destructive — local data
                      // stays). Guests are offered sign-in to back up & sync.
                      child: logic.isLoggedIn
                          ? menuItem(
                              icon: Assets.icons.icLogout.path,
                              iConColor: Get.theme.colorScheme.inverseSurface,
                              text: "txtLogout".tr,
                              onTap: () {
                                logic.onTapSingOut();
                              },
                              isLast: true,
                              whiteText: true)
                          : menuItem(
                              icon: Assets.icons.icUserName.path,
                              iConColor: Get.theme.colorScheme.inverseSurface,
                              text: "txtSignInBackupTitle".tr,
                              onTap: () {
                                logic.signInToBackup(context);
                              },
                              isLast: true,
                              whiteText: true),
                    )
                  ],
                ),
              )));
        });
  }

  Widget menuItem(
      {required String icon,
      required String text,
      required Function() onTap,
      bool isLast = false,
      bool isSwitch = false,
      bool switchValue = false,
      bool whiteText = false,
      Color? iConColor,
      ValueChanged<bool>? onChanged}) {
    String lagType = Preference.shared.getString(Preference.selectedLanguage) ??
        Constant.languageEn;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                icon,
                color: iConColor??Get.theme.colorScheme.onSurface,
                width: AppSizes.height_2_5,
                height: AppSizes.height_2_5,
              ),
              SizedBox(
                width: AppSizes.width_5,
              ),
              Expanded(
                  child: CommonText(
                    text: text,
                fontWeight: FontWeight.w400,
                fontSize: AppFontSize.size_13,
                textColor: whiteText
                    ? Colors.white
                    : Get.theme.colorScheme.onPrimary,
              )),
              (isSwitch)
                  ? SizedBox(
                      height: AppSizes.height_2,
                      child: Switch(
                        value: switchValue,
                        onChanged: onChanged,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        overlayColor: MaterialStatePropertyAll<Color>(
                            Get.theme.colorScheme.onSecondary),
                        activeColor: Get.theme.colorScheme.onSecondary,
                        inactiveThumbColor: Get.theme.colorScheme.onSurface,
                        inactiveTrackColor:
                            Get.theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    )
                  : Transform.flip(
                      flipX:
                          lagType == 'ar' || lagType == 'ur' || lagType == 'fa',
                      child: Image.asset(
                        Assets.icons.icRightArrow.path,
                        width: AppSizes.height_3,
                        height: AppSizes.height_3,
                        color: whiteText ? Get.theme.colorScheme.error : null,
                      ),
                    ),
            ],
          ),
          if (!isLast) ...{
            SizedBox(
              height: AppSizes.height_1,
            ),
            Divider(
              color: Get.theme.colorScheme.surface.withOpacity(0.4),
            )
          }
        ],
      ),
    );
  }
}
