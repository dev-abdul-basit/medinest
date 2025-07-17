import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_details_item.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class DoctorDetailsDialog {
  final Function() onTapEdit;
  final Function() onTapDelete;
  final DoctorsTable doctor;

  DoctorDetailsDialog({required this.doctor,
    required this.onTapEdit,
    required this.onTapDelete});

  void scaleDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(a1),
          child: _dialog(ctx),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _dialog(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: AppSizes.fullWidth,
        color: Get.theme.colorScheme.background,
        padding:  EdgeInsets.only(left: AppSizes.width_2,right: AppSizes.width_2),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: CommonText(
                                  text: 'txtDoctorDetails'.tr,
                                  textColor: Get.theme.colorScheme.primary,
                                  textAlign: TextAlign.center,
                                  fontSize: AppFontSize.size_18,
                                  fontWeight: FontWeight.w600),
                            ),
                            InkWell(
                              onTap: () => Get.back(),
                              child: Image.asset(
                                Assets.iconsIcCloseDark,
                                color: Get.theme.colorScheme.tertiary,
                                height: AppSizes.height_2,
                                width: AppSizes.height_2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: AppSizes.height_16,
                            height: AppSizes.height_16,
                            // padding: const EdgeInsets.all(35),
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Get.theme.colorScheme.primary),
                            child: doctor.profileImage != null
                                ? CachedNetworkImage(
                                    imageUrl: doctor.profileImage!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    placeholder: (context, url) => Padding(
                                      padding: const EdgeInsets.all(35),
                                      child: Image.asset(
                                          Constant.genderIconList[Constant
                                              .genderList
                                              .indexOf(doctor.gender ??
                                                  Constant.genderList[0])]),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Padding(
                                      padding: const EdgeInsets.all(35),
                                      child: Image.asset(
                                          Constant.genderIconList[Constant
                                              .genderList
                                              .indexOf(doctor.gender ??
                                                  Constant.genderList[0])]),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(35),
                                    child: Image.asset(Constant.genderIconList[
                                        Constant.genderList.indexOf(
                                            doctor.gender ??
                                                Constant.genderList[0])]),
                                  ),
                            // child: Image.asset(Constant.genderIconList[Constant.genderList.indexOf(doctor.gender??Constant.genderList[0])]
                          ),
                          Expanded(
                            child: CommonText(
                                text: doctor.name!,
                                maxLines: 3,
                                textColor: Get.theme.colorScheme.primary,
                                textAlign: TextAlign.start,
                                fontSize: AppFontSize.size_22,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (doctor.experience != null && doctor.experience != 'null' &&
                              doctor.experience!.isNotEmpty)
                            Expanded(
                              child: DetailItem(
                                subtitle: 'txtEnterDoctorCategory'.tr.split(' ').sublist(1,3).join(' '),
                                title: doctor.experience!,
                                maxWidth: AppSizes.fullWidth/3,
                                icon: Assets.iconsIcBag,
                              ),
                            ),
                          if (doctor.gender != null &&
                              doctor.gender!.isNotEmpty)
                            DetailItem(
                              subtitle: 'txtGender'.tr,
                              title: doctor.gender!,
                              icon: Assets.iconsIcGender,
                            ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2,
                      ),
                      Row(
                        children: [
                          if (doctor.phoneNumber != null &&
                              doctor.phoneNumber!.isNotEmpty)
                            DetailItem(
                              subtitle: 'txtPhoneNumber'.tr,
                              title: doctor.phoneNumber!,
                              icon: Assets.iconsIcPhone,
                            ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2,
                      ),
                      Row(
                        children: [
                          if (doctor.email != null && doctor.email!.isNotEmpty)
                            DetailItem(
                              subtitle: 'txtEmailAddress'.tr,
                              title: doctor.email!,
                              icon: Assets.iconsIcMessage,
                            ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2,
                      ),
                      Row(
                        children: [
                          if (doctor.hospitalName != null &&
                              doctor.hospitalName!.isNotEmpty)
                            DetailItem(
                              subtitle: 'txtHospitalName'.tr,
                              title: doctor.hospitalName!,
                              icon: Assets.iconsIcHospital,
                            ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2,
                      ),
                      Row(
                        children: [
                          if (doctor.hospitalAddress != null &&
                              doctor.hospitalAddress!.isNotEmpty)
                            DetailItem(
                              subtitle: 'txtHospitalAddress'.tr,
                              title: doctor.hospitalAddress!,
                              icon: Assets.iconsIcLocation,
                            ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2,
                      ),

                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CommonButtonOne(
                      onTap: onTapEdit,
                      backgroundColor: Get.theme.colorScheme.background,
                      text: 'txtEdit'.tr),
                  CommonButtonOne(onTap: onTapDelete, text: 'txtDelete'.tr),
                ],
              ),
              SizedBox(
                height: AppSizes.height_3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
