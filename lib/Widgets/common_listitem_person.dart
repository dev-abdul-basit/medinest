import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/doctor_detail_dialog.dart';
import 'package:medinest/Widgets/family_member_detail_dialog.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/ui/doctors_screen/doctors_screen_logic.dart';
import 'package:medinest/ui/family_member_screen/family_member_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class ItemPerson extends StatelessWidget {
  final FamilyMemberTable? familyMember;
  final DoctorsTable? doctor;

  const ItemPerson({
    super.key,
    this.familyMember,
    this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.height_19,
      margin: const EdgeInsets.symmetric(vertical: 15,horizontal: 12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.primary.withOpacity(0.2),
            spreadRadius: 0.5,
            blurRadius: 7,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (familyMember != null) {
                  FamilyMemberDialog(
                      familyMember: familyMember!,
                      onTapEdit: () {
                        Get.back();
                        Get.find<FamilyMemberScreenLogic>()
                            .gotoEditMember(familyMember!);
                      },
                      onTapDelete: () {
                        Get.back();
                        deleteBottomSheet(context);
                      }).scaleDialog(Get.context!);
                } else {
                  DoctorDetailsDialog(
                      doctor: doctor!,
                      onTapEdit: () {
                        Get.back();
                        Get.find<DoctorsScreenLogic>()
                            .gotoEditDoctor(doctor!);
                      },
                      onTapDelete: () {
                        Get.back();
                        deleteBottomSheet(context);
                      }).scaleDialog(Get.context!);
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: AppSizes.height_9,
                      height: AppSizes.height_9,
                      // padding: const EdgeInsets.all(18),
                      margin: EdgeInsetsDirectional.fromSTEB(
                          AppSizes.height_3, 0, 0, 0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Get.theme.colorScheme.errorContainer),
                      child: familyMember?.profileImage != null
                          ? CachedNetworkImage(
                              imageUrl: familyMember!.profileImage!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => Padding(
                                padding: const EdgeInsets.all(18),
                                child: Image.asset(Constant.genderIconList[
                                    Constant.genderList.indexOf(familyMember!.gender ??
                                                Constant.genderList[0])]),
                              ),
                              errorWidget: (context, url, error) => Padding(
                                padding: const EdgeInsets.all(18),
                                child: Image.asset(Constant.genderIconList[
                                    Constant.genderList.indexOf(familyMember!.gender ??
                                                Constant.genderList[0])]),
                              ),
                            )
                          :doctor?.profileImage != null?
                      CachedNetworkImage(
                        imageUrl: doctor!.profileImage!,
                        imageBuilder: (context, imageProvider) =>
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                        placeholder: (context, url) => Padding(
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(Constant.genderIconList[
                          Constant.genderList.indexOf(doctor!.gender ??
                              Constant.genderList[0])]),
                        ),
                        errorWidget: (context, url, error) => Padding(
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(Constant.genderIconList[
                          Constant.genderList.indexOf(doctor!.gender ??
                              Constant.genderList[0])]),
                        ),
                      )
                          : Padding(
                              padding: const EdgeInsets.all(18),
                              child: Image.asset(Constant.genderIconList[
                                  Constant.genderList.indexOf(
                                      familyMember != null
                                          ? familyMember!.gender ??
                                              Constant.genderList[0]
                                          : doctor!.gender ??
                                              Constant.genderList[0])]),
                            ),
                  ),
                  SizedBox(
                    width: AppFontSize.size_10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: AppSizes.fullWidth/1.8),
                          child: CommonText(
                              text: familyMember?.name ?? doctor?.name ?? '',
                              textColor: Get.theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              maxLines: 2,
                              fontSize: AppFontSize.size_14),
                        ),
                        if ((familyMember?.email != null &&
                            familyMember!.email!.isNotEmpty) ||
                            (doctor?.email != null &&
                                doctor!.email!.isNotEmpty))
                          CommonText(
                              text:
                              '${'txtEmail'.tr}: ${familyMember?.email ?? doctor?.email ?? ''}',
                              maxLines: 1,
                              textColor: Get.theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w300,
                              fontSize: AppFontSize.size_10),
                        if ((familyMember?.phoneNumber != null &&
                            familyMember!.phoneNumber!.isNotEmpty) ||
                            (doctor?.phoneNumber != null &&
                                doctor!.phoneNumber!.isNotEmpty))
                          CommonText(
                              text:
                              '${'txtPhone'.tr}: ${familyMember?.phoneNumber ?? doctor?.phoneNumber ?? ''}',
                              textColor: Get.theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w300,
                              fontSize: AppFontSize.size_10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        backgroundColor: Get.theme.colorScheme.surfaceVariant,
                        foregroundColor: Get.theme.colorScheme.primary,
                        surfaceTintColor: Get.theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Get.theme.colorScheme.primary),
                            borderRadius: const BorderRadiusDirectional.only(
                                topEnd: Radius.circular(15),
                                bottomStart: Radius.circular(15))),
                        splashFactory: InkSplash.splashFactory),
                    onPressed: () => familyMember != null
                        ? Get.find<FamilyMemberScreenLogic>()
                        .gotoEditMember(familyMember!)
                        : Get.find<DoctorsScreenLogic>()
                        .gotoEditDoctor(doctor!),
                    child: Image.asset(
                      Assets.iconsIcEdit,
                      color: Get.theme.colorScheme.primary,
                      width: AppSizes.height_2,
                      height: AppSizes.height_2,
                    )),
              ),
              SizedBox(
                width: AppFontSize.size_5,
              ),
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Get.theme.colorScheme.primary,
                        foregroundColor: Get.theme.colorScheme.background,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Get.theme.colorScheme.primary),
                            borderRadius: const BorderRadiusDirectional.only(
                                topStart: Radius.circular(15),
                                bottomEnd: Radius.circular(15))),
                        splashFactory: InkSplash.splashFactory),
                    onPressed: () {
                      deleteBottomSheet(context);
                    },
                    child: Image.asset(
                      Assets.iconsIcDelete,
                      width: AppSizes.height_2,
                      height: AppSizes.height_2,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<dynamic> deleteBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => DeleteConformation(
          title: familyMember != null
              ? 'txtDeleteMember'.tr
              : 'txtDeleteDoctor'.tr,
          description: familyMember != null
              ? 'txtAreYouSureYouWantToDeleteThisMember'.tr
              : 'txtAreYouSureYouWantToDeleteThisDoctor'.tr,
          onTapDelete: () {
            if (familyMember != null) {
              Get.find<FamilyMemberScreenLogic>()
                  .deleteMember(familyMember!);
            } else {
              Get.find<DoctorsScreenLogic>().deleteMember(doctor!);
            }
          },
        ));
  }
}
