import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/common_subscribe_dialog.dart';
import 'package:medinest/Widgets/update_medicin_history.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_history_table.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/database/tables/shape_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

class MedicineHistoryScreenLogic extends GetxController {
  List<FamilyMemberTable?> familyMembersList =
      List<FamilyMemberTable?>.empty(growable: true);
  List<MedicineHistoryTable?> medicineHistoryTableList =
      List<MedicineHistoryTable?>.empty(growable: true);
  List<MedicineHistoryTable?> filteredMedicineHistoryTableList =
      List<MedicineHistoryTable?>.empty(growable: true);
  List<MedicineTable?> medicineTableList =
      List<MedicineTable?>.empty(growable: true);
  List<ShapeTable> allShapeList = List<ShapeTable>.empty(growable: true);
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

  void gotoAddMedicine(BuildContext context) {
    int length = Get.find<MedicineScreenLogic>()
        .medicineTableList
        .where((element) => element!.mIsDeleted != 1)
        .toList()
        .length;
    Debug.printLog('appointmentList length : $length');
    if (Preference.shared.getIsPurchase() || length < 10) {
      Get.toNamed(AppRoutes.add)!.then((value) {
        Get.find<MedicineScreenLogic>().getAllFamilyMembers();
      });
    } else {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: true,
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
    medicineTableList = await DataBaseHelper.instance.getMedicineData();
    allShapeList = await DataBaseHelper.instance.getAllShapesData();
    medicineHistoryTableList =
        await DataBaseHelper.instance.getMedicineHistoryData();
    filterHistoryList();
    Debug.printLog(":: ::: ::: $familyMembersList");
    update([Constant.idMedicineHistory, Constant.idMedicineItem]);
  }

  void onDateChanged(DateTime newSelectedDate) {
    currantDate = newSelectedDate;
    filterHistoryList();
    update([
      Constant.idMedicineHistory,
      Constant.idMedicineItem,
      Constant.idHistoryTimeLine
    ]);
  }

  editHistory(MedicineHistoryTable medicineHistoryData) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        builder: (context) => UpdateMedicineHistory(
              title: 'txtMedicineHistory'.tr,
              isMedicine: true,
              onTapTaken: () => updateHistory(
                  medicineHistoryData: medicineHistoryData, isTaken: true),
              onSkipped: () => updateHistory(
                  medicineHistoryData: medicineHistoryData, isTaken: false),
            ));
  }

  updateHistory(
      {required MedicineHistoryTable medicineHistoryData,
      required bool isTaken}) async {
    medicineHistoryData.isTaken = isTaken ? 1 : 0;
    medicineHistoryData.isSkipped = isTaken ? 0 : 1;
    medicineHistoryData.mIsSynced = 0;
    await DataBaseHelper.instance
        .updateHistoryTableData(medicineHistoryData.hId!, medicineHistoryData)
        .then((value) async {
      if (await InternetConnectivity.isInternetConnect(Get.context!)) {
        await FireStoreHelper()
            .addAndUpdateHistory(medicineHistoryData.hId!, medicineHistoryData);
      }
      medicineHistoryTableList =
          await DataBaseHelper.instance.getMedicineHistoryData();
      filterHistoryList();
      Utils.showToast(Get.context!, 'txtHistoryIsUpdated'.tr);
      Get.back();
    });
  }

  void filterHistoryList() {
    filteredMedicineHistoryTableList = medicineHistoryTableList
        .where((element) {
          DateTime historyDate = DateTime.parse(element!.takenTime!);
          return DateFormat('dd-MM-yyyy').format(historyDate) ==
              DateFormat('dd-MM-yyyy').format(currantDate);
        })
        .toList()
        .reversed
        .toList();
    update([Constant.idMedicineHistory, Constant.idMedicineItem]);
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
    for (var medicineHistoryTable in filteredMedicineHistoryTableList) {
      await DataBaseHelper.instance
          .deleteMedicineHistory(medicineHistoryTable!.hId!);
      if (await InternetConnectivity.isInternetConnect(Get.context!)) {
        FireStoreHelper().deleteMedicineHistory(medicineHistoryTable.hId!);
      }
    }
    medicineHistoryTableList =
        await DataBaseHelper.instance.getMedicineHistoryData();
    filterHistoryList();
    Utils.showToast(Get.context!, 'txtHistoryIsDeleted'.tr);
    Get.back();
  }
}
