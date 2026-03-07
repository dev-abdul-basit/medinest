import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/ui/pro_version/pro_version_controller.dart';
import 'package:medinest/utils/color.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/utils.dart';

import '../../utils/sizer_utils.dart';

class ProVersionScreen extends StatelessWidget {
  const ProVersionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      appBar: CommonAppBar(title: 'txtSubscription'.tr),
      body: SafeArea(
        top: false,
        bottom: true,
        child: GetBuilder<ProVersionController>(
          id: Constant.idProVersionProgress,
          builder: (logic) {
            return ProgressDialog(
              inAsyncCall: logic.isShowProgress,
              child: Column(
                children: [
                  SizedBox(
                    height: AppSizes.fullHeight / 1.44,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: AppSizes.height_3),

                          Image.asset(
                            Assets.imagesImgSuscription,
                            height: AppSizes.height_20,
                          ),
                          SizedBox(height: AppSizes.height_3),

                          // SizedBox(height: AppSizes.height_3),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     SizedBox(width: AppSizes.width_7),
                          //     Image.asset(
                          //       Assets.iconsIcDoneSubscription,
                          //       color: Get.theme.colorScheme.onPrimary,
                          //       height: AppSizes.height_2_5,
                          //     ),
                          //     SizedBox(width: AppSizes.width_3),
                          //     CommonText(
                          //         text: 'txtRemoveAds'.tr,
                          //         textColor: Get.theme.colorScheme.onPrimary,
                          //         fontWeight: FontWeight.w400,
                          //         fontSize: AppFontSize.size_12),
                          //   ],
                          // ),
                          // SizedBox(height: AppSizes.width_3),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     SizedBox(width: AppSizes.width_7),
                          //     Image.asset(
                          //       Assets.iconsIcDoneSubscription,
                          //       color: Get.theme.colorScheme.onPrimary,
                          //       height: AppSizes.height_2_5,
                          //     ),
                          //     SizedBox(width: AppSizes.width_3),
                          //     CommonText(
                          //         text: 'txtAddUnlimitedMedicines'.tr,
                          //         textColor: Get.theme.colorScheme.onPrimary,
                          //         fontWeight: FontWeight.w400,
                          //         fontSize: AppFontSize.size_12),
                          //   ],
                          // ),
                          // SizedBox(height: AppSizes.width_5
                          // ),
                          _accessAllFeatureButtonWidget(),
                        ],
                      ),
                    ),
                  ),
                  // _startButton(logic),
                  CommonButton(
                    onTap: () {
                      logic.onPurchaseClick();
                    },
                    backgroundColor: Get.theme.colorScheme.primary,
                    text: 'txtApplyNow'.tr,
                  ),
                  SizedBox(height: AppSizes.width_5),
                  CommonText(
                    text: 'txtCancelAnytime'.tr,
                    textColor: Get.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.size_11,
                  ),
                  SizedBox(height: AppSizes.width_3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Utils.urlLauncher(Constant.termsAndConditionURL);
                        },
                        child: CommonText(
                          text: 'txtTerms&Conditions'.tr,
                          textColor: Get.theme.colorScheme.onSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSize.size_11,
                        ),
                      ),
                      CommonText(
                        text: ' | ',
                        textColor: Get.theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.size_11,
                      ),
                      InkWell(
                        onTap: () {
                          Utils.urlLauncher(Constant.privacyPolicyURL);
                        },
                        child: CommonText(
                          text: 'txtPrivacy'.tr,
                          textColor: Get.theme.colorScheme.onSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSize.size_11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// COMPLETELY REDESIGNED: Premium gradient card with enhanced visual appeal
_accessAllFeatureButtonWidget() {
  return GetBuilder<ProVersionController>(
    id: Constant.idAccessAllFeaturesButtons,
    builder: (logic) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.width_6),
        child: InkWell(
          onTap: () {
            logic.onChangePlanSelection(Constant.boolValueTrue);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.width_5),
            decoration: BoxDecoration(
              // CHANGED: Added beautiful gradient background
              gradient: LinearGradient(
                colors: logic.isMonthlySelected
                    ? [AppColor.colorPrimaryLight, AppColor.colorSecondaryDark]
                    : [
                        Get.theme.colorScheme.background,
                        Get.theme.colorScheme.background,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              // CHANGED: Enhanced border styling
              border: Border.all(
                width: logic.isMonthlySelected ? 3 : 2,
                color: logic.isMonthlySelected
                    ? Colors.white.withOpacity(0.5)
                    : AppColor.txtColor999,
              ),
              // CHANGED: Added shadow for depth
              boxShadow: logic.isMonthlySelected
                  ? [
                      BoxShadow(
                        color: AppColor.colorSecondaryLight.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              children: [
                // ADDED: Premium badge at the top
                if (logic.isMonthlySelected)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.width_4,
                      vertical: AppSizes.height_0_5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColor.colorSecondaryDark,
                          size: AppSizes.height_2,
                        ),
                        SizedBox(width: AppSizes.width_1),
                        CommonText(
                          text: 'MOST POPULAR',
                          textColor: AppColor.colorSecondaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: AppFontSize.size_9,
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: AppSizes.height_2),

                // CHANGED: Enhanced plan name with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: logic.isMonthlySelected
                          ? Colors.white
                          : Get.theme.colorScheme.onSecondary,
                      size: AppSizes.height_3,
                    ),
                    SizedBox(width: AppSizes.width_2),
                    CommonText(
                      text: 'txtMonthly'.tr,
                      textColor: logic.isMonthlySelected
                          ? Colors.white
                          : Get.theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: AppFontSize.size_16,
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.height_1),

                // CHANGED: Larger, more prominent price display
                CommonText(
                  text:
                      "${logic.products.isEmpty ? '\$0.00' : logic.products.last.price}",
                  textColor: logic.isMonthlySelected
                      ? Colors.white
                      : Get.theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: AppFontSize.size_24,
                ),

                SizedBox(height: AppSizes.height_0_5),

                // CHANGED: Subtitle with better contrast
                CommonText(
                  text: "per month",
                  textColor: logic.isMonthlySelected
                      ? Colors.white.withOpacity(0.9)
                      : Get.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: AppFontSize.size_11,
                ),

                SizedBox(height: AppSizes.height_2),

                // ADDED: Feature highlights within the card
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizes.height_1_5,
                    horizontal: AppSizes.width_4,
                  ),
                  decoration: BoxDecoration(
                    color: logic.isMonthlySelected
                        ? Colors.white.withOpacity(0.2)
                        : Get.theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: logic.isMonthlySelected
                            ? Colors.white
                            : Get.theme.colorScheme.onSecondary,
                        size: AppSizes.height_2,
                      ),
                      SizedBox(width: AppSizes.width_2),
                      CommonText(
                        text: 'txtRemoveAds'.tr,
                        textColor: logic.isMonthlySelected
                            ? Colors.white
                            : Get.theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.size_14,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.height_2),

                // ADDED: Feature highlights within the card
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizes.height_1_5,
                    horizontal: AppSizes.width_4,
                  ),
                  decoration: BoxDecoration(
                    color: logic.isMonthlySelected
                        ? Colors.white.withOpacity(0.2)
                        : Get.theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: logic.isMonthlySelected
                            ? Colors.white
                            : Get.theme.colorScheme.onSecondary,
                        size: AppSizes.height_2,
                      ),
                      SizedBox(width: AppSizes.width_2),
                      CommonText(
                        text: 'txtAddUnlimitedMedicines'.tr,
                        textColor: logic.isMonthlySelected
                            ? Colors.white
                            : Get.theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.size_14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// _accessAllFeatureButtonWidget() {
//   return GetBuilder<ProVersionController>(
//     id: Constant.idAccessAllFeaturesButtons,
//     builder: (logic) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           InkWell(
//             onTap: () {
//               logic.onChangePlanSelection(Constant.boolValueTrue);
//             },
//             child: Stack(
//               alignment: Alignment.topCenter,
//               children: [
//                 Container(
//                   width: AppSizes.fullWidth / 2.5,
//                   height: AppSizes.height_15,
//                   margin: EdgeInsets.symmetric(vertical: AppSizes.width_3_5),
//                   decoration: BoxDecoration(
//                     color: Get.theme.colorScheme.background,
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(
//                         width: (logic.isMonthlySelected) ? 3 : 1,
//                         color: (logic.isMonthlySelected)
//                             ? AppColor.colorSecondaryLight
//                             : AppColor.txtColor999),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CommonText(
//                           text: 'txtMonthly'.tr,
//                           textColor: logic.isMonthlySelected
//                               ? Get.theme.colorScheme.onSecondary
//                               : Get.theme.colorScheme.onPrimary,
//                           fontWeight: logic.isMonthlySelected
//                               ? FontWeight.w700
//                               : FontWeight.w400,
//                           fontSize: AppFontSize.size_12),
//                       SizedBox(height: AppSizes.height_0_5),
//                       CommonText(
//                           text:
//                               "${logic.products.isEmpty ? 0 : logic.products.last.price} / month",
//                           // text: "${logic.products.where((element) => element.)} / month",
//                           textColor: logic.isMonthlySelected
//                               ? Get.theme.colorScheme.onSecondary
//                               : Get.theme.colorScheme.onSurface,
//                           fontWeight: FontWeight.w400,
//                           fontSize: AppFontSize.size_11),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // InkWell(
//           //   onTap: () {
//           //     logic.onChangePlanSelection(Constant.boolValueFalse);
//           //   },
//           //   child: Stack(
//           //     alignment: Alignment.topCenter,
//           //     children: [
//           //       Container(
//           //         width: AppSizes.fullWidth / 2.5,
//           //         height: AppSizes.height_15,
//           //         margin: EdgeInsets.symmetric(vertical: AppSizes.width_3_5),
//           //         decoration: BoxDecoration(
//           //           color: Get.theme.colorScheme.background,
//           //           borderRadius: BorderRadius.circular(15),
//           //           border: Border.all(
//           //               width: (!logic.isMonthlySelected) ? 3 : 1,
//           //               color: (!logic.isMonthlySelected)
//           //                   ? AppColor.colorSecondaryLight
//           //                   : AppColor.txtColor999),
//           //         ),
//           //         child: Column(
//           //           mainAxisAlignment: MainAxisAlignment.center,
//           //           children: [
//           //             CommonText(
//           //                 text: 'txtYearly'.tr,
//           //                 textColor: !logic.isMonthlySelected
//           //                     ? Get.theme.colorScheme.onSecondary
//           //                     : Get.theme.colorScheme.onPrimary,
//           //                 fontWeight: !logic.isMonthlySelected
//           //                     ? FontWeight.w700
//           //                     : FontWeight.w400,
//           //                 fontSize: AppFontSize.size_12),
//           //             SizedBox(height: AppSizes.height_0_5),
//           //             CommonText(
//           //                 text:
//           //                     "${logic.products.isEmpty ? 0 : logic.products.first.price} / Year",
//           //                 textColor: !logic.isMonthlySelected
//           //                     ? Get.theme.colorScheme.onSecondary
//           //                     : Get.theme.colorScheme.onPrimary,
//           //                 fontWeight: FontWeight.w400,
//           //                 fontSize: AppFontSize.size_11),
//           //           ],
//           //         ),
//           //       ),
//           //       Positioned(
//           //         top: 0,
//           //         child: Container(
//           //           height: AppSizes.height_3_5,
//           //           width: AppSizes.height_14,
//           //           alignment: Alignment.center,
//           //           decoration: BoxDecoration(
//           //               color: (!logic.isMonthlySelected)
//           //                   ? Get.theme.colorScheme.onSecondary
//           //                   : Get.theme.colorScheme.onSurface,
//           //               borderRadius: BorderRadius.circular(15),
//           //               border: Border.all(
//           //                   color: (!logic.isMonthlySelected)
//           //                       ? Get.theme.colorScheme.onSecondary
//           //                       : Get.theme.colorScheme.onSurface)),
//           //           child: CommonText(
//           //               text: '${'txtSave'.tr} 10%',
//           //               textColor: Get.theme.colorScheme.background,
//           //               fontWeight: FontWeight.w400,
//           //               fontSize: AppFontSize.size_10),
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//         ],
//       );
//     },
//   );
//
//
// }
