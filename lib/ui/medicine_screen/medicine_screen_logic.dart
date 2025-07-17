import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/database/tables/notification_table.dart';
import 'package:medinest/database/tables/shape_table.dart';
import 'package:medinest/main.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/utils.dart';

class MedicineScreenLogic extends GetxController
    with GetTickerProviderStateMixin {
  int selectedTabIndex = 0;
  List<FamilyMemberTable?> familyMembersList =
      List<FamilyMemberTable?>.empty(growable: true);
  List<MedicineTable?> medicineTableList =
      List<MedicineTable?>.empty(growable: true);
  List<ShapeTable> allShapeList = List<ShapeTable>.empty(growable: true);

  TabController? medicineTabController;

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
    medicineTabController!.index = selectedTabIndex;
    update([Constant.idHome, Constant.idMedicineScreenTab]);
  }

  Future<void> getAllFamilyMembers() async {
    familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
    medicineTabController = null;
    medicineTabController = TabController(
        length: familyMembersList
            .where((element) => element!.mIsDeleted != 1)
            .toList()
            .length,
        vsync: this);
    // medicineTabController!.addListener(() {
    //   Debug.printLog(
    //       "medicineTabController!.addListener ::: ${medicineTabController!.index}");
    //
    //   selectedTabIndex = medicineTabController!.index;
    //   update([Constant.idHome, Constant.idMedicineScreenTab]);
    // });
    allShapeList = await DataBaseHelper.instance.getAllShapesData();
    // Future.delayed(Duration(seconds: 1),() async {
    // });
    medicineTableList = await DataBaseHelper.instance.getMedicineData();

    Debug.printLog(
        ":: :::medicineTableList.length ::: ${medicineTableList.where((element) => element!.mFamilyMemberId! == 2 && element.mIsDeleted != 1).toList().length}");
    // selectedTabIndex = 0;
    update([Constant.idMedicineList, Constant.idMedicineScreenTab]);
    Get.forceAppUpdate();
  }

  Future<void> deleteMedicine(MedicineTable medicineData) async {
    medicineData.mIsDeleted = 1;
    medicineData.mIsActive = 0;
    medicineData.mIsSynced = 0;

    await DataBaseHelper.instance.updateMedicineData(
      medicineData.mId!,
      medicineData,
    );

    if (await InternetConnectivity.isInternetConnect(Get.context!)) {
      FireStoreHelper().addAndUpdateMedicine(
        medicineData.mId!.toString(),
        medicineData,
      );
    }
    // DataBaseHelper().deleteMedicineData(medicineData.mId!);
    // FireStoreHelper().deleteMedicine(medicineData.mId!);
    List<MedicineNotificationTable> notificationDataList = await DataBaseHelper
        .instance
        .getNotificationData(result: medicineData.mId);
    for (var notification in notificationDataList) {
      await flutterLocalNotificationsPlugin
          .cancel(notification.nId! + Constant.notificationStartID);
    }
    // FireStoreHelper().deleteNotificationsBatchByMid(medicineData.mId!);
    DataBaseHelper().deleteNotificationData(id: medicineData.mId!);
    Utils.showToast(Get.context!, 'txtYouHaveSuccessfullyDeletedMedicine'.tr);
    getAllFamilyMembers();
    Get.back();
  }
}
