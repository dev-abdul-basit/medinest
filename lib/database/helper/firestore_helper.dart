import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/tables/journal_history_table.dart';
import 'package:medinest/database/tables/journal_table.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_history_table.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/database/tables/user_table.dart';
import 'package:medinest/main.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/utils.dart';

class FireStoreHelper {
  /// USER TABLE
  String usersTable = "Users";
  String userId = "UserId";
  String userName = "UserName";
  String userEmail = "UserEmail";
  String userToken = "userToken";

  CollectionReference _getDataBaseTable(String tableName) {
    return MyApp.firebaseFirestore.collection(tableName);
  }

  Future onSync() async {
    if (await InternetConnectivity.isInternetConnect(Get.context!)) {
      return _getDataBaseTable(usersTable)
          .doc(Utils.getFirebaseUid())
          .get()
          .then((value) async {
        if (!value.exists) {
          Debug.printLog("NOT EXIST");
        } else {
          // syncNotificationData();
          await syncFamilyMemberData();
          await syncDoctorData();
          await syncMedicineData();
          await syncAppointment();
          syncHistoryData();
          await syncAppointmentHistoryData();

          Debug.printLog(
              "--------------<><><> ALL DATA SYNC SUCCESSFULLY ON SERVER <><><>--------------");
        }
      });
    }
  }

  syncMedicineData() async {
    var data = await _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().medicineTable)
        .get();

    final allData = data.docs.map((doc) => doc.data()).toList();
    for (var element in allData) {
      await DataBaseHelper.instance
          .insertOrUpdateMedicineData(MedicineTable.fromMap(element));
    }
  }

  syncAppointment() async {
    var data = await _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().appointmentTable)
        .get();

    final allData = data.docs.map((doc) => doc.data()).toList();
    for (var element in allData) {
      await DataBaseHelper.instance
          .insertOrUpdateAppointment(JournalTable.fromJson(element));
    }
  }

  syncHistoryData() async {
    var data = await _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().medicineHistoryTable)
        .get();

    final allData = data.docs.map((doc) => doc.data()).toList();
    for (var element in allData) {
      await DataBaseHelper.instance
          .insertOrUpdateHistoryData(MedicineHistoryTable.fromJson(element));
    }
  }

  syncAppointmentHistoryData() async {
    var data = await _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().appointmentHistoryTable)
        .get();

    final allData = data.docs.map((doc) => doc.data()).toList();
    for (var element in allData) {
      await DataBaseHelper.instance.insertOrUpdateAppointmentHistoryData(
          JournalHistoryTable.fromJson(element));
    }
  }

  syncFamilyMemberData() async {
    var data = await _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().familyMemberTable)
        .get();

    final allData = data.docs.map((doc) => doc.data()).toList();
    for (var element in allData) {
      await DataBaseHelper.instance
          .insertOrUpdateFamilyMember(FamilyMemberTable.fromJson(element));
    }
  }

  syncDoctorData() async {
    var data = await _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().doctorsTable)
        .get();

    final allData = data.docs.map((doc) => doc.data()).toList();
    for (var element in allData) {
      await DataBaseHelper.instance
          .insertOrUpdateDoctor(DoctorsTable.fromJson(element));
    }
  }

  addUser(UserTable? user) {
    return _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .get()
        .then((value) {
      if (!value.exists) {
        _getDataBaseTable(usersTable)
            .doc(Utils.getFirebaseUid())
            .set(user!.toJson())
            .then((value) {
          Debug.printLog("User Added Success");
        }).catchError((error) => Debug.printLog("Failed to add user: $error"));
      } else {
        _getDataBaseTable(usersTable)
            .doc(Utils.getFirebaseUid())
            .update(user!.toJson())
            .then((value) {
          Debug.printLog("Update User Success");
        }).catchError(
                (error) => Debug.printLog("Failed to Update user: $error"));
      }
    });
  }

  Future<bool?> addOrUpdateFamilyMember(FamilyMemberTable familyMember) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().familyMemberTable)
        .doc(familyMember.fId.toString());
    var value = await doc.get();
    if (!value.exists) {
      familyMember.mIsSynced = 1;
      return await doc.set(familyMember.toJson()).then((value) async {
        await DataBaseHelper.instance
            .updateFamilyMember(familyMember.fId!, familyMember);
        Debug.printLog("Add FamilyMemberTable Success");
        return true;
      });
    } else {
      familyMember.mIsSynced = 1;
      return await doc.update(familyMember.toJson()).then((value) async {
        await DataBaseHelper.instance
            .updateFamilyMember(familyMember.fId!, familyMember);
        Debug.printLog("Update FamilyMember Success");
        return true;
      });
    }
  }

  Future<bool?> addOrUpdateDoctor(DoctorsTable doctor) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().doctorsTable)
        .doc(doctor.dId.toString());
    var value = await doc.get();
    if (!value.exists) {
      doctor.mIsSynced = 1;
      return await doc.set(doctor.toJson()).then((value) async {
        await DataBaseHelper.instance.updateDoctor(doctor.dId!, doctor);
        Debug.printLog("Add Doctor Table Success");
        return true;
      });
    } else {
      doctor.mIsSynced = 1;
      return await doc.update(doctor.toJson()).then((value) async {
        await DataBaseHelper.instance.updateDoctor(doctor.dId!, doctor);
        Debug.printLog("Update Doctor Success");
        return true;
      });
    }
  }

  checkAndSyncExistingUser() {
    return _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .get()
        .then((value) async {
      if (value.exists) {
        Debug.printLog("checkAndSyncExistingUser",
            UserTable().fromDocumentSnapshot(value).toRawJson());
        await DataBaseHelper.instance
            .insertUser(UserTable().fromDocumentSnapshot(value));
        Preference.shared.setIsUserLogin(true);
        Preference.shared.setProfileAdded(true);
        await FireStoreHelper().onSync();
        Get.offAllNamed(AppRoutes.home,
            parameters: {Constant.idIsFromLogIn: "true"});
      } else {
        Preference.shared.setIsUserLogin(false);
        Get.toNamed(AppRoutes.addOrEditProfile,
            parameters: {Constant.idIsEditProfile: "false"});
      }
    });
  }

  addAndUpdateMedicine(String id, MedicineTable medicineData) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().medicineTable)
        .doc(id);
    var value = await doc.get();

    if (!value.exists) {
      medicineData.mIsSynced = 1;
      await doc.set(medicineData.toJson());
      await DataBaseHelper.instance
          .updateMedicineData(medicineData.mId!, medicineData);
      Debug.printLog("Add MedicineTable Success");
    } else {
      medicineData.mIsSynced = 1;
      await doc.update(medicineData.toJson());
      await DataBaseHelper.instance
          .updateMedicineData(medicineData.mId!, medicineData);
      Debug.printLog("Update MedicineTable Success");
    }
  }

  updateMedicineBatchByFId(int id) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().medicineTable)
        .where(DataBaseHelper().mFamilyMemberId, isEqualTo: id);
    var value = await doc.get();
    final batch = MyApp.firebaseFirestore.batch();
    for (var doc in value.docs) {
      batch.update(doc.reference, {DataBaseHelper().mIsDeleted: 1});
    }
    batch.commit();
  }

  updateMedicineBatchByMid(List<MedicineTable>? medicineList) async {
    final batch = MyApp.firebaseFirestore.batch();
    for (var medicine in medicineList!) {
      var doc = _getDataBaseTable(usersTable)
          .doc(Utils.getFirebaseUid())
          .collection(DataBaseHelper().medicineTable)
          .where(DataBaseHelper().mId, isEqualTo: medicine.mId);
      var value = await doc.get();
      if (value.docs.isEmpty) {
        var newDoc = _getDataBaseTable(usersTable)
            .doc(Utils.getFirebaseUid())
            .collection(DataBaseHelper().medicineTable)
            .doc(medicine.mId.toString());
        batch.set(newDoc, medicine.toJson());
      } else {
        batch.update(
            value.docs.first.reference, {DataBaseHelper().mIsSynced: 1});
      }
    }
    batch.commit();
  }

  updateMedicineHistoryBatchByHid(
      List<MedicineHistoryTable> medicineHistoryDataList) async {
    final batch = MyApp.firebaseFirestore.batch();
    for (var medicineHistory in medicineHistoryDataList) {
      var doc = _getDataBaseTable(usersTable)
          .doc(Utils.getFirebaseUid())
          .collection(DataBaseHelper().medicineHistoryTable)
          .where(DataBaseHelper().hId, isEqualTo: medicineHistory.hId);
      var value = await doc.get();
      if (value.docs.isEmpty) {
        var newDoc = _getDataBaseTable(usersTable)
            .doc(Utils.getFirebaseUid())
            .collection(DataBaseHelper().medicineHistoryTable)
            .doc(medicineHistory.hId.toString());
        batch.set(newDoc, medicineHistory.toJson());
      } else {
        batch.update(
            value.docs.first.reference, {DataBaseHelper().mIsSynced: 1});
      }
    }
    batch.commit();
  }

  updateAppointmentBatchByAid(
  List<JournalTable> appointmentDataList) async {
    final batch = MyApp.firebaseFirestore.batch();
    for (var appointmentData in appointmentDataList) {
      var doc = _getDataBaseTable(usersTable)
          .doc(Utils.getFirebaseUid())
          .collection(DataBaseHelper().appointmentTable)
          .where(DataBaseHelper().aId, isEqualTo: appointmentData.aId);
      var value = await doc.get();
      if (value.docs.isEmpty) {
        var newDoc = _getDataBaseTable(usersTable)
            .doc(Utils.getFirebaseUid())
            .collection(DataBaseHelper().appointmentTable)
            .doc(appointmentData.aId.toString());
        batch.set(newDoc, appointmentData.toJson());
      } else {
        batch.update(
            value.docs.first.reference, {DataBaseHelper().mIsSynced: 1});
      }
    }
    batch.commit();
  }

  updateAppointmentHistoryBatchByAHid(
      List<JournalHistoryTable> appointmentHistoryDataList) async {
    final batch = MyApp.firebaseFirestore.batch();
    for (var appointmentHistoryData in appointmentHistoryDataList) {
      var doc = _getDataBaseTable(usersTable)
          .doc(Utils.getFirebaseUid())
          .collection(DataBaseHelper().appointmentHistoryTable)
          .where(DataBaseHelper().ahId, isEqualTo: appointmentHistoryData.ahId);
      var value = await doc.get();
      if (value.docs.isEmpty) {
        var newDoc = _getDataBaseTable(usersTable)
            .doc(Utils.getFirebaseUid())
            .collection(DataBaseHelper().appointmentHistoryTable)
            .doc(appointmentHistoryData.ahId.toString());
        batch.set(newDoc, appointmentHistoryData.toJson());
      } else {
        batch.update(
            value.docs.first.reference, {DataBaseHelper().mIsSynced: 1});
      }
    }
    batch.commit();
  }

  updateFamilyMemberBatch(
      List<FamilyMemberTable> familyMemberDataList) async {
    final batch = MyApp.firebaseFirestore.batch();
    for (var familyMemberData in familyMemberDataList) {
      var doc = _getDataBaseTable(usersTable)
          .doc(Utils.getFirebaseUid())
          .collection(DataBaseHelper().familyMemberTable)
          .where(DataBaseHelper().fId, isEqualTo: familyMemberData.fId);
      var value = await doc.get();
      if (value.docs.isEmpty) {
        var newDoc = _getDataBaseTable(usersTable)
            .doc(Utils.getFirebaseUid())
            .collection(DataBaseHelper().familyMemberTable)
            .doc(familyMemberData.fId.toString());
        batch.set(newDoc, familyMemberData.toJson());
      } else {
        batch.update(
            value.docs.first.reference, {DataBaseHelper().mIsSynced: 1});
      }
    }
    batch.commit();
  }


  updateDoctorsBatch(
      List<DoctorsTable> doctorsDataList) async {
    final batch = MyApp.firebaseFirestore.batch();
    for (var doctorsData in doctorsDataList) {
      var doc = _getDataBaseTable(usersTable)
          .doc(Utils.getFirebaseUid())
          .collection(DataBaseHelper().doctorsTable)
          .where(DataBaseHelper().dId, isEqualTo: doctorsData.dId);
      var value = await doc.get();
      if (value.docs.isEmpty) {
        var newDoc = _getDataBaseTable(usersTable)
            .doc(Utils.getFirebaseUid())
            .collection(DataBaseHelper().doctorsTable)
            .doc(doctorsData.dId.toString());
        batch.set(newDoc, doctorsData.toJson());
      } else {
        batch.update(
            value.docs.first.reference, {DataBaseHelper().mIsSynced: 1});
      }
    }
    batch.commit();
  }

  updateAppointmentBatchByFId(int id) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().appointmentTable)
        .where(DataBaseHelper().bookedForFamilyMemberId, isEqualTo: id);
    var value = await doc.get();
    final batch = MyApp.firebaseFirestore.batch();
    for (var doc in value.docs) {
      batch.update(doc.reference, {DataBaseHelper().mIsDeleted: 1});
    }
    batch.commit();
  }

  addAndUpdateAppointment(JournalTable appointmentData) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().appointmentTable)
        .doc(appointmentData.aId!.toString());
    var value = await doc.get();

    if (!value.exists) {
      appointmentData.mIsSynced = 1;
      await doc.set(appointmentData.toJson());
      await DataBaseHelper.instance
          .updateAppointmentData(appointmentData.aId!, appointmentData);
      Debug.printLog("Add MedicineTable Success");
    } else {
      appointmentData.mIsSynced = 1;
      await doc.update(appointmentData.toJson());
      await DataBaseHelper.instance.updateAppointmentData(
        appointmentData.aId!,
        appointmentData,
      );
      Debug.printLog("Update MedicineTable Success");
    }
  }

  deleteMedicine(int id) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().medicineTable)
        .doc(id.toString());

    await doc
        .delete()
        .then((value) => Debug.printLog("Delete MedicineTable Success"))
        .catchError((error) =>
            Debug.printLog("Failed to Delete MedicineTable: $error"));
  }

  deleteAppointment(int id) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().appointmentTable)
        .doc(id.toString());

    await doc
        .delete()
        .then((value) => Debug.printLog("Delete MedicineTable Success"))
        .catchError((error) =>
            Debug.printLog("Failed to Delete MedicineTable: $error"));
  }

  deleteMedicineHistory(int id) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().medicineHistoryTable)
        .doc(id.toString());

    await doc
        .delete()
        .then((value) => Debug.printLog("Delete MedicineTable Success"))
        .catchError((error) =>
            Debug.printLog("Failed to Delete MedicineTable: $error"));
  }

  deleteAppointmentHistory(int id) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().appointmentHistoryTable)
        .doc(id.toString());

    await doc
        .delete()
        .then((value) => Debug.printLog("Delete MedicineTable Success"))
        .catchError((error) =>
            Debug.printLog("Failed to Delete MedicineTable: $error"));
  }

  Future<bool> deleteFamilyMember(int id) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().familyMemberTable)
        .doc(id.toString());

    return await doc.delete().then((value) {
      Debug.printLog("Delete Family Member Success");
      return true;
    }).catchError((error) {
      Debug.printLog("Failed to Delete Family Member: $error");
      return false;
    });
  }

  Future<bool> deleteDoctor(int id) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().doctorsTable)
        .doc(id.toString());

    return await doc.delete().then((value) {
      Debug.printLog("Delete doctor Success");
      return true;
    }).catchError((error) {
      Debug.printLog("Failed to doctor Member: $error");
      return false;
    });
  }

  addAndUpdateHistory(int id, MedicineHistoryTable historyTableData) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().medicineHistoryTable)
        .doc(id.toString());
    var value = await doc.get();

    if (!value.exists) {
      historyTableData.mIsSynced = 1;
      await doc.set(historyTableData.toJson());
      await DataBaseHelper.instance
          .updateHistoryTableData(id, historyTableData);
      Debug.printLog("Add NotificationTable Success");
    } else {
      historyTableData.mIsSynced = 1;
      await doc.update(historyTableData.toJson());
      await DataBaseHelper.instance
          .updateHistoryTableData(id, historyTableData);
      Debug.printLog("Update NotificationTable Success");
    }
  }

  addAndUpdateAppointmentHistory(
      JournalHistoryTable historyTableData) async {
    var doc = _getDataBaseTable(usersTable)
        .doc(Utils.getFirebaseUid())
        .collection(DataBaseHelper().appointmentHistoryTable)
        .doc(historyTableData.ahId.toString());
    var value = await doc.get();

    if (!value.exists) {
      historyTableData.mIsSynced = 1;
      await doc.set(historyTableData.toJson());
      await DataBaseHelper.instance
          .updateAppointmentHistoryTableData(historyTableData);
      Debug.printLog("Add updateAppointmentHistoryTableData Success");
    } else {
      historyTableData.mIsSynced = 1;
      await doc.update(historyTableData.toJson());
      await DataBaseHelper.instance
          .updateAppointmentHistoryTableData(historyTableData);
      Debug.printLog("Update updateAppointmentHistoryTableData Success");
    }
  }
}
