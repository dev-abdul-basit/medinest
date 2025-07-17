import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/date_timeline.dart';
import 'package:medinest/Widgets/no_history_widget.dart';
import 'package:medinest/database/tables/appointment_history_table.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

import 'appointment_history_screen_logic.dart';

class AppointmentHistoryScreenPage extends StatelessWidget {
  const AppointmentHistoryScreenPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Get.theme.colorScheme.background,
      child: Column(
        children: [
          Container(
            width: AppSizes.fullWidth,
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.onPrimaryContainer,
              borderRadius: const BorderRadiusDirectional.only(
                bottomEnd: Radius.circular(35),
                bottomStart: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(
                      0.2),
                  spreadRadius: 0.5,
                  blurRadius: 7,
                  offset: const Offset(0, 5), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    GetBuilder<AppointmentHistoryScreenLogic>(
                        id:Constant.idHistoryTimeLine,
                        builder: (logic) {
                          return DateTimeline(
                            onDateChange: logic.onDateChanged,
                            focusDate: logic.currantDate,
                          );
                        }),
                    Positioned(
                        bottom: 15,
                        right: 30,
                        child: GetBuilder<AppointmentHistoryScreenLogic>(
                            id: Constant.idAppointmentHistory,
                            builder: (logic) {
                          return InkWell(
                            onTap: logic.filteredAppointmentHistoryTableList.isNotEmpty?logic.onDeleteHistory:null,
                            child: Image.asset(
                              Assets.iconsIcDeleteHistory,
                              color: logic.filteredAppointmentHistoryTableList.isNotEmpty?Get.theme.colorScheme.secondary:Get.theme.colorScheme.surface,
                              height: AppSizes.width_5_5,
                              width: AppSizes.width_5_5,
                            ),
                          );
                        }))
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: GetBuilder<AppointmentHistoryScreenLogic>(
                id: Constant.idAppointmentHistory,
                builder: (logic) {
                  return logic.filteredAppointmentHistoryTableList.isNotEmpty
                      ? ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: AppFontSize.size_16,
                        horizontal: AppFontSize.size_4),
                    itemCount: logic.filteredAppointmentHistoryTableList.length,
                    itemBuilder: (context, index) {
                      return appointment(appointmentHistoryTable: logic
                          .filteredAppointmentHistoryTableList[index]!);
                    },
                  )
                      : NoHistoryWidget(
                    image: Assets.imagesImgNoHistory,
                    text: 'txtHistoryNotFound'.tr,
                    description: 'txtHistoryNotFoundDescription'.tr,
                    buttonText: 'txtCreateAppointment'.tr,
                    onTapCreate: () {
                      logic.goToAddAppointment(context);
                    },
                  );
                }),
          )
        ],
      ),
    );
  }

  appointment({AppointmentHistoryTable? appointmentHistoryTable}) {
    return GetBuilder<AppointmentHistoryScreenLogic>(builder: (logic) {
      DoctorsTable doctorDetails = logic.doctorsList
          .where((element) =>
      element!.dId! == appointmentHistoryTable!.doctorId!)
          .toList()
          .first!;
      // AppointmentTable? appointmentTable =
      //     logic.appointmentTableList
      //         .where((element) =>
      //     element!.aId! == appointmentHistoryTable!.appointmentId!)
      //         .first;
      DateTime startDate = DateTime.parse(appointmentHistoryTable!.acceptTime!);
      String time = DateFormat('hh:mm a').format(startDate);
      // TimeOfDay times = NotificationHelper()
      //     .parseTimeList(appointmentTable!.appointmentTime!)
      //     .first;
      return InkWell(
        onTap: () => logic.editHistory(appointmentHistoryTable),
        child: Container(
          margin: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surfaceVariant,
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Get.theme.colorScheme.primary.withOpacity(0.2),
                spreadRadius: 0.5,
                blurRadius: 7,
                offset: const Offset(0, 5), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSizes.height_9,
                    height: AppSizes.height_9,
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsetsDirectional.fromSTEB(15, 0, 0, 0),
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: Get.theme.colorScheme.errorContainer),
                    child: Image.asset(
                        Constant.genderIconList[Constant.genderList.indexOf(
                            doctorDetails.gender ?? Constant.genderList[0])]),
                  ),
                  SizedBox(
                    width: AppFontSize.size_10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonText(
                            text: doctorDetails.name!,
                            textColor: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: AppFontSize.size_14),
                        if(doctorDetails.hospitalName != null && doctorDetails
                            .hospitalName!.isNotEmpty)CommonText(
                            text: '${doctorDetails.hospitalName}',
                            maxLines: 1,
                            textColor: Get.theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w300,
                            fontSize: AppFontSize.size_10),
                        SizedBox(height: AppSizes.height_1),
                        Row(
                          children: [
                            Image.asset(Assets.iconsIcUserName,
                                color: Get.theme.colorScheme.onSurface,
                                height: AppSizes.width_4_5,
                                width: AppSizes.width_4_5),
                            SizedBox(width: AppSizes.width_2),
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth: AppSizes.fullWidth / 2.3),
                              child: CommonText(
                                  text: 'Booked For ${appointmentHistoryTable
                                      .appointmentFor}',
                                  textColor: Get.theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w300,
                                  fontSize: AppFontSize.size_11),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.height_1),
                        Row(
                          children: [
                            Image.asset(Assets.iconsIcWatch,
                                color: Get.theme.colorScheme.onSurface,
                                height: AppSizes.width_4_5,
                                width: AppSizes.width_4_5),
                            SizedBox(width: AppSizes.width_2),
                            CommonText(
                                text: time, //times.format(Get.context!),
                                textColor: Get.theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w300,
                                fontSize: AppFontSize.size_11),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    appointmentHistoryTable.isAccept == 1
                        ? Assets.iconsIcActive
                        : Assets.iconsIcReSchedule,
                    width: AppSizes.width_6,
                    height: AppSizes.width_6,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
