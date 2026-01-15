import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/appointment_history_table.dart';
import 'package:medinest/database/tables/appointment_notification_table.dart';
import 'package:medinest/database/tables/appointment_table.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/main.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/ui/home/home_controller.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/utils.dart';

class AppointmentScreenLogic extends GetxController
    with GetTickerProviderStateMixin {
  int selectedTabIndex = 0;
  List<FamilyMemberTable?> familyMembersList =
      List<FamilyMemberTable?>.empty(growable: true);
  List<DoctorsTable?> doctorsList = List<DoctorsTable?>.empty(growable: true);
  List<AppointmentTable?> appointmentList =
      List<AppointmentTable?>.empty(growable: true);
  List<AppointmentHistoryTable?> appointmentHistoryTableList =
      List<AppointmentHistoryTable?>.empty(growable: true);
  TabController? appointmentTabController;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getAllFamilyMembers();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void onTabSelected(int selectedIndex) {
    selectedTabIndex = selectedIndex;
    appointmentTabController!.index = selectedIndex;
    update([Constant.idHome, Constant.idAppointmentScreenTab]);
  }

  Future<void> getAllFamilyMembers() async {
    familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
    doctorsList = await DataBaseHelper.instance.getDoctorsData();
    appointmentTabController = null;
    appointmentTabController = TabController(
        length: familyMembersList
            .where((element) => element!.mIsDeleted != 1)
            .toList()
            .length,
        vsync: this);
    appointmentHistoryTableList =
        await DataBaseHelper.instance.getAppointmentHistoryData();
    appointmentList = await DataBaseHelper.instance.getAppointmentTableData();
    Debug.printLog(
        ":: appointmentHistoryTableList.isNotEmpty1 ::: ${appointmentHistoryTableList.isNotEmpty}");
    for (var appointmentTable in appointmentList) {
      if (appointmentHistoryTableList.isNotEmpty) {
        List<AppointmentHistoryTable?> tempAppointmentHistoryTableList =
            List<AppointmentHistoryTable?>.empty(growable: true);
        tempAppointmentHistoryTableList = appointmentHistoryTableList
            .where(
                (element) => element!.appointmentId! == appointmentTable!.aId)
            .toList()
          ..sort((a, b) => DateTime.parse(b!.acceptTime!)
              .compareTo(DateTime.parse(a!.acceptTime!)));
        Debug.printLog(
            ":: appointmentHistoryTableList.isNotEmpty2 ::: ${tempAppointmentHistoryTableList.isNotEmpty}");
        // if (tempAppointmentHistoryTableList.isNotEmpty) {
        //   appointmentTable!.isAccept =
        //       tempAppointmentHistoryTableList.first!.isAccept;
        //   appointmentTable.isReSchedule =
        //       tempAppointmentHistoryTableList.first!.isReSchedule;
        //   Debug.printLog(
        //       ":: appointmentTable.isReSchedule ::: ${appointmentTable.isReSchedule}");
        // }
      }

      update([Constant.idAppointmentListItem]);
    }

    Get.find<HomeController>().update([
      Constant.idHome,
      Constant.idAppointmentList,
      Constant.idAppointmentScreenTab
    ]);
    Get.forceAppUpdate();
  }

  void gotoEditAppointment(AppointmentTable appointmentTable) {
    Get.toNamed(AppRoutes.addOrEditAppointment,
            arguments: [true, appointmentTable, false, null])!
        .then((value) => getAllFamilyMembers());
  }

  Future<void> deleteAppointment(AppointmentTable appointmentTable) async {
    appointmentTable.mIsDeleted = 1;
    appointmentTable.mIsSynced = 0;
    await DataBaseHelper.instance.updateAppointmentData(
      appointmentTable.aId!,
      appointmentTable,
    );

    if (await InternetConnectivity.isInternetConnect(Get.context!)) {
      FireStoreHelper().addAndUpdateAppointment(appointmentTable);
    }

    // DataBaseHelper().deleteAppointment(appointmentTable.aId!);
    // FireStoreHelper().deleteAppointment(appointmentTable.aId!);
    List<AppointmentNotificationTable> notificationDataList =
        await DataBaseHelper.instance
            .getAppointmentNotificationData(result: appointmentTable.aId!);
    for (var notification in notificationDataList) {
      await flutterLocalNotificationsPlugin.cancel(notification.anId!);
    }

    await DataBaseHelper.instance
        .deleteAppointmentNotificationData(id: appointmentTable.aId!);
    Utils.showToast(
        Get.context!, 'txtYouHaveSuccessfullyDeletedAppointment'.tr);
    getAllFamilyMembers();
    Get.back();
  }
}
