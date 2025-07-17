import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/custom_drop_down.dart';
import 'package:medinest/Widgets/custom_drop_down_select_doctor.dart';
import 'package:medinest/Widgets/custom_drop_down_select_member.dart';
import 'package:medinest/Widgets/text_form_field.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/ui/add_medicine/add_medicine_controller.dart';
import 'package:medinest/utils/asset.dart';
import 'package:medinest/utils/color.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/font_style.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';

class AddMedicineScreen extends StatelessWidget {
  final AddMedicineController addMedicineController = Get.find<AddMedicineController>();

  AddMedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Get.theme.colorScheme.onBackground,
          appBar: CommonAppBar(title: addMedicineController.isEdit ? 'txtEditMedicine'.tr : 'txtAddMedicine'.tr),
          body: SingleChildScrollView(
            child: Form(
              key: addMedicineController.formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    CommonText(
                        text: 'txtMedicine'.tr, textColor: Get.theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: AppFontSize.size_18),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idUserNameInput,
                        builder: (logic) {
                          return CommonTextFormFieldWithSuffix(
                            controller: logic.medicineNameController,
                            hintText: '${'txtEnterMedicineName'.tr} *',
                            maxLength: 30,
                            fillColor: Get.theme.colorScheme.surfaceVariant,
                            prefixIcon: Assets.iconsIcMedicineName,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[a-z A-Z 0-9]")),
                            ],
                            validatorText: 'txtEnterMedicineName'.tr,
                          );
                        }),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idUserNameInput,
                        builder: (logic) {
                          return CommonTextFormFieldWithSuffix(
                            controller: logic.dosageController,
                            hintText: '${'txtAddDosage'.tr} *',
                            fillColor: Get.theme.colorScheme.surfaceVariant,
                            prefixIcon: Assets.iconsIcDosage,
                            keyboardType: TextInputType.number,
                            validatorText: 'txtAddDosage'.tr,
                          );
                        }),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idSelectUnit,
                        builder: (logic) {
                          return DropdownWithPrefix(
                            prefix: Padding(
                              padding:  EdgeInsetsDirectional.only(start: AppSizes.width_4,end: AppSizes.width_4),
                              child: Image.asset(Assets.iconsIcUnits, width: AppSizes.width_6, height: AppSizes.width_6),
                            ),
                            items: Constant.dosageDataList,
                            selectedItem: logic.dosageChoose,
                            hintText: '${'txtAddUnits'.tr} *',
                            onChanged: (value) {
                              logic.dosageChoose = value!;
                              logic.update([Constant.idSelectUnit]);
                            },
                          );
                        }),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idSelectedShape,
                        builder: (logic) {
                          return _settingItem(
                            icon: Assets.iconsIcShape,
                            text: logic.selectedShape != null ? logic.selectedShape!.shapeName : '${"txtSelectShape".tr} *',
                            onTap: () => logic.gotoSelectShape(context),
                            defaultIcon: Assets.iconsIcRightArrow,
                            image: logic.selectedShape?.shapeImage,
                          );
                        }),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idSelectedColor,
                        builder: (logic) {
                          return _settingItem(
                            icon: Assets.iconsIcColor,
                            text: '${"txtChooseColor".tr} *',
                            onTap: () => logic.gotoSelectColor(context),
                            defaultIcon: Assets.iconsIcRightArrow,
                            color: logic.shadeColor,
                          );
                        }),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idSelectBeforeOrAfterMeal,
                        builder: (logic) {
                          return DropdownWithPrefix(
                            prefix: Padding(
                              padding:  EdgeInsetsDirectional.only(start: AppSizes.width_5,end: AppSizes.width_4),
                              child: Image.asset(Assets.iconsIcMeal, width: AppSizes.width_5, height: AppSizes.width_5),
                            ),
                            items: Constant.beforeOrAfterMeal,
                            selectedItem: logic.beforeOrAfterMeal,
                            hintText: '${'txtSelectHowToTakeYourMedicine'.tr} *',
                            onChanged: (value) {
                              logic.beforeOrAfterMeal = value!;
                              logic.update([Constant.idSelectBeforeOrAfterMeal]);
                            },
                          );
                        }),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    CommonText(
                        text: 'txtSetReminders'.tr,
                        textColor: Get.theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.size_18),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idSelectStartDate,
                        builder: (logic) {
                          return _settingItem(
                            icon: Assets.iconsIcCalendar,
                            text: logic.startDate!=null?"txtStartDate".tr:'${'txtSelectStartDate'.tr} *',
                            onTap: logic.selectStartDate,
                            defaultIcon: Assets.iconsIcDropdown,
                            defaultText: logic.startDate!=null?DateFormat('d MMM, yyyy').format(logic.startDate!):null,
                          );
                        }),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idSelectEndDate,
                        builder: (logic) {
                          return _settingItem(
                            icon: Assets.iconsIcCalendar,
                            text: logic.endDate!=null?"txtEndDate".tr: '${'txtSelectEndDate'.tr} *',
                            isHint: logic.isNoEndDate,
                            onTap:  logic.isNoEndDate?null:logic.selectEndDateDate,
                            defaultIcon: Assets.iconsIcDropdown,
                            defaultText: logic.endDate!=null?DateFormat('d MMM, yyyy').format(logic.endDate!):null,
                          );
                        }),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idNoEndDate,
                        builder: (logic) {
                          return CheckboxListTile(
                            title: CommonText(
                                text: 'txtNoEndDate'.tr,
                                textColor: Get.theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w300,
                                fontSize: AppFontSize.size_10),
                            value: logic.isNoEndDate,
                            activeColor: Get.theme.colorScheme.onSecondary,
                            onChanged: (newValue) {
                              logic.isNoEndDate = newValue!;
                              logic.update([Constant.idNoEndDate, Constant.idSelectEndDate]);
                            },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.trailing, //  <-- leading Checkbox
                          );
                        }),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GetBuilder<AddMedicineController>(
                            id: Constant.idSelectedTime,
                            builder: (logic) {
                              return Expanded(
                                child: _settingItem(
                                  icon: Assets.iconsIcWatch,
                                  text: '${"txtSetTime".tr} *',
                                  defaultText: logic.tempSelectedTime?.format(context),
                                  onTap: () => logic.selectTime(context),
                                ),
                              );
                            }),
                        SizedBox(
                          width: AppSizes.width_2,
                        ),
                        InkWell(
                          onTap: () => Get.find<AddMedicineController>().addTimeToList(context),
                          child: Image.asset(
                            Assets.iconsIcPlus,
                            gaplessPlayback: true,
                            height: AppSizes.width_10,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: AppSizes.height_1,
                    ),
                    buildSelectedTimeList(),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idSelectedTime,
                        builder: (logic) {
                          return logic.selectedTimeList.isNotEmpty
                              ? SizedBox(
                                  height: AppSizes.height_1,
                                )
                              : SizedBox(
                            height: AppSizes.height_2_2,
                          );
                        }),
                    GetBuilder<AddMedicineController>(
                        id: Constant.idSelectFrequency,
                        builder: (logic) {
                          return _settingItem(
                            icon: AppAsset.icFrequency,
                            text: logic.frequency!=null?'txtFrequency'.tr: '${'txtSelectFrequency'.tr} *',
                            isHint: logic.frequency==null,
                            onTap: logic.selectFrequency,
                            defaultIcon: Assets.iconsIcRightArrow,
                            defaultText: logic.frequency,
                          );
                        }),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    if(Platform.isAndroid)GetBuilder<AddMedicineController>(
                        id: Constant.idSelectAlertSound,
                        builder: (logic) {
                          return _settingItem(
                            icon: Assets.iconsIcSound,
                            text: '${"txtChooseSound".tr} *',
                            isHint: logic.pickedSoundTitle==null,
                            defaultIcon: Assets.iconsIcRightArrow,
                            onTap: logic.gotoSelectAlertSound,
                            defaultText: logic.pickedSoundTitle,
                          );
                        }),
                    if(Platform.isAndroid)SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    CommonText(
                        text: 'txtAddMemberDoctor'.tr,
                        textColor: Get.theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.size_18),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GetBuilder<AddMedicineController>(
                            id: Constant.idSelectMember,
                            builder: (logic) {
                              return Expanded(
                                child: DropdownWithPrefixSelectMember(
                                  prefix: Padding(
                                    padding:  EdgeInsetsDirectional.only(start: AppSizes.width_4_5,end: AppSizes.width_4),
                                    child: Image.asset(Assets.iconsIcUserName, width: AppSizes.width_5_5, height: AppSizes.width_5_5),
                                  ),
                                  hintText: '${'txtSelectMember'.tr} *',
                                  familyMemberItems: logic.familyMembersList.reversed.toList().where((element) => element.mIsDeleted!=1).toList(),
                                  selectedFamilyMemberItem: logic.selectedFamilyMembers,
                                  onChangedFamilyMember: (value) {
                                    logic.selectedFamilyMembers = value!;
                                    logic.update([Constant.idSelectMember]);
                                  },
                                ),
                              );
                            }),
                        SizedBox(
                          width: AppSizes.width_2,
                        ),
                        InkWell(
                          onTap: () => Get.find<AddMedicineController>().goToAddMember(),
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
                            textColor: Get.theme.colorScheme.surface,
                            fontWeight: FontWeight.w400,
                            fontSize: AppFontSize.size_10),
                        CommonText(text: '+', textColor: Get.theme.colorScheme.onSecondary, fontWeight: FontWeight.w800, fontSize: AppFontSize.size_12),
                        CommonText(
                            text: 'txtToAddMember'.tr,
                            textColor: Get.theme.colorScheme.surface,
                            fontWeight: FontWeight.w400,
                            fontSize: AppFontSize.size_10),
                      ],
                    ),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GetBuilder<AddMedicineController>(
                            id: Constant.idSelectDoctor,
                            builder: (logic) {
                              return Expanded(
                                child: DropdownWithPrefixSelectDoctor(
                                  prefix: Padding(
                                    padding:  EdgeInsetsDirectional.only(start: AppSizes.width_5,end: AppSizes.width_4),
                                    child: Image.asset(Assets.iconsIcDoctorName, width: AppSizes.width_5_5, height: AppSizes.width_5_5),
                                  ),
                                  doctorsListItems: logic.doctorsList.reversed.toList(),
                                  selectedDoctorItem: logic.selectedDoctorItem,
                                  onChangedDoctor: (value) {
                                    logic.selectedDoctorItem = value!;
                                    logic.update([Constant.idSelectDoctor]);
                                  },
                                ),
                              );
                            }),
                        SizedBox(
                          width: AppSizes.width_2,
                        ),
                        InkWell(
                          onTap: () => Get.find<AddMedicineController>().goToAddDoctor(),
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
                            textColor: Get.theme.colorScheme.surface,
                            fontWeight: FontWeight.w400,
                            fontSize: AppFontSize.size_10),
                        CommonText(text: '+', textColor: Get.theme.colorScheme.onSecondary, fontWeight: FontWeight.w800, fontSize: AppFontSize.size_12),
                        CommonText(
                            text: 'txtToAddDoctor'.tr,
                            textColor: Get.theme.colorScheme.surface,
                            fontWeight: FontWeight.w400,
                            fontSize: AppFontSize.size_10),
                      ],
                    ),
                    GetBuilder<AddMedicineController>(
                        id: Constant.isUserActive,
                        builder: (logic) {
                          return Row(
                            children: [
                              CommonText(
                                  text: 'txtStatus'.tr,
                                  textColor: Get.theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppFontSize.size_12),
                              SizedBox(
                                width: AppSizes.width_1,
                              ),
                              Expanded(
                                child: CommonText(
                                    text: logic.isUserActive ? 'Active' : 'Suspend',
                                    textAlign: TextAlign.start,
                                    textColor: logic.isUserActive ? AppColor.colorGreen : AppColor.colorOrange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppFontSize.size_12),
                              ),
                              SizedBox(
                                width: AppSizes.width_5,
                              ),
                              Transform.scale(
                                scaleX :0.9,
                                scaleY :0.8,
                                child: Switch(
                                    overlayColor: MaterialStatePropertyAll<Color>(Get.theme.colorScheme.onSecondary),
                                    activeColor: Get.theme.colorScheme.onSecondary,
                                    inactiveThumbColor: Get.theme.colorScheme.onSurface,
                                    inactiveTrackColor:Get.theme.colorScheme.onSurface.withOpacity(0.5),
                                    value: logic.isUserActive,
                                    onChanged: logic.onChangedActiveStatus),
                              )
                            ],
                          );
                        }),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonButtonOne(
                            onTap: () {
                              Get.find<AddMedicineController>().clearData();
                            },
                            backgroundColor: Get.theme.colorScheme.background,
                            text: 'txtReset'.tr),
                        SizedBox(
                          width: AppSizes.height_2,
                        ),
                        CommonButtonOne(
                            onTap: () async {
                              if (Get.find<AddMedicineController>().isEdit) {
                                Get.find<AddMedicineController>().updateMedicineToDatabase(Get.context);
                              } else {
                                Get.find<AddMedicineController>().insertMedicineToDatabase(Get.context);
                              }
                            },
                            text: Get.find<AddMedicineController>().isEdit ? 'txtUpdateNow'.tr : 'txtSave'.tr),
                      ],
                    ),
                    SizedBox(
                      height: AppSizes.height_2_2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GetBuilder<AddMedicineController>(
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
    bool isHint = false,
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
        padding:  EdgeInsets.symmetric(vertical: AppSizes.width_3_8, horizontal: 12),
        decoration: BoxDecoration(color: Get.theme.colorScheme.surfaceVariant,borderRadius: BorderRadius.circular(10), border: Border.all(width: 1, color: Get.theme.colorScheme.surfaceTint)),
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
              child: Text(
                text!,
                style: AppFontStyle.styleW400(
                  color != null || image != null || defaultText != null
                      ? isHint?Get.context!.theme.colorScheme.surface:Get.context!.theme.colorScheme.primary
                      : Get.context!.theme.colorScheme.surface,
                  AppFontSize.size_11,
                ),
              ),
            ),
            if (defaultText != null) ...{
              CommonText(text: defaultText,textColor: isHint?Get.context!.theme.colorScheme.surface:Get.theme.colorScheme.primary ,fontSize: AppFontSize.size_12,fontWeight: FontWeight.w400,fontFamily: Constant.fontFamilyNunitoSans),
              // Text(
              //   defaultText,
              //   style: AppFontStyle.styleW500(
              //     isHint?Get.context!.theme.colorScheme.surface:Get.context!.theme.primaryColor,
              //     AppFontSize.size_12,
              //     fontWeight: FontWeight.w400,
              //   ),
              // ),
            },
            if (image != null) ...{Image.memory(image, fit: BoxFit.cover, height: AppSizes.width_7, width: AppSizes.width_7)},
            if (color != null) ...{
              Container(
                decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(Radius.circular(5))),
                width: AppSizes.width_6,
                height: AppSizes.width_6,
              )
            },
            SizedBox(
              width: AppSizes.width_2,
            ),
            if (defaultIcon != null)
              Transform.flip(
                flipX: lagType == 'ar' || lagType == 'ur'||  lagType == 'fa',
                child: Image.asset(
                  defaultIcon,
                  fit: BoxFit.contain,
                  width: AppSizes.height_2_6,
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

  Widget buildSelectedTimeList() {
    return GetBuilder<AddMedicineController>(
        id: Constant.idSelectedTime,
        builder: (logic) {
          return Wrap(
            spacing: 5,
            runSpacing: -5,
            children: List.generate(logic.selectedTimeList.length, (index) {
              final time = logic.selectedTimeList[index];
              return InputChip(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                labelPadding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                label: CommonText(
                    text: time.format(Get.context!),
                    textColor: Get.theme.colorScheme.background,
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.size_12),
                onSelected: (bool selected) {},
                backgroundColor: Get.theme.colorScheme.onSecondary,
                deleteIconColor: Colors.white,
                onDeleted: () {
                  Debug.printLog(":: onDeleted :::");
                  logic.deleteTimeFormList(index);
                },
              );
            }),
          );
        });
  }
}
