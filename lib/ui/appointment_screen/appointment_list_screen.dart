import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/appointmet_detail_dialog.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/no_data_widget.dart';
import 'package:medinest/database/tables/appointment_table.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/ui/appointment_screen/appointment_screen_logic.dart';
import 'package:medinest/ui/home/home_controller.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/no_data_widget.dart';
import 'package:medinest/database/tables/appointment_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/ui/appointment_screen/appointment_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class AppointmentListScreen extends StatelessWidget {
  final int familyMemberId;

  const AppointmentListScreen({
    super.key,
    required this.familyMemberId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentScreenLogic>(
      id: Constant.idAppointmentList,
      builder: (logic) {
        /// FILTER JOURNALS FOR THIS FAMILY MEMBER
        final journals = logic.appointmentList
            .where((e) =>
        e!.aId == familyMemberId &&
            e.mIsDeleted != 1)
            .toList()
            .reversed
            .toList();

        if (journals.isEmpty) {
          return NoDataWidget(
            image: Assets.imagesImgNoMedicine,
            text: 'txtYouDontHaveAnyJournal'.tr,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: AppFontSize.size_10,
            horizontal: AppFontSize.size_4,
          ),
          itemCount: journals.length,
          itemBuilder: (context, index) {
            return journalItem(
              journalTable: journals[index]!,
            );
          },
        );
      },
    );
  }
}

/// ======================
/// JOURNAL ITEM UI
/// ======================
Widget journalItem({
  required AppointmentTable journalTable,
}) {
  return GetBuilder<AppointmentScreenLogic>(
    id: Constant.idAppointmentListItem,
    builder: (logic) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.primary.withOpacity(0.15),
              blurRadius: 7,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            /// CONTENT
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// JOURNAL TITLE
                  CommonText(
                    text: journalTable.mSoundTitle ?? '---',
                    fontSize: AppFontSize.size_14,
                    fontWeight: FontWeight.w600,
                    textColor: Get.theme.colorScheme.primary,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 8),

                  /// JOURNAL DESCRIPTION
                  CommonText(
                    text: journalTable.description ?? '',
                    fontSize: AppFontSize.size_11,
                    fontWeight: FontWeight.w400,
                    textColor: Get.theme.colorScheme.onSurface,
                    maxLines: 4,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            /// ACTION BUTTONS
            Row(
              children: [
                /// EDIT
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                      Get.theme.colorScheme.surfaceVariant,
                      foregroundColor:
                      Get.theme.colorScheme.primary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                          bottomStart: Radius.circular(25),
                        ),
                      ),
                    ),
                    onPressed: () {
                      logic.gotoEditAppointment(journalTable);
                    },
                    child: Image.asset(
                      Assets.iconsIcEdit,
                      width: AppSizes.height_2,
                      height: AppSizes.height_2,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),

                /// DELETE
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Get.theme.colorScheme.primary,
                      foregroundColor:
                      Get.theme.colorScheme.background,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                          bottomEnd: Radius.circular(25),
                        ),
                      ),
                    ),
                    onPressed: () {
                      deleteBottomSheet(Get.context!, journalTable);
                    },
                    child: Image.asset(
                      Assets.iconsIcDeleteFill,
                      width: AppSizes.height_2,
                      height: AppSizes.height_2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// ======================
/// DELETE BOTTOM SHEET
/// ======================
Future<dynamic> deleteBottomSheet(
    BuildContext context,
    AppointmentTable journalTable,
    ) {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => DeleteConformation(
      title: 'txtDeleteJournal'.tr,
      description: 'txtAreYouSureYouWantToDeleteThisJournal'.tr,
      onTapDelete: () {
        Get.find<AppointmentScreenLogic>()
            .deleteAppointment(journalTable);
      },
    ),
  );
}



// class AppointmentListScreen extends StatelessWidget {
//   final int familyMemberId;
//
//   const AppointmentListScreen({super.key, required this.familyMemberId});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AppointmentScreenLogic>(
//         id :Constant.idAppointmentList,
//         builder: (logic) {
//           return logic.appointmentList.isNotEmpty &&
//               logic.appointmentList
//                   .where((element) =>
//               element!.bookedForFamilyMemberId! == familyMemberId && element.mIsDeleted!=1)
//                   .toList()
//                   .isNotEmpty
//               ? ListView.builder(
//             padding: EdgeInsets.symmetric(
//                 vertical: AppFontSize.size_10,
//                 horizontal: AppFontSize.size_4),
//             itemCount: logic.appointmentList
//                 .where((element) =>
//             element!.bookedForFamilyMemberId! == familyMemberId&&element.mIsDeleted!=1)
//                 .toList().reversed.toList()
//                 .length,
//             itemBuilder: (context, index) {
//               return appointment(
//                   appointmentTable: logic.appointmentList
//                       .where((element) =>
//                   element!.bookedForFamilyMemberId! ==
//                       familyMemberId&&element.mIsDeleted!=1)
//                       .toList().reversed.toList()[index]!,
//                   familyMemberId: familyMemberId);
//             },
//           )
//               :  NoDataWidget(
//             image: Assets.imagesImgNoMedicine,
//             text: 'txtYouDontHaveAnyJournal'.tr,
//           );
//         });
//   }
//
//   appointment({
//     AppointmentTable? appointmentTable,
//     required int familyMemberId,
//   }) {
//     return GetBuilder<AppointmentScreenLogic>(
//         id :  Constant.idAppointmentListItem,
//         builder: (logic) {
//           DoctorsTable? doctorDetails = logic.doctorsList
//               .where((element) => element!.dId! == appointmentTable!.doctorId!)
//               .toList()
//               .first!;
//           DateTime startDate =
//           DateTime.parse(appointmentTable!.appointmentDate!);
//           TimeOfDay times = NotificationHelper()
//               .parseTimeList(appointmentTable.appointmentTime!)
//               .first;
//
//
//           return Container(
//             height: AppSizes.height_24,
//             margin: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
//             decoration: BoxDecoration(
//               color: Get.theme.colorScheme.surfaceVariant,
//               borderRadius: const BorderRadius.all(Radius.circular(25)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Get.theme.colorScheme.primary.withOpacity(0.2),
//                   spreadRadius: 0.5,
//                   blurRadius: 7,
//                   offset: const Offset(0, 5), // changes position of shadow
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(top: AppSizes.width_4, left: AppSizes.width_4_5,right: AppSizes.width_4_5,bottom: AppSizes.width_3),
//                   child: Row(
//                     children: [
//                       Image.asset(Assets.iconsIcCalendar,
//                           color: Get.theme.colorScheme.onPrimary,
//                           height: AppSizes.width_4_5,
//                           width: AppSizes.width_4_5),
//                       SizedBox(width: AppSizes.width_2),
//                       CommonText(
//                           text: DateFormat('dd-MM-yyyy').format(startDate),
//                           textColor: Get.theme.colorScheme.onPrimary,
//                           fontWeight: FontWeight.w500,
//                           fontSize: AppFontSize.size_10),
//                       const Spacer(),
//                       Image.asset(Assets.iconsIcWatch,
//                           color: Get.theme.colorScheme.onPrimary,
//                           height: AppSizes.width_4_5,
//                           width: AppSizes.width_4_5),
//                       SizedBox(width: AppSizes.width_2),
//                       CommonText(
//                           text: times.format(Get.context!),
//                           textColor: Get.theme.colorScheme.onPrimary,
//                           fontWeight: FontWeight.w500,
//                           fontSize: AppFontSize.size_10),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   color: Get.theme.colorScheme.surface.withOpacity(0.5),
//                   width: AppSizes.fullWidth - 80,
//                   height: 1,
//                 ),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       if (!Preference.shared.getIsPurchase()) {
//                         Get.find<HomeController>().showAd();
//                       }
//                         AppointmentDetailsDialog(
//                           onTapDelete: () {
//                             Get.back();
//                             deleteBottomSheet(Get.context!, appointmentTable);
//                           },
//                           onTapEdit: () {
//                             Get.back();
//                             logic.gotoEditAppointment(appointmentTable);
//                           },
//                           doctorDetails: doctorDetails,
//                           appointmentTable: appointmentTable,
//                           familyMemberId: familyMemberId,
//                         ).scaleDialog(Get.context!);
//                     },
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: AppSizes.height_9,
//                           height: AppSizes.height_9,
//                           // padding: const EdgeInsets.all(20),
//                           margin:
//                               const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
//                           decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Get.theme.colorScheme.errorContainer),
//                           child: doctorDetails.profileImage != null
//                               ? CachedNetworkImage(
//                                   imageUrl: doctorDetails.profileImage!,
//                                   imageBuilder: (context, imageProvider) =>
//                                       Container(
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       image: DecorationImage(
//                                           image: imageProvider,
//                                           fit: BoxFit.cover),
//                                     ),
//                                   ),
//                                   placeholder: (context, url) => Padding(
//                                     padding: const EdgeInsets.all(18),
//                                     child: Image.asset(Constant.genderIconList[
//                                         Constant.genderList.indexOf(
//                                             doctorDetails.gender ??
//                                                 Constant.genderList[0])]),
//                                   ),
//                                   errorWidget: (context, url, error) => Padding(
//                                     padding: const EdgeInsets.all(18),
//                                     child: Image.asset(Constant.genderIconList[
//                                         Constant.genderList.indexOf(
//                                             doctorDetails.gender ??
//                                                 Constant.genderList[0])]),
//                                   ),
//                                 )
//                               : Padding(
//                                   padding: const EdgeInsets.all(18),
//                                   child: Image.asset(Constant.genderIconList[
//                                       Constant.genderList.indexOf(
//                                           doctorDetails.gender ??
//                                               Constant.genderList[0])]),
//                                 ),
//                           // child: Image.asset(Constant.genderIconList[Constant.genderList.indexOf(doctorDetails.gender??Constant.genderList[0])]),
//                         ),
//                         SizedBox(
//                           width: AppFontSize.size_10,
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               CommonText(
//                                   text: doctorDetails.name!,
//                                   maxLines: 2,
//                                   textColor: Get.theme.colorScheme.primary,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: AppFontSize.size_14),
//                               if(doctorDetails.hospitalName!=null&&doctorDetails.hospitalName!.isNotEmpty)CommonText(
//                                   text:
//                                   '${'txtHospital'.tr} : ${doctorDetails.hospitalName}',
//                                   maxLines: 1,
//                                   textColor: Get.theme.colorScheme.onSurface,
//                                   fontWeight: FontWeight.w300,
//                                   fontSize: AppFontSize.size_10),
//                               if (doctorDetails.phoneNumber != null &&
//                                   doctorDetails.phoneNumber!.isNotEmpty)
//                                 CommonText(
//                                     text:
//                                     '${'txtPhone'.tr} : ${doctorDetails.phoneNumber}',
//                                     textColor: Get.theme.colorScheme.onSurface,
//                                     fontWeight: FontWeight.w300,
//                                     fontSize: AppFontSize.size_10),
//                             ],
//                           ),
//                         ),
//                         if(appointmentTable.isReSchedule!=null&& appointmentTable.isAccept!=null)Container(
//                           margin: EdgeInsetsDirectional.only(
//                               top: AppSizes.height_1, end: AppSizes.height_2),
//                           alignment: Alignment.topRight,
//                           child: Image.asset(
//                             appointmentTable.isAccept == 1 ? Assets.iconsIcActive : Assets.iconsIcReSchedule,
//                             width: AppSizes.width_6,
//                             height: AppSizes.width_6,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               elevation: 0,
//                               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                               padding: EdgeInsets.zero,
//                               backgroundColor: Get.theme.colorScheme.surfaceVariant,
//                               foregroundColor: Get.theme.colorScheme.primary,
//                               surfaceTintColor: Get.theme.colorScheme.primary,
//                               shape: RoundedRectangleBorder(
//                                   side: BorderSide(
//                                       color: Get.theme.colorScheme.primary),
//                                   borderRadius: const BorderRadiusDirectional.only(
//                                       topEnd: Radius.circular(25),
//                                       bottomStart: Radius.circular(25))),
//                               splashFactory: InkSplash.splashFactory),
//                           onPressed: () {
//                             logic.gotoEditAppointment(appointmentTable);
//                           },
//                           child: Image.asset(
//                             Assets.iconsIcEdit,
//                             color: Get.theme.colorScheme.primary,
//                             width: AppSizes.height_2,
//                             height: AppSizes.height_2,
//                           )),
//                     ),
//                     SizedBox(
//                       width: AppFontSize.size_5,
//                     ),
//                     Expanded(
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               elevation: 0,
//                               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                               backgroundColor: Get.theme.colorScheme.primary,
//                               foregroundColor: Get.theme.colorScheme.background,
//                               shape: RoundedRectangleBorder(
//                                   side: BorderSide(
//                                       color: Get.theme.colorScheme.primary),
//                                   borderRadius: const BorderRadiusDirectional.only(
//                                       topStart: Radius.circular(25),
//                                       bottomEnd: Radius.circular(25))),
//                               splashFactory: InkSplash.splashFactory),
//                           onPressed: () {
//                             deleteBottomSheet(Get.context!,appointmentTable);
//                           },
//                           child: Image.asset(
//                             Assets.iconsIcDeleteFill,
//                             width: AppSizes.height_2,
//                             height: AppSizes.height_2,
//                           )),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         });
//   }
//
//   Future<dynamic> deleteBottomSheet(BuildContext context, AppointmentTable appointmentTable) {
//     return showModalBottomSheet(
//         backgroundColor: Colors.transparent,
//         context: context,
//         builder: (context) => DeleteConformation(
//           title: 'txtDeleteAppointment'.tr,
//           description: 'txtAreYouSureYouWantToDeleteThisAppointment'.tr,
//           onTapDelete: () {
//             Get.find<AppointmentScreenLogic>()
//                 .deleteAppointment(appointmentTable);
//           },
//         ));
//   }
// }
