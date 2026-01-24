import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/custom_drop_down.dart';
import 'package:medinest/Widgets/text_form_field.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

import 'add_or_edit_profile_screen_logic.dart';

class AddOrEditProfileScreenPage extends StatelessWidget {
  const AddOrEditProfileScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<AddOrEditProfileScreenLogic>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Get.theme.colorScheme.background,
          appBar: CommonAppBar(title: 'txtProfile'.tr),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: AppSizes.height_5),
                Form(
                  key: logic.formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        GetBuilder<AddOrEditProfileScreenLogic>(
                          id: Constant.idUserNameInput,
                          builder: (logic) {
                            return CommonTextFormFieldWithSuffix(
                              controller: logic.userNameController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp("[a-z A-Z á-ú Á-Ú 0-9]"),
                                ),
                              ],
                              hintText: '${'txtEnterUserName'.tr} *',
                              fillColor: Get.theme.colorScheme.surfaceVariant,
                              prefixIcon: Assets.iconsIcUserName,
                              shouldValidate: true,
                              validatorText: 'txtEnterUserName'.tr,
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height_2_7),
                        GetBuilder<AddOrEditProfileScreenLogic>(
                          id: Constant.idSelectGender,
                          builder: (logic) {
                            return DropdownWithPrefix(
                              prefix: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: AppSizes.width_4,
                                  end: AppSizes.width_4,
                                ),
                                child: Image.asset(
                                  Assets.iconsIcGender,
                                  width: AppSizes.width_6,
                                  height: AppSizes.width_6,
                                ),
                              ),
                              items: Constant.genderList,
                              selectedItem: logic.selectedGender,
                              hintText: 'txtSelectGender'.tr,
                              onChanged: (value) {
                                logic.selectedGender = value;
                                logic.update([Constant.idSelectGender]);
                              },
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height_2_7),
                        GetBuilder<AddOrEditProfileScreenLogic>(
                          id: Constant.idUserBirthDateInput,
                          builder: (logic) {
                            return CommonTextFormFieldWithSuffix(
                              onTap: logic.selectBirthDate,
                              readOnly: true,
                              controller: logic.userBirthDateController,
                              hintText: 'txtEnterYourBirthDate'.tr,
                              fillColor: Get.theme.colorScheme.surfaceVariant,
                              prefixIcon: Assets.iconsIcCalendar,
                              validatorText: 'txtEnterYourBirthDate'.tr,
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height_2_7),
                        GetBuilder<AddOrEditProfileScreenLogic>(
                          id: Constant.idUserAgeInput,
                          builder: (logic) {
                            return CommonTextFormFieldWithSuffix(
                              onTap: logic.selectBirthDate,
                              readOnly: true,
                              controller: logic.userAgeController,
                              hintText: 'txtAge'.tr,
                              fillColor: Get.theme.colorScheme.surfaceVariant,
                              prefixIcon: Assets.iconsIcAge,
                              validatorText: 'txtEnterYourBirthDate'.tr,
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height_2_7),
                        GetBuilder<AddOrEditProfileScreenLogic>(
                          id: Constant.idSelectBloodGroup,
                          builder: (logic) {
                            return DropdownWithPrefix(
                              prefix: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: AppSizes.width_4,
                                  end: AppSizes.width_4,
                                ),
                                child: Image.asset(
                                  Assets.iconsIcBloodGroup,
                                  width: AppSizes.width_6,
                                  height: AppSizes.width_6,
                                ),
                              ),
                              items: Constant.bloodGroupList,
                              selectedItem: logic.selectedBloodGroup,
                              hintText: 'txtSelectBloodGroup'.tr,
                              onChanged: (value) {
                                logic.selectedBloodGroup = value;
                                logic.update([Constant.idSelectBloodGroup]);
                              },
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height_2_7),
                        GetBuilder<AddOrEditProfileScreenLogic>(
                          id: Constant.idUserEmail,
                          builder: (logic) {
                            return CommonTextFormFieldWithSuffix(
                              readOnly: true,
                              controller: logic.userEmailController,
                              hintText: 'txtEnterYourEmail'.tr,
                              validatorType: Constant.validationTypeEmail,
                              fillColor: Get.theme.colorScheme.surfaceVariant,
                              prefixIcon: Assets.iconsIcMessage,
                              validatorText: 'txtEnterYourEmail'.tr,
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height_2_7),
                        GetBuilder<AddOrEditProfileScreenLogic>(
                          id: Constant.idUserPhone,
                          builder: (logic) {
                            return CommonTextFormFieldWithSuffix(
                              controller: logic.userPhoneController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              hintText: 'txtEnterYourPhoneNumber'.tr,
                              // validatorType: Constant.validationTypePhone,
                              fillColor: Get.theme.colorScheme.surfaceVariant,
                              keyboardType: TextInputType.phone,
                              maxLength: 15,
                              prefixIcon: Assets.iconsIcPhone,
                              // validatorText: 'txtEnterValidPhoneNumber'.tr,
                            );
                          },
                        ),

                        SizedBox(height: AppSizes.height_8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CommonButtonOne(
                              onTap: () {
                                Get.back();
                              },
                              backgroundColor: Get.theme.colorScheme.background,
                              text: 'txtCancel'.tr,
                            ),
                            SizedBox(width: AppSizes.height_2),
                            CommonButtonOne(
                              onTap: () {
                                logic.submitData(context);
                              },
                              text: logic.isEdit
                                  ? 'txtUpdateNow'.tr
                                  : 'txtSave'.tr,
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.height_4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        GetBuilder<AddOrEditProfileScreenLogic>(
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
