import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_details_item.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class FamilyMemberDialog {
  final Function() onTapEdit;
  final Function() onTapDelete;
  final FamilyMemberTable familyMember;

  FamilyMemberDialog(
      {required this.familyMember,
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
                                  text: 'txtMemberDetails'.tr,
                                  textColor: Get.theme.colorScheme.primary,
                                  textAlign: TextAlign.center,
                                  fontSize: AppFontSize.size_18,
                                  fontWeight: FontWeight.w600),
                            ),
                            InkWell(
                              onTap: () => Get.back(),
                              child: Container(
                                width: AppSizes.height_3,
                                height: AppSizes.height_3,
                                alignment: Alignment.center,
                                child: Image.asset(
                                  Assets.iconsIcCloseDark,
                                  color: Get.theme.colorScheme.tertiary,
                                  height: AppSizes.height_2,
                                  width: AppSizes.height_2,
                                ),
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
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Get.theme.colorScheme.primary),
                            child: familyMember.profileImage != null
                                ? CachedNetworkImage(
                              imageUrl: familyMember.profileImage!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider, fit: BoxFit.cover),
                                    ),
                                  ),
                              placeholder: (context, url) => Padding(
                                padding: const EdgeInsets.all(35),
                                child: Image.asset(Constant.genderIconList[
                                Constant.genderList.indexOf(familyMember.gender ??
                                        Constant.genderList[0])]),
                              ),
                              errorWidget: (context, url, error) => Padding(
                                padding: const EdgeInsets.all(35),
                                child: Image.asset(Constant.genderIconList[
                                Constant.genderList.indexOf(familyMember.gender ??
                                    Constant.genderList[0])]),
                              ),
                            )
                                :Padding(
                                  padding: const EdgeInsets.all(35),
                                  child: Image.asset(Constant.genderIconList[Constant.genderList.indexOf(familyMember.gender??Constant.genderList[0])]),
                                ),
                          ),
                          Expanded(
                            child: CommonText(
                                text: familyMember.name!,
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
                          if(familyMember.gender!=null&&familyMember.gender!.isNotEmpty)DetailItem(
                            subtitle: 'txtGender'.tr,
                            title: familyMember.gender!,
                            icon: Assets.iconsIcGender,
                          ),
                          if(familyMember.age!=null&& familyMember.age!.isNotEmpty)DetailItem(
                            subtitle: 'txtAge'.tr,
                            title:
                                '${familyMember.age!.split(' ')[0]} ${familyMember.age!.split(' ')[1]}',
                            icon: Assets.iconsIcAge,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2,
                      ),
                      Row(
                        children: [
                          if(familyMember.birthDate!=null&&familyMember.birthDate!.isNotEmpty)DetailItem(
                            subtitle: 'txtBirthDate'.tr,
                            title: familyMember.birthDate!,
                            maxWidth: AppSizes.fullWidth/3.5,
                            icon: Assets.iconsIcCalendar,
                          ),
                          if(familyMember.bloodGroup!=null&&familyMember.bloodGroup!.isNotEmpty)DetailItem(
                            subtitle: 'txtBloodGroup'.tr,
                            title: familyMember.bloodGroup!,
                            maxWidth: AppSizes.fullWidth/4.1,
                            icon: Assets.iconsIcBloodGroup,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2,
                      ),
                      Row(
                        children: [
                          if(familyMember.phoneNumber!=null&&familyMember.phoneNumber!.isNotEmpty)DetailItem(
                            subtitle: 'txtPhone'.tr,
                            title: familyMember.phoneNumber!,
                            icon: Assets.iconsIcPhone,
                          ),
                        ],
                      ),

                      SizedBox(
                        height: AppSizes.height_2,
                      ),
                      Row(
                        children: [
                          if(familyMember.email!=null&&familyMember.email!.isNotEmpty)DetailItem(
                            subtitle: 'txtEmail'.tr,
                            title: familyMember.email!,
                            icon: Assets.iconsIcMessage,
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonButtonOne(
                      onTap: onTapEdit,
                      backgroundColor: Get.theme.colorScheme.background,
                      text: 'txtEdit'.tr),
                  SizedBox(
                    width: AppSizes.height_2_5,
                  ),
                  CommonButtonOne(onTap: onTapDelete, text: 'txtDelete'.tr),
                ],
              ),
              SizedBox(
                height: AppSizes.height_2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
