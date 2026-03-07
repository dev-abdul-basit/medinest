import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_details_item.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/database/tables/journal_table.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class AppointmentDetailsDialog {
  final Function() onTapEdit;
  final Function() onTapDelete;
  final DoctorsTable doctorDetails;
  final JournalTable appointmentTable;
  final int familyMemberId;

  AppointmentDetailsDialog({
      required this.onTapEdit,
      required this.doctorDetails,
      required this.appointmentTable,
      required this.familyMemberId,
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
    final logic = Get.find<JournalScreenLogic>();

    // List<TimeOfDay> times = NotificationHelper().parseTimeList(appointmentTable.appointmentTime!);

    // DateTime startDate = DateTime.parse(appointmentTable.appointmentDate!);

    // FamilyMemberTable? familyMemberTable = logic.familyMembersList
    //     .where((element) => element!.fId! == appointmentTable.bookedForFamilyMemberId)
    //     .toList()
    //     .first;

    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: AppSizes.fullWidth,
        height: AppSizes.fullHeight,
        padding: EdgeInsetsDirectional.fromSTEB(AppSizes.width_2, 0, AppSizes.width_2, 0),
        color: Get.theme.colorScheme.background,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: AppSizes.width_4),
                        child: Row(
                          children: [
                            Expanded(
                              child: CommonText(
                                  text: 'txtJournalDetails'.tr,
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
                      SizedBox(
                        height: AppSizes.height_2,
                      ),
                      Row(
                        children: [
                          Container(
                            width: AppSizes.height_18,
                            height: AppSizes.height_18,
                            // padding: EdgeInsets.all(AppSizes.width_7),
                            margin: EdgeInsetsDirectional.only(
                                start: AppSizes.width_3_5,
                                end: AppSizes.width_4),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Get.theme.colorScheme.primary),
                            child: doctorDetails.profileImage != null
                                ? CachedNetworkImage(
                              imageUrl: doctorDetails.profileImage!,
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
                                        .indexOf(doctorDetails.gender ??
                                        Constant.genderList[0])]),
                              ),
                              errorWidget: (context, url, error) =>
                                  Padding(
                                    padding: const EdgeInsets.all(35),
                                    child: Image.asset(
                                        Constant.genderIconList[Constant
                                            .genderList
                                            .indexOf(doctorDetails.gender ??
                                            Constant.genderList[0])]),
                                  ),
                            )
                                : Padding(
                              padding: const EdgeInsets.all(35),
                              child: Image.asset(Constant.genderIconList[
                              Constant.genderList.indexOf(
                                  doctorDetails.gender ??
                                      Constant.genderList[0])]),
                            ),
                            // child: Image.asset(Constant.genderIconList[Constant
                            //     .genderList
                            //     .indexOf(doctorDetails.gender ??
                            //         Constant.genderList[0])]),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: AppSizes.fullWidth/2.1,
                                alignment: AlignmentDirectional.centerStart,
                                child: CommonText(
                                    text: doctorDetails.name!,
                                    textColor: Get.theme.colorScheme.onPrimary,
                                    textAlign: TextAlign.start,
                                    fontSize: AppFontSize.size_22,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: AppSizes.height_0_2,
                              ),
                              CommonText(
                                  text: 'txtBookingFor'.tr,
                                  textColor: Get.theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w300,
                                  fontSize: AppFontSize.size_8),
                              // Container(
                              //   constraints: BoxConstraints(maxWidth: AppSizes.fullWidth/2.2),
                              //   child: CommonText(
                              //       text: familyMemberTable?.name??'',
                              //       maxLines: 2,
                              //       textColor: Get.theme.colorScheme.onPrimary,
                              //       fontWeight: FontWeight.w600,
                              //       fontSize: AppFontSize.size_11),
                              // ),
                              SizedBox(
                                height: AppSizes.height_2,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2_5,
                      ),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     DetailItem(
                      //       subtitle: 'txtDate'.tr,
                      //       title: DateFormat('dd-MM-yyyy').format(startDate),
                      //       icon: Assets.iconsIcCalendar,
                      //     ),
                      //     DetailItem(
                      //       subtitle: 'txtTime'.tr,
                      //       title: times.first.format(Get.context!),
                      //       icon: Assets.iconsIcWatch,
                      //       // titleWidget: InputChip(
                      //       //   padding: EdgeInsets.zero,
                      //       //
                      //       //   // labelPadding: EdgeInsets.zero,
                      //       //   shape: const RoundedRectangleBorder(
                      //       //       borderRadius: BorderRadius.all(Radius.circular(50))),
                      //       //   label: CommonText(
                      //       //       text: times.first.format(Get.context!),
                      //       //       textColor: Get.theme.colorScheme.inverseSurface,
                      //       //       fontWeight: FontWeight.w600,
                      //       //       fontSize: AppFontSize.size_10),
                      //       //   onSelected: (bool selected) {},
                      //       //   backgroundColor: Get.theme.colorScheme.onSecondary,
                      //       // ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: AppSizes.height_2_5,
                      // ),
                      // if (appointmentTable.reminderBeforeTime != null &&
                      //     appointmentTable.reminderBeforeTime != 'None' &&
                      //     appointmentTable.reminderBeforeTime != 'null')
                      //   DetailItem(
                      //     subtitle: 'txtRemindBeforeTime'.tr,
                      //     title:
                      //         '${'txtBefore'.tr} ${appointmentTable.reminderBeforeTime}min',
                      //     icon: Assets.iconsIcWatchBefore,
                      //   ),
                      // SizedBox(
                      //   height: AppSizes.height_2_5,
                      // ),
                      // if (doctorDetails.hospitalName != null &&
                      //     doctorDetails.hospitalName!.isNotEmpty)
                      //   DetailItem(
                      //     subtitle: 'txtHospitalName'.tr,
                      //     title: '${doctorDetails.hospitalName}',
                      //     icon: Assets.iconsIcHospital,
                      //   ),
                      // SizedBox(
                      //   height: AppSizes.height_2_5,
                      // ),
                      // if (doctorDetails.hospitalAddress != null &&
                      //     doctorDetails.hospitalAddress!.isNotEmpty)
                      //   DetailItem(
                      //     subtitle: 'txtHospitalAddress'.tr,
                      //     title: '${doctorDetails.hospitalAddress}',
                      //     icon: Assets.iconsIcLocation,
                      //   ),
                      SizedBox(
                        height: AppSizes.height_2_5,
                      ),
                      if (appointmentTable.description != null &&
                          appointmentTable.description!.isNotEmpty)
                        DetailItem(
                          subtitle: 'txtDescription'.tr,
                          title: '${appointmentTable.description}',
                          icon: Assets.iconsIcDocument,
                        ),
                      SizedBox(
                        height: AppSizes.height_4,
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
                height: AppSizes.height_3_5,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
