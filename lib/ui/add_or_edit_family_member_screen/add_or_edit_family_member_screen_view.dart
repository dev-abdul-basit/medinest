import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/member_avatar.dart';
import 'package:medinest/Widgets/custom_drop_down.dart';
import 'package:medinest/Widgets/text_form_field.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

import 'add_or_edit_family_member_screen_logic.dart';

class AddOrEditFamilyMemberScreenPage extends StatelessWidget {
  const AddOrEditFamilyMemberScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<AddOrEditFamilyMemberScreenLogic>();

    return Stack(
      children: [
        Scaffold(
            backgroundColor: Get.theme.colorScheme.background,
            appBar: CommonAppBar(title: 'txtAddFamilyMember'.tr),
            body: SafeArea(top: false, child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: AppSizes.height_2_5,
                  ),
                  GetBuilder<AddOrEditFamilyMemberScreenLogic>(
                    id: Constant.idProfilePhoto,
                    builder: (logic) => _avatarSection(logic),
                  ),
                  SizedBox(height: AppSizes.height_2),
                  // Stack(
                  //   children: [
                  //     GetBuilder<AddOrEditFamilyMemberScreenLogic>(
                  //         id: Constant.idProfilePhoto,
                  //         builder: (logic) {
                  //           return Container(
                  //             width: AppSizes.height_20,
                  //             height: AppSizes.height_20,
                  //             padding:  EdgeInsets.all(logic.profileUrl != null?0:50),
                  //             margin: const EdgeInsets.all(25),
                  //             decoration: BoxDecoration(
                  //                 shape: BoxShape.circle,
                  //                 image: logic.pickedNewFile != null
                  //                     ? DecorationImage(
                  //                         fit: BoxFit.cover,
                  //                         image: FileImage(
                  //                             File(logic.pickedNewFile!.path)))
                  //                     : null,
                  //                 color: Get.theme.colorScheme.primary),
                  //             child: logic.profileUrl != null
                  //                 ? CachedNetworkImage(
                  //                     imageUrl: logic.profileUrl!,
                  //                     imageBuilder: (context, imageProvider) =>
                  //                         Container(
                  //                       decoration: BoxDecoration(
                  //                         shape: BoxShape.circle,
                  //                         image: DecorationImage(
                  //                             image: imageProvider,
                  //                             fit: BoxFit.cover),
                  //                       ),
                  //                     ),
                  //                     placeholder: (context, url) =>
                  //                         Image.asset(
                  //                       Assets.icons.icUserName.path,
                  //                       color: Colors.white,
                  //                     ),
                  //                     errorWidget: (context, url, error) =>
                  //                         Image.asset(
                  //                       Assets.icons.icUserName.path,
                  //                       color: Colors.white,
                  //                     ),
                  //                   )
                  //                 : logic.pickedNewFile != null?const SizedBox():Image.asset(
                  //                     Assets.icons.icUserName.path,
                  //                     color: Colors.white,
                  //                   ),
                  //           );
                  //         }),
                  //     PositionedDirectional(
                  //       bottom: 1,
                  //       end: 1,
                  //       child: InkWell(
                  //         onTap: () => logic.openImagePickerDialog(),
                  //         child: Container(
                  //           width: AppSizes.height_5_5,
                  //           height: AppSizes.height_5_5,
                  //           padding: const EdgeInsets.all(11),
                  //           margin: const EdgeInsets.all(26),
                  //           decoration: BoxDecoration(
                  //               border: Border.all(
                  //                   color: Get.theme.colorScheme.background,
                  //                   width: 4),
                  //               shape: BoxShape.circle,
                  //               color: Get.theme.colorScheme.onSecondary),
                  //           child: Image.asset(Assets.icons.icEditPhoto.path,
                  //               color: Colors.white),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Form(
                    key: logic.formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      child: Column(
                        children: [
                          GetBuilder<AddOrEditFamilyMemberScreenLogic>(
                              id: Constant.idUserNameInput,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  controller: logic.userNameController,
                                  maxLength: 30,
                                  hintText: '${'txtEnterMemberName'.tr} *',
                                  fillColor:
                                  Get.theme.colorScheme.surfaceVariant,
                                  shouldValidate: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[a-z A-Z .]")),
                                  ],
                                  // inputFormatters: [
                                  //   FilteringTextInputFormatter.allow(RegExp("[a-z A-Z .]")),
                                  // ],
                                  prefixIcon: Assets.icons.icUserName.path,
                                  validatorText: 'txtEnterMemberName'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_2,
                          ),
                          GetBuilder<AddOrEditFamilyMemberScreenLogic>(
                              id: Constant.idSelectGender,
                              builder: (logic) {
                                return DropdownWithPrefix(
                                  prefix: Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        start: AppSizes.width_4_5,
                                        end: AppSizes.width_3_6),
                                    child: Image.asset(Assets.icons.icGender.path,
                                        width: AppSizes.width_6,
                                        height: AppSizes.width_6),
                                  ),
                                  items: Constant.genderList,
                                  selectedItem: logic.selectedGender,
                                  hintText: 'txtSelectGender'.tr,
                                  onChanged: (value) {
                                    logic.selectedGender = value;
                                    logic.update([Constant.idSelectGender]);
                                  },
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_2,
                          ),
                          GetBuilder<AddOrEditFamilyMemberScreenLogic>(
                              id: Constant.idUserBirthDateInput,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  onTap: logic.selectBirthDate,
                                  readOnly: true,
                                  controller: logic.userBirthDateController,
                                  hintText: 'txtEnterBirthDate'.tr,
                                  fillColor:
                                  Get.theme.colorScheme.surfaceVariant,
                                  prefixIcon: Assets.icons.icCalendar.path,
                                  validatorText: 'txtEnterBirthDate'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_2,
                          ),
                          GetBuilder<AddOrEditFamilyMemberScreenLogic>(
                              id: Constant.idUserAgeInput,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  onTap: logic.selectBirthDate,
                                  readOnly: true,
                                  controller: logic.userAgeController,
                                  hintText: 'txtAge'.tr,
                                  fillColor:
                                  Get.theme.colorScheme.surfaceVariant,
                                  prefixIcon: Assets.icons.icAge.path,
                                  validatorText: 'txtEnterBirthDate'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_2,
                          ),
                          GetBuilder<AddOrEditFamilyMemberScreenLogic>(
                              id: Constant.idSelectBloodGroup,
                              builder: (logic) {
                                return DropdownWithPrefix(
                                  prefix: Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        start: AppSizes.width_4_5,
                                        end: AppSizes.width_3_6),
                                    child: Image.asset(Assets.icons.icBloodGroup.path,
                                        width: AppSizes.width_6,
                                        height: AppSizes.width_6),
                                  ),
                                  items: Constant.bloodGroupList,
                                  selectedItem: logic.selectedBloodGroup,
                                  hintText: 'txtSelectBloodGroup'.tr,
                                  onChanged: (value) {
                                    logic.selectedBloodGroup = value;
                                    logic.update([Constant.idSelectBloodGroup]);
                                  },
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_2,
                          ),
                          GetBuilder<AddOrEditFamilyMemberScreenLogic>(
                              id: Constant.idUserEmail,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  controller: logic.userEmailController,
                                  hintText: 'txtEnterEmailAddress'.tr,
                                  keyboardType: TextInputType.emailAddress,
                                  validatorType: Constant.validationTypeEmail,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[a-z A-Z 0-9 . @]")),
                                  ],
                                  fillColor:
                                  Get.theme.colorScheme.surfaceVariant,
                                  prefixIcon: Assets.icons.icMessage.path,
                                  validatorText: 'txtEnterEmailAddress'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_2,
                          ),
                          GetBuilder<AddOrEditFamilyMemberScreenLogic>(
                              id: Constant.idUserPhone,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  controller: logic.userPhoneController,
                                  hintText: 'txtEnterPhoneNumber'.tr,
                                  // validatorType: Constant.validationTypePhone,
                                  fillColor:
                                  Get.theme.colorScheme.surfaceVariant,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: 15,
                                  keyboardType: TextInputType.phone,
                                  prefixIcon: Assets.icons.icPhone.path,
                                  // validatorText: 'txtEnterValidPhoneNumber'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_2,
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
                                  },
                                  text: logic.isEdit
                                      ? 'txtUpdateNow'.tr
                                      : 'txtSave'.tr),
                            ],
                          ),
                          SizedBox(
                            height: AppSizes.height_2_2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ))),
        GetBuilder<AddOrEditFamilyMemberScreenLogic>(
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

  /// Avatar picker — a live preview, a row of generated preset avatars, and a
  /// camera badge for a photo. Presets save offline; photo needs connectivity.
  Widget _avatarSection(AddOrEditFamilyMemberScreenLogic logic) {
    final scheme = Get.theme.colorScheme;
    const double preview = 96;

    final Widget previewChild = logic.pickedNewFile != null
        ? Image.file(
            File(logic.pickedNewFile!.path),
            width: preview,
            height: preview,
            fit: BoxFit.cover,
          )
        : MemberAvatar(
            size: preview,
            profileImage: logic.profileUrl,
            gender: logic.selectedGender,
          );

    return Column(
      children: [
        SizedBox(
          width: preview,
          height: preview,
          child: Stack(
            children: [
              Container(
                width: preview,
                height: preview,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.primary.withOpacity(0.25),
                    width: 2,
                  ),
                ),
                child: ClipOval(child: previewChild),
              ),
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: InkWell(
                  onTap: () => logic.openImagePickerDialog(),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary,
                      border:
                          Border.all(color: scheme.background, width: 2),
                    ),
                    child: const Icon(Icons.photo_camera,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.height_1_5),
        CommonText(
          text: 'txtChooseAvatar'.tr,
          textColor: scheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w500,
          fontSize: AppFontSize.size_13,
        ),
        SizedBox(height: AppSizes.height_1_5),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 25),
            itemCount: MemberAvatar.presetCount,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final bool selected =
                  logic.profileUrl == MemberAvatar.presetValue(i);
              return GestureDetector(
                onTap: () => logic.selectAvatar(i),
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? scheme.primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: MemberAvatar(
                    size: 42,
                    profileImage: MemberAvatar.presetValue(i),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
