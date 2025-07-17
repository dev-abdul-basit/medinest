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

import 'add_or_edit_appointment_logic.dart';

class AddOrEditAppointmentPage extends StatelessWidget {
  AddOrEditAppointmentPage({super.key});
  final logic = Get.find<AddOrEditAppointmentLogic>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<AddOrEditAppointmentLogic>(
            id: Constant.addAppointment,
            builder: (logic) {
              return Scaffold(
                backgroundColor: Get.theme.colorScheme.background,
                appBar: CommonAppBar(
                  title: logic.isEdit
                      ? 'txtUpdateAppointment'.tr
                      : 'txtCreateAppointment'.tr,
                ),
                body: SingleChildScrollView(
                  child: Form(
                    key: logic.formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: AppSizes.height_2,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              GetBuilder<AddOrEditAppointmentLogic>(
                                  id: Constant.idSelectMember,
                                  builder: (logic) {
                                    return DropdownWithPrefixSelectMember(
                                      prefix: Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: AppSizes.width_4_5,
                                            end: AppSizes.width_3_6),
                                        child: Image.asset(
                                            Assets.iconsIcUserName,
                                            width: AppSizes.width_5_5,
                                            height: AppSizes.width_5_5),
                                      ),
                                      familyMemberItems: logic.familyMembersList.reversed.toList()
                                          .where((element) =>
                                              element.mIsDeleted != 1)
                                          .toList(),
                                      selectedFamilyMemberItem:
                                          logic.selectedFamilyMembers,
                                      onChangedFamilyMember: (value) {
                                        logic.selectedFamilyMembers = value!;
                                        logic.update([Constant.idSelectMember]);
                                      },
                                    );
                                  }),
                              SizedBox(
                                width: AppSizes.width_2,
                              ),
                              InkWell(
                                onTap: () =>
                                    Get.find<AddOrEditAppointmentLogic>()
                                        .goToAddMember(),
                                child: Image.asset(
                                  Assets.iconsIcPlus,
                                  gaplessPlayback: true,
                                  height: AppSizes.width_10,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: AppSizes.height_0_5,
                          ),
                          Row(
                            children: [
                              CommonText(
                                  text: 'txtClick'.tr,
                                  textColor: Get.theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppFontSize.size_10),
                              CommonText(
                                  text: '+',
                                  textColor: Get.theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: AppFontSize.size_12),
                              CommonText(
                                  text: 'txtToAddMember'.tr,
                                  textColor: Get.theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppFontSize.size_10),
                            ],
                          ),
                          SizedBox(
                            height: AppSizes.height_2,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              GetBuilder<AddOrEditAppointmentLogic>(
                                  id: Constant.idSelectDoctor,
                                  builder: (logic) {
                                    return DropdownWithPrefixSelectDoctor(
                                      prefix: Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: AppSizes.width_4_5,
                                            end: AppSizes.width_3_6),
                                        child: Image.asset(
                                            Assets.iconsIcDoctorName,
                                            width: AppSizes.width_5_5,
                                            height: AppSizes.width_5_5),
                                      ),
                                      doctorsListItems: logic.doctorsList.reversed.toList(),
                                      selectedDoctorItem:
                                          logic.selectedDoctorItem,
                                      onChangedDoctor: (value) {
                                        logic.selectedDoctorItem = value!;
                                        logic.update([Constant.idSelectDoctor]);
                                      },
                                    );
                                  }),
                              SizedBox(
                                width: AppSizes.width_2,
                              ),
                              InkWell(
                                onTap: () =>
                                    Get.find<AddOrEditAppointmentLogic>()
                                        .goToAddDoctor(),
                                child: Image.asset(
                                  Assets.iconsIcPlus,
                                  gaplessPlayback: true,
                                  height: AppSizes.width_10,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: AppSizes.height_0_5,
                          ),
                          Row(
                            children: [
                              CommonText(
                                  text: 'txtClick'.tr,
                                  textColor: Get.theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppFontSize.size_10),
                              CommonText(
                                  text: '+',
                                  textColor: Get.theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: AppFontSize.size_12),
                              CommonText(
                                  text: 'txtToAddDoctor'.tr,
                                  textColor: Get.theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppFontSize.size_10),
                            ],
                          ),
                          SizedBox(
                            height: AppSizes.height_2,
                          ),
                          GetBuilder<AddOrEditAppointmentLogic>(
                              id: Constant.idSelectStartDate,
                              builder: (logic) {
                                return _settingItem(
                                  icon: Assets.iconsIcCalendar,
                                  text: '${"txtSelectDate".tr} *',
                                  onTap: logic.selectStartDate,
                                  defaultIcon: Assets.iconsIcDropdown,
                                  defaultText: logic.startDate != null
                                      ? DateFormat('d MMM, yyyy')
                                          .format(logic.startDate!)
                                      : null,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2,
                          ),
                          GetBuilder<AddOrEditAppointmentLogic>(
                              id: Constant.idSelectedTime,
                              builder: (logic) {
                                return _settingItem(
                                  icon: Assets.iconsIcWatch,
                                  text: '${"txtSelectTime".tr} *',
                                  defaultText:
                                      logic.tempSelectedTime?.format(context),
                                  onTap: () => logic.selectTime(context),
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2,
                          ),
                          if (Platform.isAndroid)
                            GetBuilder<AddOrEditAppointmentLogic>(
                                id: Constant.idSelectAlertSound,
                                builder: (logic) {
                                  return _settingItem(
                                    icon: Assets.iconsIcSound,
                                    text: '${"txtChooseSound".tr} *',
                                    defaultIcon: Assets.iconsIcRightArrow,
                                    onTap: logic.gotoSelectAlertSound,
                                    defaultText: logic.pickedSoundTitle,
                                  );
                                }),
                          if (Platform.isAndroid)
                            SizedBox(
                              height: AppSizes.height_2,
                            ),
                          GetBuilder<AddOrEditAppointmentLogic>(
                              id: Constant.idSelectMinutesBeforeTime,
                              builder: (logic) {
                                return DropdownWithPrefixMinutes(
                                  prefix: Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        start: AppSizes.width_4_6,
                                        end: AppSizes.width_3_2),
                                    child: Image.asset(Assets.iconsIcReminder,
                                        width: AppSizes.width_6,
                                        height: AppSizes.width_6),
                                  ),
                                  items: Constant.minutesList,
                                  selectedItem: logic.minutesChoose,
                                  onChanged: (value) {
                                    logic.minutesChoose = value!;
                                    logic.update(
                                        [Constant.idSelectMinutesBeforeTime]);
                                  },
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2,
                          ),
                          GetBuilder<AddOrEditAppointmentLogic>(
                              id: Constant.idUserComment,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  controller: logic.commentController,
                                  hintText: 'txtEnterDescription'.tr,
                                  fillColor:
                                      Get.theme.colorScheme.surfaceVariant,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 4,
                                  prefixIcon: Assets.iconsIcDescription,
                                  validatorText: 'txtEnterDescription'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CommonButtonOne(
                                  onTap: () {
                                    logic.clearData();
                                  },
                                  backgroundColor:
                                      Get.theme.colorScheme.background,
                                  text: 'txtReset'.tr),
                              SizedBox(
                                width: AppSizes.height_2,
                              ),
                              CommonButtonOne(
                                  onTap: () async {
                                    await logic.submitData(context);
                                    // logic.clearData();
                                  },
                                  text: logic.isEdit
                                      ? 'txtUpdateNow'.tr
                                      : 'txtSave'.tr),
                            ],
                          ),
                          SizedBox(
                            height: AppSizes.height_2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        GetBuilder<AddOrEditAppointmentLogic>(
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
    String lagType = Preference.shared.getString(Preference.selectedLanguage) ??
        Constant.languageEn;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: AppSizes.width_3_8, horizontal: 12),
        decoration: BoxDecoration(
            color: Get.theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(width: 1, color: Get.theme.colorScheme.surfaceTint)),
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.width_2,
            ),
            Image.asset(
              icon!,
              gaplessPlayback: true,
              height: AppSizes.width_5_5,
              width: AppSizes.width_5_5,
            ),
            SizedBox(
              width: AppSizes.width_3_2,
            ),
            Expanded(
              child: CommonText(
                  text: text!,
                  textColor: image != null || defaultText != null
                      ? Get.theme.colorScheme.primary
                      : Get.context!.theme.colorScheme.surface,
                  fontSize: AppFontSize.size_12,
                  fontWeight: FontWeight.w400,
                  fontFamily: Constant.fontFamilyNunitoSans),

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
                  fontFamily: Constant.fontFamilyNunitoSans),

              // Text(
              //   defaultText,
              //   style: AppFontStyle.styleW500(
              //     Get.context!.theme.primaryColor,
              //     AppFontSize.size_12,
              //   ),
              // ),
            },
            if (image != null) ...{
              Image.memory(image,
                  fit: BoxFit.cover,
                  height: AppSizes.width_7,
                  width: AppSizes.width_7)
            },
            if (color != null) ...{
              Container(
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                width: AppSizes.width_6,
                height: AppSizes.width_6,
              )
            },
            SizedBox(
              width: AppSizes.width_2,
            ),
            if (defaultIcon != null)
              Transform.flip(
                flipX: lagType == 'ar' || lagType == 'ur' || lagType == 'fa',
                child: Image.asset(
                  defaultIcon,
                  width: AppSizes.height_2,
                ),
              ),
            SizedBox(
              width: AppSizes.width_0_8,
            ),
          ],
        ),
      ),
    );
  }
}
