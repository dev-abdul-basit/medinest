import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/onboarding_illustrations.dart';
import 'package:medinest/utils/color.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

import 'first_medicine_logic.dart';

/// F07 — "Set your first medicine in under 60 seconds".
class FirstMedicineScreen extends StatelessWidget {
  const FirstMedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirstMedicineLogic logic = Get.find<FirstMedicineLogic>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Get.theme.colorScheme.onBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.width_6,
                AppSizes.height_3,
                AppSizes.width_6,
                AppSizes.height_3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: 'txtFirstMedNameLabel'.tr,
                    textColor: Get.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.size_14,
                  ),
                  SizedBox(height: AppSizes.height_1_2),
                  _nameField(logic),
                  SizedBox(height: AppSizes.height_3),
                  CommonText(
                    text: 'txtFirstMedHowOften'.tr,
                    textColor: Get.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.size_14,
                  ),
                  SizedBox(height: AppSizes.height_1_2),
                  GetBuilder<FirstMedicineLogic>(
                    id: Constant.idFirstMedicine,
                    builder: (l) => _frequencyChips(l),
                  ),
                  SizedBox(height: AppSizes.height_2_5),
                  GetBuilder<FirstMedicineLogic>(
                    id: Constant.idFirstMedicine,
                    builder: (l) => _reminderRow(l),
                  ),
                  SizedBox(height: AppSizes.height_1_5),
                  _moreOptions(logic),
                  SizedBox(height: AppSizes.height_4),
                  GetBuilder<FirstMedicineLogic>(
                    id: Constant.idFirstMedicine,
                    builder: (l) => _actions(context, l),
                  ),
                  SizedBox(height: AppSizes.height_2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- Blue header panel with generated illustration ----------------------
  Widget _header() {
    return Container(
      width: AppSizes.fullWidth,
      padding: EdgeInsets.fromLTRB(
        AppSizes.width_6,
        AppSizes.height_7,
        AppSizes.width_6,
        AppSizes.height_4,
      ),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary,
        borderRadius: const BorderRadiusDirectional.only(
          bottomStart: Radius.circular(60),
          bottomEnd: Radius.circular(60),
        ),
      ),
      child: Column(
        children: [
          OnboardingIllustration(
            art: OnboardArt.pill,
            size: AppSizes.fullWidth / 2.6,
          ),
          SizedBox(height: AppSizes.height_2_5),
          CommonText(
            text: 'txtFirstMedTitle'.tr,
            textColor: AppColor.white,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            fontSize: AppFontSize.size_24,
          ),
          SizedBox(height: AppSizes.height_1),
          CommonText(
            text: 'txtFirstMedSubtitle'.tr,
            textColor: AppColor.white,
            textAlign: TextAlign.center,
            maxLines: 2,
            fontWeight: FontWeight.w300,
            fontSize: AppFontSize.size_13,
          ),
        ],
      ),
    );
  }

  Widget _nameField(FirstMedicineLogic logic) {
    return TextField(
      controller: logic.nameController,
      focusNode: logic.nameFocus,
      autofocus: true,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        fontFamily: Constant.fontFamilyLexendDeca,
        color: Get.theme.colorScheme.onSurface,
        fontSize: AppFontSize.size_16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'txtFirstMedNamePlaceholder'.tr,
        hintStyle: TextStyle(
          fontFamily: Constant.fontFamilyLexendDeca,
          color: AppColor.txtColor999,
          fontSize: AppFontSize.size_15,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor:
            Utils.isLightTheme() ? AppColor.grayLight : AppColor.colorDarkCard,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.width_4,
          vertical: AppSizes.height_2,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Get.theme.colorScheme.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _frequencyChips(FirstMedicineLogic logic) {
    final List<String> labels = [
      'txtFirstMedFrequencyOnce'.tr,
      'txtFirstMedFrequencyTwice'.tr,
      'txtFirstMedFrequencyThrice'.tr,
    ];
    return Row(
      children: List.generate(labels.length, (i) {
        final bool selected = logic.selectedFrequency == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: i < labels.length - 1 ? AppSizes.width_2_5 : 0,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => logic.selectFrequency(i),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: AppSizes.height_1_8),
                decoration: BoxDecoration(
                  color: selected
                      ? Get.theme.colorScheme.primary
                      : (Utils.isLightTheme()
                          ? AppColor.grayLight
                          : AppColor.colorDarkCard),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? Get.theme.colorScheme.primary
                        : AppColor.txtLightGray,
                  ),
                ),
                child: CommonText(
                  text: labels[i],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  textColor: selected
                      ? AppColor.white
                      : Get.theme.colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: AppFontSize.size_12,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _reminderRow(FirstMedicineLogic logic) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.width_4,
        vertical: AppSizes.height_1_8,
      ),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: Get.theme.colorScheme.primary,
            size: AppFontSize.size_20,
          ),
          SizedBox(width: AppSizes.width_3),
          Expanded(
            child: CommonText(
              text: '${'txtFirstMedNextReminder'.tr}: ${logic.reminderTimesLabel}',
              textColor: Get.theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              maxLines: 2,
              fontSize: AppFontSize.size_13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moreOptions(FirstMedicineLogic logic) {
    return InkWell(
      onTap: logic.openMoreOptions,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.height_0_5),
        child: CommonText(
          text: 'txtFirstMedMoreOptions'.tr,
          textColor: Get.theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
          textDecoration: TextDecoration.underline,
          decorationColor: Get.theme.colorScheme.primary,
          fontSize: AppFontSize.size_12,
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, FirstMedicineLogic logic) {
    return Column(
      children: [
        Center(
          child: CommonButton(
            onTap: logic.isSaving ? () {} : () => logic.saveFirstMedicine(context),
            text: (logic.isSaving
                    ? 'txtPleaseWait'
                    : 'txtFirstMedSaveCta')
                .tr,
          ),
        ),
        SizedBox(height: AppSizes.height_2),
        InkWell(
          onTap: logic.skipForNow,
          child: CommonText(
            text: 'txtFirstMedLater'.tr,
            textColor: AppColor.gray,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
            fontSize: AppFontSize.size_13,
          ),
        ),
      ],
    );
  }
}
