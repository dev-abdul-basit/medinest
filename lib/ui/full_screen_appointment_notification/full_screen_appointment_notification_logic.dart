
import 'dart:io';
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
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/utils.dart';
import 'package:timezone/timezone.dart' as tz;

class FullScreenAppointmentNotificationLogic extends GetxController {
  var data = Get.arguments;

  String payload = '';
  AppointmentNotificationTable? appointmentNotificationTable;

  List<FamilyMemberTable?> familyMembersList =
      List<FamilyMemberTable?>.empty(growable: true);
  FamilyMemberTable? familyMemberTable;

  List<DoctorsTable?> doctorsList = List<DoctorsTable?>.empty(growable: true);
  DoctorsTable? doctorsTable;

  int selectedMinute = Constant.snoozeMinutesList[0];
  bool isShowProgress = false;
  // final deviceInfoPlugin = DeviceInfoPlugin();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (data != null) {
      payload = data[0];
      appointmentNotificationTable =
          AppointmentNotificationTable.fromRawJson(payload);
      // print('notificationTable: ${notificationTable?.toJson().toString()}');
      update();
      getAllFamilyMembers();

      playRingtone();
    }
  }
  Future<void> playRingtone() async {
    if (Platform.isAndroid) {
      // List<dynamic> deviceInfoValues = await deviceInfo();

      // if (int.parse(deviceInfoValues[0]) >= 13) {
        if (appointmentNotificationTable != null &&
            appointmentNotificationTable?.mDeviceSoundUri != null) {
          // await channel.invokeMethod('playSystemRingtone', notificationTable?.nDeviceSoundUri);

          Utils.playAudio(
              "sounds/${appointmentNotificationTable?.mSoundTitle?.toLowerCase()}.mp3");
        }
      // }
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
    familyMemberTable = familyMembersList
        .where((element) =>
            element!.fId! ==
            appointmentNotificationTable!.bookedForFamilyMemberId!)
        .toList()
        .first;

    doctorsList = await DataBaseHelper.instance.getDoctorsData();
    doctorsTable = doctorsList
        .where((element) =>
            element!.dId! == appointmentNotificationTable!.doctorId!)
        .toList()
        .first;

    Debug.printLog(":: ::: ::: $familyMembersList");
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
    stopRingTone();
    if (appointmentNotificationTable == null) {
      return;
    }
    isShowProgress = true;
    update([Constant.notificationAlert]);
    int notificationId = appointmentNotificationTable!.anId!;
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
    appointmentNotificationTable!.appointmentNotificationTime =
        notificationTime.toIso8601String();
    await flutterLocalNotificationsPlugin
        .cancel(appointmentNotificationTable!.anId!);
    await NotificationHelper().scheduleAppointmentNotification(
        result: appointmentNotificationTable!.anId!,
        currentNotificationDateTime: scheduledDate,
        notificationPayload: appointmentNotificationTable!.toRawJson(),
        appointmentNotificationTable: appointmentNotificationTable!);
    isShowProgress = false;
    update([Constant.notificationAlert]);
    // if (Platform.isAndroid)SystemNavigator.pop();
    // if (Platform.isIOS)exit(0);
    // await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop', true);
    exit(0);
    // Get.offAllNamed(AppRoutes.home);
  }

  Future<void> acceptAppointment([bool isReSchedule = false]) async {
    stopRingTone();
    isShowProgress = true;
    update([Constant.notificationAlert]);
    List<FamilyMemberTable?> familyMembersList =
        List<FamilyMemberTable?>.empty(growable: true);
    familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
    FamilyMemberTable? familyMemberTable = familyMembersList
        .where((element) =>
            element!.fId! ==
            appointmentNotificationTable!.bookedForFamilyMemberId!)
        .toList()
        .first;
    AppointmentHistoryTable appointmentHistoryTableData =
        AppointmentHistoryTable(
            ahId: null,
            doctorId: appointmentNotificationTable!.doctorId!,
            acceptTime: DateTime.now().toIso8601String(),
            isAccept: isReSchedule ? 0 : 1,
            mIsSynced: 0,
            appointmentId: appointmentNotificationTable!.appointmentId,
            appointmentFor: familyMemberTable!.name,
            appointmentForId:
                appointmentNotificationTable!.bookedForFamilyMemberId!,
            isReSchedule: isReSchedule ? 1 : 0);
    if (isReSchedule) {
      await DataBaseHelper.instance
          .getAppointmentTableData(
              result: appointmentHistoryTableData.appointmentId!)
          .then((value) async {
        AppointmentTable appointmentTable = value.first;
        isShowProgress = false;
        update([Constant.notificationAlert]);
        await flutterLocalNotificationsPlugin
            .cancel(appointmentNotificationTable!.anId!);
        Get.offAllNamed(AppRoutes.home);
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.toNamed(AppRoutes.addOrEditAppointment, arguments: [
            true,
            appointmentTable,
            true,
            appointmentHistoryTableData
          ]);
        });
      });
    } else {
      var result = await DataBaseHelper.instance
          .insertAppointmentHistoryData(appointmentHistoryTableData);
      appointmentHistoryTableData.ahId = result;
      if (await InternetConnectivity.isInternetConnect(Get.context!)) {
        await FireStoreHelper()
            .addAndUpdateAppointmentHistory(appointmentHistoryTableData);
      }
      await flutterLocalNotificationsPlugin
          .cancel(appointmentNotificationTable!.anId!);
      // Get.find<AppointmentScreenLogic>().getAllFamilyMembers();
      isShowProgress = false;
      update([Constant.notificationAlert]);
      // await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop', true);

      // if (Platform.isAndroid)SystemNavigator.pop();
      // if (Platform.isIOS)exit(0);
      exit(0);
      // Get.offAllNamed(AppRoutes.home);
    }
  }

  void onMinuteChange(int? value) {
    selectedMinute = value!;
    update([Constant.notificationAlert]);
    scheduleNotification(selectedMinute);
  }
}
