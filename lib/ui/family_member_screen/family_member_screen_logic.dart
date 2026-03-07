import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/journal_notification_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/notification_table.dart';
import 'package:medinest/main.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/utils.dart';

class FamilyMemberScreenLogic extends GetxController {
  bool isShowProgress = false;

  List<FamilyMemberTable> familyMembersList = [];

  ScrollController listController = ScrollController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getFamilyMemberDataFromDatabase();
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

  Future<void> getFamilyMemberDataFromDatabase() async {
    familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
    Debug.printLog(":: ::: ::: $familyMembersList");
    update([Constant.idFamilyMemberList]);
  }

  void gotoAddMember() {
    Get.toNamed(AppRoutes.addOrEditFamilyMember)!.then((value) {
      getFamilyMemberDataFromDatabase();
    });
  }

  void gotoEditMember(FamilyMemberTable familyMember) {
    Get.toNamed(AppRoutes.addOrEditFamilyMember, parameters: {
      Constant.idIsEditProfile: "true",
      Constant.idMemberId: familyMember.fId.toString()
    })!
        .then((value) {
      getFamilyMemberDataFromDatabase();
    });
  }

  Future<void> deleteMember(FamilyMemberTable familyMember) async {
    isShowProgress = true;
    update([Constant.idProVersionProgress]);
    Get.back();
    DataBaseHelper().updateMedicineDataByFid(familyMember.fId!);

    if (await InternetConnectivity.isInternetConnect(Get.context!)) {
      FireStoreHelper().updateMedicineBatchByFId(familyMember.fId!);
    }
    List<MedicineNotificationTable> notificationDataList = await DataBaseHelper
        .instance
        .getNotificationData(fId: familyMember.fId!);
    for (var notification in notificationDataList) {
      flutterLocalNotificationsPlugin
          .cancel(notification.nId! + Constant.notificationStartID);
    }
    DataBaseHelper().deleteNotificationData(fId: familyMember.fId!);

    DataBaseHelper().updateAppointmentDataByFId(familyMember.fId!);

    if (await InternetConnectivity.isInternetConnect(Get.context!)) {
      FireStoreHelper().updateAppointmentBatchByFId(familyMember.fId!);
    }

    List<JournalNotificationTable> appointmentNotificationList =
        await DataBaseHelper.instance
            .getAppointmentNotificationData(fId: familyMember.fId);
    for (var notification in appointmentNotificationList) {
      flutterLocalNotificationsPlugin.cancel(notification.anId!);
    }
    DataBaseHelper().deleteAppointmentNotificationData(fId: familyMember.fId);

    familyMember.mIsDeleted = 1;
    familyMember.mIsSynced = 1;
    await DataBaseHelper.instance.updateFamilyMember(
      familyMember.fId!,
      familyMember,
    );

    if (await InternetConnectivity.isInternetConnect(Get.context!)) {
      await FireStoreHelper().addOrUpdateFamilyMember(familyMember);
    }

    Utils.showToast(Get.context!, "txtFamilyMemberIsDeletedSuccessfully".tr);
    isShowProgress = false;
    update([Constant.idProVersionProgress]);
    getFamilyMemberDataFromDatabase();
  }
}
