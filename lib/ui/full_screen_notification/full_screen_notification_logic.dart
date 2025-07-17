import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_history_table.dart';
import 'package:medinest/database/tables/notification_table.dart';
import 'package:medinest/database/tables/shape_table.dart';
import 'package:medinest/main.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/utils.dart';
import 'package:timezone/timezone.dart' as tz;

class FullScreenNotificationLogic extends GetxController {
  var data = Get.arguments;

  String payload = '';
  MedicineNotificationTable? notificationTable;

  List<FamilyMemberTable?> familyMembersList =
      List<FamilyMemberTable?>.empty(growable: true);
  List<ShapeTable> allShapeList = List<ShapeTable>.empty(growable: true);
  FamilyMemberTable? familyMemberTable;

  Uint8List? imageData;

  int selectedMinute = Constant.snoozeMinutesList[0];

  bool isShowProgress = false;

  // static const channel = MethodChannel('ringtone_channel');

  // final deviceInfoPlugin = DeviceInfoPlugin();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (data != null) {
      payload = data[0];
      notificationTable = MedicineNotificationTable.fromRawJson(payload);
      //
      update();
      getAllFamilyMembers();

      playRingtone();
    }
  }

  /*Future<List<dynamic>> deviceInfo() async {
    final deviceInfo = await deviceInfoPlugin.androidInfo;

    var release = deviceInfo.version.release;
    var sdkInt = deviceInfo.version.sdkInt;

    List<dynamic> deviceInfoValues = [release, sdkInt];

    log("deviceInfoValues ==>> $deviceInfoValues");

    return deviceInfoValues;
  }*/

  Future<void> playRingtone() async {
    if (Platform.isAndroid) {
      // List<dynamic> deviceInfoValues = await deviceInfo();

       // if (int.parse(deviceInfoValues[0]) >= 13) {
      if (notificationTable != null &&
          notificationTable?.nDeviceSoundUri != null) {
        // await channel.invokeMethod('playSystemRingtone', notificationTable?.nDeviceSoundUri);

        Utils.playAudio(
            "sounds/${notificationTable?.nSoundTitle?.toLowerCase()}.mp3");
      }
      // }
    }
  }

  Future<void> stopRingTone() async {
    if (Platform.isAndroid) {
      // List<dynamic> deviceInfoValues = await deviceInfo();

      // if (int.parse(deviceInfoValues[0]) >= 13) {
      // await channel.invokeMethod('stopSystemRingtone');
      Utils.audioPlayer.stop();
      // }
    }
  }

  Future<void> getAllFamilyMembers() async {
    familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
    allShapeList = await DataBaseHelper.instance.getAllShapesData();
    familyMemberTable = familyMembersList
        .where(
            (element) => element!.fId! == notificationTable!.nFamilyMemberId!)
        .toList()
        .first;

    imageData = allShapeList
        .where((element) => element.sId == notificationTable!.nSelectedShapeId)
        .first
        .shapeImage;
    update([Constant.notificationAlert]);
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

  Future<void> scheduleNotification(int selectedMinute) async {
    if (notificationTable == null) {
      return;
    }
    isShowProgress = true;
    update([Constant.notificationAlert]);

    int notificationId = notificationTable!.nId! + Constant.notificationStartID;
    await flutterLocalNotificationsPlugin
        .cancel(notificationId + Constant.notificationStartID);

    final DateTime nNotificationTime = DateTime.now();
    // DateTime.parse(notificationTable!.nNotificationTime!);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        nNotificationTime.year,
        nNotificationTime.month,
        nNotificationTime.day,
        nNotificationTime.hour,
        nNotificationTime.minute + selectedMinute);

    DateTime notificationTime =
        NotificationHelper().getDateTimeFromTZDateTime(scheduledDate);
    notificationTable!.nNotificationTime = notificationTime.toIso8601String();
    await flutterLocalNotificationsPlugin
        .cancel(notificationTable!.nId! + Constant.notificationStartID);
    await NotificationHelper().scheduleNotification(
        result: notificationTable!.nId! + Constant.notificationStartID,
        currentNotificationDateTime: scheduledDate,
        notificationPayload: notificationTable!.toRawJson(),
        notificationTable: notificationTable!);
    isShowProgress = false;
    update([Constant.notificationAlert]);
    // await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop', true);
    // if (Platform.isAndroid)SystemNavigator.pop();
    // if (Platform.isIOS)exit(0);
    exit(0);
    // Get.back();
    // Get.back();
    // Get.find<HomeController>().onTabSelected(0);
    // Get.find<AppointmentScreenLogic>().update([
    //   Constant.idHome,
    //   Constant.idAppointmentList,
    //   Constant.idAppointmentScreenTab
    // ]);
    // Get.find<MedicineScreenLogic>().update([
    //   Constant.idHome,
    //   Constant.idMedicineList,
    //   Constant.idMedicineScreenTab
    // ]);
    // Get.forceAppUpdate();
    // Get.offAllNamed(AppRoutes.home);
  }

  Future<void> takeMedicine([bool isSkipped = false]) async {
    stopRingTone();

    isShowProgress = true;
    update([Constant.notificationAlert]);
    MedicineHistoryTable historyTableData = MedicineHistoryTable(
        hId: null,
        doctorId: notificationTable!.nDoctorId!,
        medicineId: notificationTable!.notificationMid!,
        medicineName: notificationTable!.nName!,
        medicineTakenBy: familyMemberTable?.name ?? '',
        takenById: notificationTable!.nFamilyMemberId!,
        isSkipped: isSkipped ? 1 : 0,
        isTaken: isSkipped ? 0 : 1,
        takenTime: DateTime.now().toIso8601String(),
        mIsSynced: 0);
    var result =
        await DataBaseHelper.instance.insertHistoryData(historyTableData);
    historyTableData.hId = result;

    /// If internet available
    if (await InternetConnectivity.isInternetConnect(Get.context!)) {
      await FireStoreHelper()
          .addAndUpdateHistory(historyTableData.hId!, historyTableData);
    }

    await flutterLocalNotificationsPlugin
        .cancel(notificationTable!.nId! + Constant.notificationStartID);

    isShowProgress = false;
    update([Constant.notificationAlert]);
    // await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop', true);
    // if (Platform.isAndroid)SystemNavigator.pop();
    // if (Platform.isIOS)exit(0);
    exit(0);
    // Get.back();
    // Get.back();
    // Get.find<HomeController>().onTabSelected(0);
    // Get.find<AppointmentScreenLogic>().update([
    //   Constant.idHome,
    //   Constant.idAppointmentList,
    //   Constant.idAppointmentScreenTab
    // ]);
    // Get.find<MedicineScreenLogic>().update([
    //   Constant.idHome,
    //   Constant.idMedicineList,
    //   Constant.idMedicineScreenTab
    // ]);
    // Get.forceAppUpdate();
    // Get.offAllNamed(AppRoutes.home);
  }

  void onMinuteChange(int? value) {
    stopRingTone();

    selectedMinute = value!;
    update([Constant.notificationAlert]);
    scheduleNotification(selectedMinute);
  }
}
