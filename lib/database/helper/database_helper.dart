import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:medinest/database/tables/appointment_history_table.dart';
import 'package:medinest/database/tables/appointment_notification_table.dart';
import 'package:medinest/database/tables/appointment_table.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_history_table.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/database/tables/notification_table.dart';
import 'package:medinest/database/tables/shape_table.dart';
import 'package:medinest/database/tables/user_table.dart';
import 'package:medinest/utils/debug.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  static final DataBaseHelper instance = DataBaseHelper.internal();

  factory DataBaseHelper() => instance;

  Database? _db;

  DataBaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await init();
    return _db!;
  }

  init() async {
    _db = null;
    var dbPath = await getDatabasesPath();

    String dbPathPillReminder = path.join(dbPath, "PillReminder2.db");

    bool dbExistsEnliven = await io.File(dbPathPillReminder).exists();

    if (!dbExistsEnliven) {
      ByteData data = await rootBundle.load(
        path.join("assets/database", "PillReminder2.db"),
      );
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await io.File(dbPathPillReminder).writeAsBytes(bytes, flush: true);
    }

    return _db = await openDatabase(dbPathPillReminder);
  }

  String medicineTable = "MedicineTable";
  String appointmentTable = "AppointmentTable";
  String appointmentNotificationTable = "AppointmentNotificationTable";
  String medicineHistoryTable = "MedicineHistoryTable";
  String appointmentHistoryTable = "AppointmentHistoryTable";
  String notificationTable = "MedicineNotificationTable";
  String userTable = "UserTable";
  String familyMemberTable = "FamilyMemberTable";
  String doctorsTable = "DoctorsTable";
  String shapeTable = "ShapeTable";
  String mId = "mId";
  String aId = "aId";
  String fId = "fId";
  String dId = "dId";
  String sId = "sId";
  String notificationMid = "notificationMid";
  String nNotificationTimeStamp = "nNotificationTimeStamp";
  String appointmentNotificationTimeStamp = "appointmentNotificationTimeStamp";
  String nIsActive = "nIsActive";
  String appointmentId = "AppointmentId";
  String mFamilyMemberId = "mFamilyMemberId";
  String nFamilyMemberId = "nFamilyMemberId";
  String doctorId = "DoctorId";
  String bookedForFamilyMemberId = "BookedForFamilyMemberId";
  String mIsDeleted = "mIsDeleted";
  String mIsSynced = "mIsSynced";
  String mIsActive = "mIsActive";
  String nId = "nId";
  String anId = "anId";
  String email = "Email";
  String hId = "hId";
  String ahId = "ahId";
  String uId = "uId";

  Future<int> insertUser(UserTable userData) async {
    var dbClient = await db;

    var result = await dbClient.insert(userTable, userData.toJson());

    Debug.printLog("insert UserData res: $result");
    return result;
  }

  Future<int> insertFamilyMember(FamilyMemberTable familyMember) async {
    var dbClient = await db;

    var result = await dbClient.insert(
      familyMemberTable,
      familyMember.toJson(),
    );

    Debug.printLog("insert familyMember res: $result");
    return result;
  }

  Future<int> insertDoctor(DoctorsTable doctor) async {
    var dbClient = await db;

    var result = await dbClient.insert(doctorsTable, doctor.toJson());

    Debug.printLog("insert DoctorsTable res: $result");
    return result;
  }

  Future<int> updateUser(UserTable userData) async {
    var dbClient = await db;

    var result = await dbClient.update(
      userTable,
      userData.toJson(),
      where: '$uId = ?',
      whereArgs: [userData.uId],
    );

    Debug.printLog("insert UserData res: $result");
    return result;
  }

  Future<List<UserTable>> getUserData([String? userEmail]) async {
    var dbClient = await db;
    List<UserTable> userDataList = [];
    Debug.printLog("userEmail :$userEmail");
    List<Map<String, dynamic>> maps = await dbClient.query(
      userTable,
      where: '$email = ?',
      whereArgs: [userEmail],
    );
    Debug.printLog("maps.isNotEmpty :${maps.isNotEmpty}");
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var userData = UserTable.fromJson(answer);
        userDataList.add(userData);
      }
    }
    return userDataList;
  }

  Future<List<FamilyMemberTable>> getFamilyMemberData([
    int? result,
    bool isNotSynced = false,
  ]) async {
    var dbClient = await db;
    List<FamilyMemberTable> familyMemberDataList = [];
    Debug.printLog('getFamilyMember: $result');
    List<Map<String, dynamic>> maps = result != null
        ? await dbClient.query(
            familyMemberTable,
            where: "$fId = ?",
            whereArgs: [result],
            limit: 1,
          )
        : isNotSynced
        ? await dbClient.query(
            familyMemberTable,
            where: "$mIsSynced = ?",
            whereArgs: [0],
          )
        : await dbClient.query(familyMemberTable);
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var familyMemberData = FamilyMemberTable.fromJson(answer);
        familyMemberDataList.add(familyMemberData);
      }
    }
    return familyMemberDataList;
  }

  Future<List<DoctorsTable>> getDoctorsData({
    int? result,
    bool isList = false,
    bool isNotSynced = false,
  }) async {
    var dbClient = await db;
    List<DoctorsTable> doctorsDataList = [];
    List<Map<String, dynamic>> maps = result != null
        ? await dbClient.query(
            doctorsTable,
            where: "$dId = ?",
            whereArgs: [result],
            limit: 1,
          )
        : isList
        ? await dbClient.query(
            doctorsTable,
            where: "$mIsDeleted != ?",
            whereArgs: [1],
          )
        : isNotSynced
        ? await dbClient.query(
            doctorsTable,
            where: "$mIsSynced != ?",
            whereArgs: [0],
          )
        : await dbClient.query(doctorsTable);
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var doctorsData = DoctorsTable.fromJson(answer);
        doctorsDataList.add(doctorsData);
      }
    }
    return doctorsDataList;
  }

  Future<List<ShapeTable>> getAllShapesData([int? result]) async {
    var dbClient = await db;
    List<ShapeTable> shapeDataList = [];
    List<Map<String, dynamic>> maps = result != null
        ? await dbClient.query(
            shapeTable,
            where: "$sId = ?",
            whereArgs: [result],
            limit: 1,
          )
        : await dbClient.query(shapeTable);
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var shapeData = ShapeTable.fromJson(answer);
        shapeDataList.add(shapeData);
      }
    }
    return shapeDataList;
  }

  Future<int> insertHistoryData(MedicineHistoryTable historyTableData) async {
    var dbClient = await db;

    var result = await dbClient.insert(
      medicineHistoryTable,
      historyTableData.toJson(),
    );

    Debug.printLog("insert HistoryData res: $result");
    return result;
  }

  Future<int> insertAppointmentHistoryData(
    AppointmentHistoryTable historyTableData,
  ) async {
    var dbClient = await db;

    var result = await dbClient.insert(
      appointmentHistoryTable,
      historyTableData.toJson(),
    );

    Debug.printLog("insert appointmentHistoryTable res: $result");
    return result;
  }

  Future<int> insertMedicineData(MedicineTable medicineData) async {
    var dbClient = await db;

    var result = await dbClient.insert(medicineTable, medicineData.toJson());

    Debug.printLog("insert MedicineData res: $result");
    return result;
  }

  Future<int> insertAppointment(AppointmentTable appointmentData) async {
    var dbClient = await db;

    var result = await dbClient.insert(
      appointmentTable,
      appointmentData.toJson(),
    );

    Debug.printLog("insert MedicineData res: $result");
    return result;
  }

  Future<int> insertOrUpdateMedicineData(MedicineTable medicineData) async {
    var dbClient = await db;

    var result = await dbClient.insert(
      medicineTable,
      medicineData.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result == 0) {
      // The row already exists, so we need to update it.
      var updateResult = await dbClient.update(
        medicineTable,
        medicineData.toJson(),
        where: "$mId = ?",
        whereArgs: [medicineData.mId],
      );
      return updateResult;
    } else {
      return result;
    }
  }

  Future<int> insertOrUpdateAppointment(
    AppointmentTable appointmentData,
  ) async {
    var dbClient = await db;
    var result = await dbClient.insert(
      appointmentTable,
      appointmentData.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result == 0) {
      // The row already exists, so we need to update it.
      var updateResult = await dbClient.update(
        appointmentTable,
        appointmentData.toJson(),
        where: "$aId = ?",
        whereArgs: [appointmentData.aId],
      );
      return updateResult;
    } else {
      return result;
    }
  }

  Future<int> insertOrUpdateNotificationData(
    MedicineNotificationTable notificationData,
  ) async {
    var dbClient = await db;
    List<Map<String, Object?>> dataList = await dbClient.query(
      notificationTable,
      where: '$nId = ?',
      whereArgs: [notificationData.nId],
    );
    if (dataList.isEmpty) {
      var result = await dbClient.insert(
        notificationTable,
        notificationData.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } else {
      await dbClient.update(
        notificationTable,
        notificationData.toJson(),
        where: "$nId = ?",
        whereArgs: [notificationData.nId],
      );
      return notificationData.nId!;
    }
  }

  Future<int> insertOrUpdateAppointmentNotificationData(
    AppointmentNotificationTable notificationData,
  ) async {
    var dbClient = await db;
    List<Map<String, Object?>> dataList = await dbClient.query(
      appointmentNotificationTable,
      where: '$anId = ?',
      whereArgs: [notificationData.anId],
    );
    if (dataList.isEmpty) {
      var result = await dbClient.insert(
        appointmentNotificationTable,
        notificationData.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } else {
      await dbClient.update(
        appointmentNotificationTable,
        notificationData.toJson(),
        where: "$anId = ?",
        whereArgs: [notificationData.anId],
      );
      return notificationData.anId!;
    }
  }

  Future<int> insertOrUpdateHistoryData(
    MedicineHistoryTable historyData,
  ) async {
    var dbClient = await db;
    List<Map<String, Object?>> dataList = await dbClient.query(
      medicineHistoryTable,
      where: '$hId = ?',
      whereArgs: [historyData.hId],
    );
    if (dataList.isEmpty) {
      var result = await dbClient.insert(
        medicineHistoryTable,
        historyData.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } else {
      await dbClient.update(
        medicineHistoryTable,
        historyData.toJson(),
        where: "$hId = ?",
        whereArgs: [historyData.hId],
      );
      return historyData.hId!;
    }
  }

  Future<int> insertOrUpdateAppointmentHistoryData(
    AppointmentHistoryTable historyData,
  ) async {
    var dbClient = await db;
    List<Map<String, Object?>> dataList = await dbClient.query(
      appointmentHistoryTable,
      where: '$ahId = ?',
      whereArgs: [historyData.ahId],
    );
    if (dataList.isEmpty) {
      var result = await dbClient.insert(
        appointmentHistoryTable,
        historyData.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } else {
      await dbClient.update(
        appointmentHistoryTable,
        historyData.toJson(),
        where: "$ahId = ?",
        whereArgs: [historyData.ahId],
      );
      return historyData.ahId!;
    }
  }

  Future<int> insertOrUpdateFamilyMember(FamilyMemberTable familyMember) async {
    var dbClient = await db;
    List<Map<String, Object?>> dataList = await dbClient.query(
      familyMemberTable,
      where: '$fId = ?',
      whereArgs: [familyMember.fId],
    );
    if (dataList.isEmpty) {
      var result = await dbClient.insert(
        familyMemberTable,
        familyMember.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } else {
      await dbClient.update(
        familyMemberTable,
        familyMember.toJson(),
        where: "$fId = ?",
        whereArgs: [familyMember.fId],
      );
      return familyMember.fId!;
    }
  }

  Future<int> insertOrUpdateDoctor(DoctorsTable doctor) async {
    var dbClient = await db;
    List<Map<String, Object?>> dataList = await dbClient.query(
      doctorsTable,
      where: '$dId = ?',
      whereArgs: [doctor.dId],
    );
    if (dataList.isEmpty) {
      var result = await dbClient.insert(
        doctorsTable,
        doctor.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } else {
      await dbClient.update(
        doctorsTable,
        doctor.toJson(),
        where: "$dId = ?",
        whereArgs: [doctor.dId],
      );
      return doctor.dId!;
    }
  }

  Future<List<MedicineTable>> getMedicineData({
    int? result,
    int? fId,
    bool isNotDeletedOnly = false,
    bool isNotSynced = false,
  }) async {
    var dbClient = await db;
    List<MedicineTable> medicineDataList = [];
    List<Map<String, dynamic>> maps = result != null
        ? await dbClient.query(
            medicineTable,
            where: "$mId = ?",
            whereArgs: [result],
            limit: 1,
          )
        : fId != null
        ? await dbClient.query(
            medicineTable,
            where: "$mFamilyMemberId = ?",
            whereArgs: [fId],
          )
        : isNotDeletedOnly
        ? await dbClient.query(
            medicineTable,
            where: "$mIsDeleted = ?",
            whereArgs: [0],
          )
        : isNotSynced
        ? await dbClient.query(
            medicineTable,
            where: "$mIsSynced = ?",
            whereArgs: [0],
          )
        : await dbClient.query(medicineTable);
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var medicineData = MedicineTable.fromJson(answer);
        medicineDataList.add(medicineData);
      }
    }
    return medicineDataList;
  }

  Future<List<AppointmentTable>> getAppointmentTableData({
    int? result, // <-- keep this (aId filter)
    bool isNotSynced = false,
  }) async {
    final dbClient = await db;
    List<Map<String, dynamic>> maps;
    if (result != null) {
      maps = await dbClient.query(
        appointmentTable,
        where: "aId = ?",
        whereArgs: [result],
      );
    } else if (isNotSynced) {
      maps = await dbClient.query(
        appointmentTable,
        where: "mIsSynced = ?",
        whereArgs: [0],
      );
    } else {
      maps = await dbClient.query(appointmentTable);
    }

    return maps.map((row) => AppointmentTable.fromJson(row)).toList();
  }

  // Future<List<AppointmentTable>> getAppointmentTableData(
  //     {int? result, int? dId, int? fId, bool isNotSynced = false}) async {
  //   var dbClient = await db;
  //   List<AppointmentTable> appointmentTableDataList = [];
  //   List<Map<String, dynamic>> maps = result != null
  //       ? await dbClient
  //           .query(appointmentTable, where: "$aId = ?", whereArgs: [result])
  //       : dId != null
  //           ? await dbClient.query(appointmentTable,
  //               where: "$doctorId = ?", whereArgs: [dId])
  //           : fId != null
  //               ? await dbClient.query(appointmentTable,
  //                   where: "$bookedForFamilyMemberId = ?", whereArgs: [fId])
  //               : isNotSynced
  //                   ? await dbClient.query(appointmentTable,
  //                       where: "$mIsSynced = ?", whereArgs: [0])
  //                   : await dbClient.query(appointmentTable);
  //   if (maps.isNotEmpty) {
  //     for (var answer in maps) {
  //       var appointmentTableData = AppointmentTable.fromJson(answer);
  //       appointmentTableDataList.add(appointmentTableData);
  //     }
  //   }
  //   return appointmentTableDataList;
  // }

  Future<List<MedicineHistoryTable>> getMedicineHistoryData({
    int? result,
    bool isNotSynced = false,
  }) async {
    var dbClient = await db;
    List<MedicineHistoryTable> historyTableDataList = [];
    List<Map<String, dynamic>> maps = result != null
        ? await dbClient.query(
            medicineHistoryTable,
            where: "$mId = ?",
            whereArgs: [result],
            limit: 1,
          )
        : isNotSynced
        ? await dbClient.query(
            medicineHistoryTable,
            where: "$mIsSynced = ?",
            whereArgs: [0],
          )
        : await dbClient.query(medicineHistoryTable);
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var historyTableData = MedicineHistoryTable.fromJson(answer);
        historyTableDataList.add(historyTableData);
      }
    }
    return historyTableDataList;
  }

  Future<List<AppointmentHistoryTable>> getAppointmentHistoryData({
    int? result,
    bool isNotSynced = false,
  }) async {
    var dbClient = await db;
    List<AppointmentHistoryTable> historyTableDataList = [];
    List<Map<String, dynamic>> maps = result != null
        ? await dbClient.query(
            appointmentHistoryTable,
            where: "$ahId = ?",
            whereArgs: [result],
            limit: 1,
          )
        : isNotSynced
        ? await dbClient.query(
            appointmentHistoryTable,
            where: "$mIsSynced = ?",
            whereArgs: [0],
          )
        : await dbClient.query(appointmentHistoryTable);
    Debug.printLog(
      ":: appointmentHistoryTableList.isNotEmpty ::: ${maps.toString()}",
    );
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var historyTableData = AppointmentHistoryTable.fromJson(answer);
        historyTableDataList.add(historyTableData);
      }
    }
    return historyTableDataList;
  }

  Future<int?> updateMedicineData(int id, MedicineTable medicineData) async {
    var dbClient = await db;
    var result = await dbClient.update(
      medicineTable,
      medicineData.toJson(),
      where: "$mId = ?",
      whereArgs: [id],
    );
    Debug.printLog("updateMedicineData result: $result");
    return result;
  }

  Future<int?> updateMedicineDataByFid(int id) async {
    var dbClient = await db;
    var result = await dbClient.update(
      medicineTable,
      {mIsDeleted: 1, mIsActive: 0},
      where: "$mFamilyMemberId = ?",
      whereArgs: [id],
    );
    Debug.printLog("updateMedicineData result: $result");
    return result;
  }

  Future<int?> updateAllMedicineDataToSync() async {
    var dbClient = await db;
    var result = await dbClient.update(
      medicineTable,
      {mIsSynced: 1},
      where: "$mIsSynced = ?",
      whereArgs: [0],
    );
    Debug.printLog("updateMedicineData result: $result");
    return result;
  }

  Future<int?> updateAllMedicineHistoryDataToSync() async {
    var dbClient = await db;
    var result = await dbClient.update(
      medicineHistoryTable,
      {mIsSynced: 1},
      where: "$mIsSynced = ?",
      whereArgs: [0],
    );
    Debug.printLog("updateMedicineData result: $result");
    return result;
  }

  Future<int?> updateAllAppointmentDataToSync() async {
    var dbClient = await db;
    var result = await dbClient.update(
      appointmentTable,
      {mIsSynced: 1},
      where: "$mIsSynced = ?",
      whereArgs: [0],
    );
    Debug.printLog("updateMedicineData result: $result");
    return result;
  }

  Future<int?> updateAllAppointmentHistoryDataToSync() async {
    var dbClient = await db;
    var result = await dbClient.update(
      appointmentHistoryTable,
      {mIsSynced: 1},
      where: "$mIsSynced = ?",
      whereArgs: [0],
    );
    Debug.printLog("updateMedicineData result: $result");
    return result;
  }

  Future<int?> updateAllFamilyMemberDataToSync() async {
    var dbClient = await db;
    var result = await dbClient.update(
      familyMemberTable,
      {mIsSynced: 1},
      where: "$mIsSynced = ?",
      whereArgs: [0],
    );
    Debug.printLog("updateMedicineData result: $result");
    return result;
  }

  Future<int?> updateAllDoctorsDataToSync() async {
    var dbClient = await db;
    var result = await dbClient.update(
      doctorsTable,
      {mIsSynced: 1},
      where: "$mIsSynced = ?",
      whereArgs: [0],
    );
    Debug.printLog("updateMedicineData result: $result");
    return result;
  }

  Future<int?> updateAppointmentData(
    int id,
    AppointmentTable appointmentData,
  ) async {
    var dbClient = await db;
    var result = await dbClient.update(
      appointmentTable,
      appointmentData.toJson(),
      where: "$aId = ?",
      whereArgs: [id],
    );
    Debug.printLog("updateAppointmentData result: $result");
    return result;
  }

  Future<int?> updateAppointmentDataByFId(int id) async {
    var dbClient = await db;
    var result = await dbClient.update(
      appointmentTable,
      {mIsDeleted: 1},
      where: "$bookedForFamilyMemberId = ?",
      whereArgs: [id],
    );
    Debug.printLog("updateAppointmentData result: $result");
    return result;
  }

  Future<int> updateFamilyMember(int id, FamilyMemberTable familyMember) async {
    var dbClient = await db;
    var result = await dbClient.update(
      familyMemberTable,
      familyMember.toJson(),
      where: "$fId = ?",
      whereArgs: [id],
    );
    Debug.printLog("updateFamilyMember result: $result");
    return result;
  }

  Future<int> updateDoctor(int id, DoctorsTable doctor) async {
    var dbClient = await db;
    var result = await dbClient.update(
      doctorsTable,
      doctor.toJson(),
      where: "$dId = ?",
      whereArgs: [id],
    );
    Debug.printLog("update Doctor result: $result");
    return result;
  }

  Future<int?> updateNotificationData(
    int id,
    MedicineNotificationTable notificationData,
  ) async {
    var dbClient = await db;
    var result = await dbClient.update(
      notificationTable,
      notificationData.toJson(),
      where: "$nId = ?",
      whereArgs: [id],
    );

    Debug.printLog("updateMedicineData result: $result");
    return result;
  }

  Future<int?> updateHistoryTableData(
    int id,
    MedicineHistoryTable historyTableData,
  ) async {
    var dbClient = await db;
    var result = await dbClient.update(
      medicineHistoryTable,
      historyTableData.toJson(),
      where: "$hId = ?",
      whereArgs: [id],
    );

    Debug.printLog("updateHistoryTableData result: $result");
    return result;
  }

  Future<int?> updateAppointmentHistoryTableData(
    AppointmentHistoryTable historyTableData,
  ) async {
    var dbClient = await db;
    Debug.printLog("updateAppointment result: ${historyTableData.toJson()}");
    var result = await dbClient.update(
      appointmentHistoryTable,
      historyTableData.toJson(),
      where: "$ahId = ?",
      whereArgs: [historyTableData.ahId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    Debug.printLog("updateAppointment result: $result");
    return result;
  }

  Future<int?> deleteMedicineData([int? id]) async {
    var dbClient = await db;
    var result = id != null
        ? await dbClient.delete(
            medicineTable,
            where: "$mId = ?",
            whereArgs: [id],
          )
        : await dbClient.delete(medicineTable);

    Debug.printLog("deleteReminder -->>$result");
    return result;
  }

  Future<int?> deleteAppointment([int? id]) async {
    var dbClient = await db;
    var result = id != null
        ? await dbClient.delete(
            appointmentTable,
            where: "$aId = ?",
            whereArgs: [id],
          )
        : await dbClient.delete(appointmentTable);

    Debug.printLog("deleteReminder -->>$result");
    return result;
  }

  Future<int?> deleteMedicineHistory([int? id]) async {
    var dbClient = await db;
    var result = id != null
        ? await dbClient.delete(
            medicineHistoryTable,
            where: "$hId = ?",
            whereArgs: [id],
          )
        : await dbClient.delete(medicineHistoryTable);

    Debug.printLog("deleteReminder -->>$result");
    return result;
  }

  Future<int?> deleteAppointmentHistory([int? id]) async {
    var dbClient = await db;
    var result = id != null
        ? await dbClient.delete(
            appointmentHistoryTable,
            where: "$ahId = ?",
            whereArgs: [id],
          )
        : await dbClient.delete(appointmentHistoryTable);

    Debug.printLog("deleteReminder -->>$result");
    return result;
  }

  Future<int?> deleteFamilyMemberData([int? id]) async {
    var dbClient = await db;
    var result = id != null
        ? await dbClient.delete(
            familyMemberTable,
            where: "$fId = ?",
            whereArgs: [id],
          )
        : await dbClient.delete(familyMemberTable);

    Debug.printLog("deleteReminder -->>$result");
    return result;
  }

  Future<int?> deleteDoctor([int? id]) async {
    var dbClient = await db;
    var result = id != null
        ? await dbClient.delete(
            doctorsTable,
            where: "$dId = ?",
            whereArgs: [id],
          )
        : await dbClient.delete(doctorsTable);

    Debug.printLog("delete Doctor -->>$result");
    return result;
  }

  Future<int?> deleteUser([int? id]) async {
    var dbClient = await db;
    var result = await dbClient.delete(userTable);

    Debug.printLog("delete user -->>$result");
    return result;
  }

  Future<int?> deleteNotificationData({int? id, int? fId}) async {
    var dbClient = await db;
    var result = id != null
        ? await dbClient.delete(
            notificationTable,
            where: "$notificationMid = ?",
            whereArgs: [id],
          )
        : fId != null
        ? await dbClient.delete(
            notificationTable,
            where: "$nFamilyMemberId = ?",
            whereArgs: [fId],
          )
        : await dbClient.delete(notificationTable);

    Debug.printLog("deleteReminder -->>$result");
    return result;
  }

  Future<int?> deleteAppointmentNotificationData({int? id, int? fId}) async {
    var dbClient = await db;
    var result = id != null
        ? await dbClient.delete(
            appointmentNotificationTable,
            where: "$appointmentId = ?",
            whereArgs: [id],
          )
        : fId != null
        ? await dbClient.delete(
            appointmentNotificationTable,
            where: "$bookedForFamilyMemberId = ?",
            whereArgs: [fId],
          )
        : await dbClient.delete(appointmentNotificationTable);

    Debug.printLog("deleteReminder -->>$result");
    return result;
  }

  Future<List<MedicineNotificationTable>> getNotificationData({
    int? result,
    int? startForm,
    int? limit,
    int? fId,
  }) async {
    var dbClient = await db;
    List<MedicineNotificationTable> notificationDataList = [];
    List<Map<String, dynamic>> maps = result != null
        ? await dbClient.query(
            notificationTable,
            where: "$notificationMid = ?",
            whereArgs: [result],
          )
        : startForm != null
        ? await dbClient.query(
            notificationTable,
            where: '$nNotificationTimeStamp > ? AND ($nIsActive = ?)',
            whereArgs: [startForm, 1],
            orderBy: '$nNotificationTimeStamp ASC',
            limit: limit,
          )
        : fId != null
        ? await dbClient.query(
            notificationTable,
            where: "$nFamilyMemberId = ?",
            whereArgs: [fId],
          )
        : await dbClient.query(notificationTable);
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var notificationData = MedicineNotificationTable.fromJson(answer);
        notificationDataList.add(notificationData);
      }
    }
    return notificationDataList;
  }

  Future<List<AppointmentNotificationTable>> getAppointmentNotificationData({
    int? result,
    int? startForm,
    int? limit,
    int? fId,
  }) async {
    var dbClient = await db;
    List<AppointmentNotificationTable> notificationDataList = [];
    List<Map<String, dynamic>> maps = result != null
        ? await dbClient.query(
            appointmentNotificationTable,
            where: "$appointmentId = ?",
            whereArgs: [result],
          )
        : startForm != null
        ? await dbClient.query(
            appointmentNotificationTable,
            where: '$appointmentNotificationTimeStamp > ?',
            whereArgs: [startForm],
            orderBy: '$appointmentNotificationTimeStamp ASC',
            limit: limit,
          )
        : fId != null
        ? await dbClient.query(
            appointmentNotificationTable,
            where: "$bookedForFamilyMemberId = ?",
            whereArgs: [fId],
          )
        : await dbClient.query(appointmentNotificationTable);
    if (maps.isNotEmpty) {
      for (var answer in maps) {
        var notificationData = AppointmentNotificationTable.fromJson(answer);
        notificationDataList.add(notificationData);
      }
    }
    return notificationDataList;
  }
}
