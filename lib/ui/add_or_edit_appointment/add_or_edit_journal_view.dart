import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/custom_drop_down_minutes.dart';
import 'package:medinest/Widgets/custom_drop_down_select_doctor.dart';
import 'package:medinest/Widgets/custom_drop_down_select_member.dart';
import 'package:medinest/Widgets/text_form_field.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';

import 'add_or_edit_journal_logic.dart';

class AddOrEditAppointmentPage extends StatelessWidget {
  AddOrEditAppointmentPage({super.key});

  final logic = Get.find<AddOrEditJournalLogic>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<AddOrEditJournalLogic>(
          id: Constant.addAppointment,
          builder: (logic) {
            return Scaffold(
              backgroundColor: Get.theme.colorScheme.background,
              appBar: CommonAppBar(
                title: logic.isEdit
                    ? 'txtUpdateJournal'.tr
                    : 'txtCreateJournal'.tr,
              ),
              body: SingleChildScrollView(
                child: Form(
                  key: logic.formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: AppSizes.height_3),

                        GetBuilder<AddOrEditJournalLogic>(
                          id: Constant.idAppointmentTitle,
                          builder: (logic) {
                            return CommonTextFormFieldWithSuffix(
                              controller: logic.titleController,
                              hintText: 'Enter Title'.tr,
                              fillColor: Get.theme.colorScheme.surfaceVariant,
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                              prefixIcon: Assets.iconsIcEdit,
                              validatorText: 'Enter Title'.tr,
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height_3),

                        GetBuilder<AddOrEditJournalLogic>(
                          id: Constant.idUserComment,
                          builder: (logic) {
                            return CommonTextFormFieldWithSuffix(
                              controller: logic.commentController,
                              hintText: 'txtEnterDescription'.tr,
                              fillColor: Get.theme.colorScheme.surfaceVariant,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              prefixIcon: Assets.iconsIcDescription,
                              validatorText: 'txtEnterDescription'.tr,
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height_5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CommonButtonOne(
                              onTap: () {
                                logic.clearData();
                              },
                              backgroundColor: Get.theme.colorScheme.background,
                              text: 'txtReset'.tr,
                            ),
                            SizedBox(width: AppSizes.height_2),
                            CommonButtonOne(
                              onTap: () async {
                                await logic.submitData(context);
                                // logic.clearData();
                              },
                              text: logic.isEdit
                                  ? 'txtUpdateNow'.tr
                                  : 'txtSave'.tr,
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.height_2),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        GetBuilder<AddOrEditJournalLogic>(
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

  _settingItem({
    String? icon,
    String? text,
    String? defaultText,
    String? defaultIcon,
    Uint8List? image,
    Color? color,
    Function()? onTap,
  }) {
    String lagType =
        Preference.shared.getString(Preference.selectedLanguage) ??
        Constant.languageEn;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.width_3_8,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: Get.theme.colorScheme.surfaceTint,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: AppSizes.width_2),
            Image.asset(
              icon!,
              gaplessPlayback: true,
              height: AppSizes.width_5_5,
              width: AppSizes.width_5_5,
            ),
            SizedBox(width: AppSizes.width_3_2),
            Expanded(
              child: CommonText(
                text: text!,
                textColor: image != null || defaultText != null
                    ? Get.theme.colorScheme.primary
                    : Get.context!.theme.colorScheme.surface,
                fontSize: AppFontSize.size_12,
                fontWeight: FontWeight.w400,
                fontFamily: Constant.fontFamilyNunitoSans,
              ),

              // Text(
              //   text!,
              //   style: AppFontStyle.styleW500(
              //     color != null || image != null || defaultText != null
              //         ? Get.context!.theme.colorScheme.primary
              //         : Get.context!.theme.colorScheme.surface,
              //     AppFontSize.size_11,
              //   ),
              // ),
            ),
            if (defaultText != null) ...{
              CommonText(
                text: defaultText,
                textColor: Get.theme.colorScheme.primary,
                fontSize: AppFontSize.size_12,
                fontWeight: FontWeight.w400,
                fontFamily: Constant.fontFamilyNunitoSans,
              ),

              // Text(
              //   defaultText,
              //   style: AppFontStyle.styleW500(
              //     Get.context!.theme.primaryColor,
              //     AppFontSize.size_12,
              //   ),
              // ),
            },
            if (image != null) ...{
              Image.memory(
                image,
                fit: BoxFit.cover,
                height: AppSizes.width_7,
                width: AppSizes.width_7,
              ),
            },
            if (color != null) ...{
              Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                width: AppSizes.width_6,
                height: AppSizes.width_6,
              ),
            },
            SizedBox(width: AppSizes.width_2),
            if (defaultIcon != null)
              Transform.flip(
                flipX: lagType == 'ar' || lagType == 'ur' || lagType == 'fa',
                child: Image.asset(defaultIcon, width: AppSizes.height_2),
              ),
            SizedBox(width: AppSizes.width_0_8),
          ],
        ),
      ),
    );
  }
}
