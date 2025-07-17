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

import 'add_or_edit_doctor_screen_logic.dart';

class AddOrEditDoctorScreenPage extends StatelessWidget {
  const AddOrEditDoctorScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<AddOrEditDoctorScreenLogic>();

    return Stack(
      children: [
        Scaffold(
            backgroundColor: Get.theme.colorScheme.background,
            appBar: CommonAppBar(title: 'txtAddDoctor'.tr),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      GetBuilder<AddOrEditDoctorScreenLogic>(
                          id: Constant.idProfilePhoto,
                          builder: (logic) {
                            return Container(
                              width: AppSizes.height_20,
                              height: AppSizes.height_20,
                              padding:  EdgeInsets.all(logic.profileUrl != null?0:50),
                              margin: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: logic.pickedNewFile != null
                                      ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(
                                          File(logic.pickedNewFile!.path)))
                                      : null,
                                  color: Get.theme.colorScheme.primary),
                              child: logic.profileUrl != null
                                  ? CachedNetworkImage(
                                imageUrl: logic.profileUrl!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                placeholder: (context, url) =>
                                    Image.asset(
                                      Assets.iconsIcUserName,
                                      color: Colors.white,
                                    ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                      Assets.iconsIcUserName,
                                      color: Colors.white,
                                    ),
                              )
                                  : logic.pickedNewFile != null?const SizedBox():Image.asset(
                                Assets.iconsIcUserName,
                                color: Colors.white,
                              ),
                            );
                          }),
                      PositionedDirectional(
                        bottom: 1,
                        end: 1,
                        child: InkWell(
                          onTap: () => logic.openImagePickerDialog(),
                          child: Container(
                            width: AppSizes.height_5_5,
                            height: AppSizes.height_5_5,
                            padding: const EdgeInsets.all(11),
                            margin: const EdgeInsets.all(26),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Get.theme.colorScheme.background,
                                    width: 4),
                                shape: BoxShape.circle,
                                color: Get.theme.colorScheme.onSecondary),
                            child: Image.asset(Assets.iconsIcEditPhoto,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Container(
                  //   width: AppSizes.height_20,
                  //   height: AppSizes.height_20,
                  //   padding: const EdgeInsets.all(50),
                  //   margin: const EdgeInsets.all(25),
                  //   decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Get.theme.colorScheme.primary),
                  //   child: GetBuilder<AddOrEditDoctorScreenLogic>(
                  //       id: Constant.idSelectGender,
                  //       builder: (logic) {
                  //         return Image.asset(Constant.genderIconList[Constant.genderList.indexOf(logic.selectedGender??Constant.genderList[0])]);
                  //       }),
                  // ),
                  Form(
                    key: logic.formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25),
                      child: Column(
                        children: [
                          GetBuilder<AddOrEditDoctorScreenLogic>(
                              id: Constant.idUserNameInput,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  controller: logic.doctorNameController,
                                  maxLength: 30,
                                  hintText: '${'txtEnterDoctorName'.tr} *',
                                  shouldValidate: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp("[a-z A-Z .]")),
                                  ],
                                  fillColor: Get.theme.colorScheme.surfaceVariant,
                                  prefixIcon: Assets.iconsIcDoctorName,
                                  validatorText: 'txtEnterDoctorName'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_5,
                          ),
                          GetBuilder<AddOrEditDoctorScreenLogic>(
                              id: Constant.idSelectGender,
                              builder: (logic) {
                                return DropdownWithPrefix(
                                  prefix: Padding(
                                    padding:  EdgeInsetsDirectional.only(
                                        start: AppSizes.width_4_5,end: AppSizes.width_3_6),
                                    child: Image.asset(Assets.iconsIcGender,
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
                            height: AppSizes.height_2_5,
                          ),
                          GetBuilder<AddOrEditDoctorScreenLogic>(
                              id: Constant.idUserBirthDateInput,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  // onTap: logic.selectBirthDate,
                                  controller: logic.doctorExpController,
                                  hintText: 'txtEnterDoctorCategory'.tr,
                                  fillColor: Get.theme.colorScheme.surfaceVariant,
                                  prefixIcon: Assets.iconsIcBag,
                                  validatorText: 'txtEnterDoctorCategory'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_5,
                          ),
                          GetBuilder<AddOrEditDoctorScreenLogic>(
                              id: Constant.idUserEmail,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  controller: logic.doctorEmailController,
                                  hintText: 'txtEnterEmailAddress'.tr,
                                  validatorType: Constant.validationTypeEmail,
                                  fillColor: Get.theme.colorScheme.surfaceVariant,
                                  keyboardType: TextInputType.emailAddress,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp("[a-z A-Z 0-9 . @]")),
                                  ],
                                  prefixIcon: Assets.iconsIcMessage,
                                  validatorText: 'txtEnterEmailAddress'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_5,
                          ),
                          GetBuilder<AddOrEditDoctorScreenLogic>(
                              id: Constant.idUserPhone,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  controller: logic.doctorPhoneController,
                                  hintText: 'txtEnterPhoneNumber'.tr,
                                  // validatorType: Constant.validationTypePhone,
                                  fillColor: Get.theme.colorScheme.surfaceVariant,
                                  keyboardType : TextInputType.phone,
                                  prefixIcon: Assets.iconsIcPhone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: 15,
                                  // validatorText: 'txtEnterValidPhoneNumber'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_5,
                          ),
                          GetBuilder<AddOrEditDoctorScreenLogic>(
                              id: Constant.idUserPhone,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  controller: logic.hospitalNameController,
                                  hintText: 'txtEnterHospitalName'.tr,
                                  fillColor: Get.theme.colorScheme.surfaceVariant,
                                  keyboardType : TextInputType.text,
                                  prefixIcon: Assets.iconsIcHospital,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp("[a-z A-Z .]")),
                                  ],
                                  validatorText: 'txtEnterHospitalName'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_5,
                          ),
                          GetBuilder<AddOrEditDoctorScreenLogic>(
                              id: Constant.idUserPhone,
                              builder: (logic) {
                                return CommonTextFormFieldWithSuffix(
                                  controller: logic.hospitalAddressController,
                                  hintText: 'txtEnterHospitalAddress'.tr,
                                  fillColor: Get.theme.colorScheme.surfaceVariant,
                                  keyboardType : TextInputType.multiline,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp("[a-z A-Z 0-9 , . -]")),
                                  ],
                                  maxLines: 6,
                                  prefixIcon: Assets.iconsIcLocation,
                                  validatorText: 'txtEnterHospitalAddress'.tr,
                                );
                              }),
                          SizedBox(
                            height: AppSizes.height_2_5,
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
                            height: AppSizes.height_5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
        GetBuilder<AddOrEditDoctorScreenLogic>(
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
