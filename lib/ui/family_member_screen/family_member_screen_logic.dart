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
import 'package:medinest/ui/appointment_screen/journal_screen_logic.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/utils.dart';

class FamilyMemberScreenLogic extends GetxController {
  bool isShowProgress = false;

  List<FamilyMemberTable> familyMembersList = [];

  /// The current user's own "Me" profile row (owner of their own medicines).
  /// Pinned to the top of the Family tab; edited via the same screen as
  /// Settings → Edit Profile.
  int? selfMemberId;
  FamilyMemberTable? selfMember;

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
    selfMemberId = await DataBaseHelper.instance
        .ensureSelfMember(selfName: 'txtSelfProfileName'.tr);
    familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
    selfMember = familyMembersList.cast<FamilyMemberTable?>().firstWhere(
          (m) => m!.fId == selfMemberId,
          orElse: () => null,
        );
    Debug.printLog(":: ::: ::: $familyMembersList");
    update([Constant.idFamilyMemberList]);
  }

  void gotoAddMember() {
    Get.toNamed(AppRoutes.addOrEditFamilyMember)!.then((value) {
      getFamilyMemberDataFromDatabase();
    });
  }

  /// Edit the current user's own profile. Routes to the same editor as
  /// Settings → Edit Profile so "you" is managed in one place.
  void gotoEditSelf() {
    Get.toNamed(
      AppRoutes.addOrEditProfile,
      parameters: {Constant.idIsEditProfile: "true"},
    )!
        .then((value) {
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
    // Drop the deleted member from the home medicine/journal chips too.
    if (Get.isRegistered<MedicineScreenLogic>()) {
      await Get.find<MedicineScreenLogic>().getAllFamilyMembers();
    }
    if (Get.isRegistered<JournalScreenLogic>()) {
      await Get.find<JournalScreenLogic>().getAllFamilyMembers();
    }
  }
}
