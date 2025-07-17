import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/utils.dart';

class DoctorsScreenLogic extends GetxController {
  bool isShowProgress = false;
  List<DoctorsTable> doctorsList = [];
  ScrollController listController = ScrollController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getDoctorsDataFromDatabase();
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

  Future<void> getDoctorsDataFromDatabase() async {
    doctorsList = await DataBaseHelper.instance.getDoctorsData(isList: true);
    Debug.printLog(":: ::: ::: $doctorsList");
    update([Constant.idDoctorsList]);
  }

  void gotoAddDoctor() {
    Get.toNamed(AppRoutes.addOrEditDoctor)!.then((value) {
      getDoctorsDataFromDatabase();
    });
  }

  gotoEditDoctor(DoctorsTable doctorsTable) {
    Get.toNamed(AppRoutes.addOrEditDoctor, parameters: {
      Constant.idIsEditProfile: "true",
      Constant.idMemberId: doctorsTable.dId.toString()
    })!
        .then((value) {
      getDoctorsDataFromDatabase();
    });
  }

  Future<void> deleteMember(DoctorsTable doctorsTable) async {
    doctorsTable.mIsDeleted = 1;
    doctorsTable.mIsSynced = 0;
    if (await InternetConnectivity.isInternetConnect(Get.context!)) {
      await FireStoreHelper().addOrUpdateDoctor(doctorsTable);
    }
    await DataBaseHelper.instance.updateDoctor(doctorsTable.dId!, doctorsTable);
    Get.back();
    Utils.showToast(Get.context!, "txtDoctorIsDeletedSuccessfully".tr);
    getDoctorsDataFromDatabase();
  }
}
