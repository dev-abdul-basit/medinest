import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/common_subscribe_dialog.dart';
import 'package:medinest/Widgets/update_medicin_history.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/journal_history_table.dart';
import 'package:medinest/database/tables/journal_table.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

class AppointmentHistoryScreenLogic extends GetxController {
  List<FamilyMemberTable?> familyMembersList =
      List<FamilyMemberTable?>.empty(growable: true);
  List<JournalHistoryTable?> appointmentHistoryTableList =
      List<JournalHistoryTable?>.empty(growable: true);
  List<JournalHistoryTable?> filteredAppointmentHistoryTableList =
      List<JournalHistoryTable?>.empty(growable: true);
  List<JournalTable?> appointmentTableList =
      List<JournalTable?>.empty(growable: true);
  List<DoctorsTable?> doctorsList = List<DoctorsTable?>.empty(growable: true);
  DateTime currantDate = DateTime.now();

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

  void goToAddAppointment(BuildContext context) {
    int length = Get.find<JournalScreenLogic>()
        .journalList
        .where((element) => element!.mIsDeleted != 1)
        .toList()
        .length;
    if (Preference.shared.getIsPurchase() || length < 10) {
      Get.toNamed(AppRoutes.addOrEditJournal)!.then(
          (value) => Get.find<JournalScreenLogic>().getAllFamilyMembers());
    } else {
      showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => CommonSubscriptionDialog(
                title: 'txtSubscribeNow'.tr,
                description:
                    'You have reached the limit.\nPlease subscribe to the plan.\n(In the free version, you only have a limit of 10 medicines and appointments.)',
                image: Assets.imagesImgSuscription,
                imageWidth: AppSizes.height_35,
                onTapDelete: () {
                  Get.back();
                  Get.toNamed(AppRoutes.proVersion);
                },
              ));
    }
  }

  Future<void> getAllFamilyMembers() async {
    familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
    doctorsList = await DataBaseHelper.instance.getDoctorsData();
    appointmentTableList =
        await DataBaseHelper.instance.getAppointmentTableData();
    appointmentHistoryTableList =
        await DataBaseHelper.instance.getAppointmentHistoryData();
    filterHistoryList();

    update([Constant.idAppointmentHistory, Constant.idMedicineItem]);
  }

  void onDateChanged(DateTime newSelectedDate) {
    currantDate = newSelectedDate;
    filterHistoryList();
    update([
      Constant.idAppointmentHistory,
      Constant.idMedicineItem,
      Constant.idHistoryTimeLine
    ]);
  }

  editHistory(JournalHistoryTable appointmentHistoryTable) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        builder: (context) => UpdateMedicineHistory(
              title: 'txtAppointmentHistory'.tr,
              isMedicine: false,
              onTapTaken: () => updateHistory(
                  appointmentHistoryTable: appointmentHistoryTable,
                  isAccept: true),
              onSkipped: () => updateHistory(
                  appointmentHistoryTable: appointmentHistoryTable,
                  isAccept: false),
            ));
  }

  updateHistory(
      {required JournalHistoryTable appointmentHistoryTable,
      required bool isAccept}) async {
    appointmentHistoryTable.isAccept = isAccept ? 1 : 0;
    appointmentHistoryTable.isReSchedule = isAccept ? 0 : 1;
    appointmentHistoryTable.mIsSynced = 0;
    Debug.printLog(
        ":: :::AppointmentHistoryTable ::: ${appointmentHistoryTable.toJson()}");
    if (isAccept) {
      await DataBaseHelper.instance
          .updateAppointmentHistoryTableData(appointmentHistoryTable)
          .then((value) async {
        if (await InternetConnectivity.isInternetConnect(Get.context!)) {
          await FireStoreHelper()
              .addAndUpdateAppointmentHistory(appointmentHistoryTable);
        }
        appointmentHistoryTableList =
            await DataBaseHelper.instance.getAppointmentHistoryData();
        filterHistoryList();
        Get.back();
        Utils.showToast(Get.context!, 'txtHistoryIsUpdated'.tr);
      });
    } else {
      await DataBaseHelper.instance
          .getAppointmentTableData(
              result: appointmentHistoryTable.appointmentId!)
          .then((value) {
        JournalTable appointmentTable = value.first;
        // Get.offAllNamed(AppRoutes.home);
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.toNamed(AppRoutes.addOrEditJournal, arguments: [
            true,
            appointmentTable,
            true,
            appointmentHistoryTable
          ]);
        });
      });
    }
  }

  void filterHistoryList() {
    filteredAppointmentHistoryTableList = appointmentHistoryTableList
        .where((element) {
          DateTime historyDate = DateTime.parse(element!.acceptTime!);
          return DateFormat('dd-MM-yyyy').format(historyDate) ==
              DateFormat('dd-MM-yyyy').format(currantDate);
        })
        .toList()
        .reversed
        .toList();
    update([Constant.idAppointmentHistory, Constant.idMedicineItem]);
  }

  onDeleteHistory() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        builder: (context) => DeleteConformation(
              title: 'txtDeleteHistory'.tr,
              description: 'txtMedicineHistoryDeleteDescription'.tr,
              image: Utils.isLightTheme()
                  ? Assets.imagesImgDeleteHistory
                  : Assets.imagesImgDeleteHistoryDark,
              imageWidth: AppSizes.height_35,
              onTapDelete: deleteHistoryOfSelectedDate,
            ));
  }

  Future<void> deleteHistoryOfSelectedDate() async {
    for (var medicineHistoryTable in filteredAppointmentHistoryTableList) {
      await DataBaseHelper.instance
          .deleteAppointmentHistory(medicineHistoryTable!.ahId!);

      if (await InternetConnectivity.isInternetConnect(Get.context!)) {
        await FireStoreHelper()
            .deleteAppointmentHistory(medicineHistoryTable.ahId!);
      }
    }
    appointmentHistoryTableList =
        await DataBaseHelper.instance.getAppointmentHistoryData();
    filterHistoryList();
    Utils.showToast(Get.context!, 'txtHistoryIsDeleted'.tr);
    Get.back();
  }
}
