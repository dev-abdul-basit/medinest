import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/tables/appointment_notification_table.dart';
import 'package:medinest/database/tables/appointment_table.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/main.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';
import 'package:timezone/timezone.dart' as tz;

import '../database/tables/notification_table.dart';

class NotificationHelper {
  static final NotificationHelper instance = NotificationHelper.internal();

  factory NotificationHelper() => instance;

  NotificationHelper.internal();

  scheduleMedicineNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    List<MedicineNotificationTable> tempNotificationDataListTemp =
    await DataBaseHelper.instance.getNotificationData();
    for (var tempNotificationData in tempNotificationDataListTemp){
      Debug.printLog('tempNotificationData : ${tempNotificationData.toJson()}');
    }

    List<MedicineNotificationTable> tempNotificationDataList =
        await DataBaseHelper.instance.getNotificationData(
            startForm: DateTime.now().millisecondsSinceEpoch,
            limit: Platform.isAndroid ? 400 : 45);
    for (var tempNotificationData in tempNotificationDataList) {
      String notificationPayload = tempNotificationData.toRawJson();
      Debug.printLog('notificationPayload: $notificationPayload');
      DateTime notificationTime =
          DateTime.parse(tempNotificationData.nNotificationTime!);
      final tz.TZDateTime currentNotificationDateTime = tz.TZDateTime(
        tz.local,
        notificationTime.year,
        notificationTime.month,
        notificationTime.day,
        notificationTime.hour,
        notificationTime.minute,
      );
      await scheduleNotification(
          result: tempNotificationData.nId!+Constant.notificationStartID,
          currentNotificationDateTime: currentNotificationDateTime,
          notificationTable: tempNotificationData,
          notificationPayload: notificationPayload);
    }
    await reScheduleAppointmentNotification();
    checkPendingNotificationRequests();
  }

  reScheduleAppointmentNotification() async {
    List<AppointmentNotificationTable>
        firstTempAppointmentNotificationDataList =
        await DataBaseHelper.instance.getAppointmentNotificationData();
    for (var tempNotificationData in firstTempAppointmentNotificationDataList) {
      await flutterLocalNotificationsPlugin.cancel(tempNotificationData.anId!);
    }

    Debug.printLog(
        "getLastNotificationTimeStamp===>> ${Preference.shared.getLastNotificationTimeStamp()}");

    List<AppointmentNotificationTable> tempAppointmentNotificationDataList =
        await DataBaseHelper.instance.getAppointmentNotificationData(
            startForm: DateTime.now().millisecondsSinceEpoch,
            limit: Platform.isAndroid ? 100 : 15);

    for (var appointmentNotificationData
        in tempAppointmentNotificationDataList) {
      String notificationPayload = appointmentNotificationData.toRawJson();


      DateTime notificationTime = DateTime.parse(
          appointmentNotificationData.appointmentNotificationTime!);
      final tz.TZDateTime currentNotificationDateTime = tz.TZDateTime(
        tz.local,
        notificationTime.year,
        notificationTime.month,
        notificationTime.day,
        notificationTime.hour,
        notificationTime.minute,
      );


      // await scheduleAppointmentNotification(
      //     result: appointmentNotificationData.anId!,
      //     currentNotificationDateTime: currentNotificationDateTime,
      //     appointmentNotificationTable: appointmentNotificationData,
      //     notificationPayload: notificationPayload);
    }
  }

  Future<void> scheduleDailyNotificationNew(
      {required MedicineTable medicineTable}) async {
    if (medicineTable.mFrequencyType == 'Every day') {
      final DateTime startDate = DateTime.parse(medicineTable.mStartDate!);
      final DateTime endDate = DateTime.parse(medicineTable.mEndDate!);
      List<TimeOfDay> timeList = parseTimeList(medicineTable.mTime!);
      DateTime tempDate = startDate;
      Debug.printLog('currentNotificationDateTime 1: ${tempDate.toString()}');
      Debug.printLog("Start Date: ${startDate.toString()}");
      Debug.printLog("End Date: ${endDate.toString()}");
      while (tempDate.isBefore(endDate) || tempDate.isAtSameMomentAs(endDate)) {
        Debug.printLog('currentNotificationDateTime 1: ${tempDate.toString()}');
        for (TimeOfDay notificationTime in timeList) {
          final tz.TZDateTime currentNotificationDateTime = tz.TZDateTime(
            tz.local,
            tempDate.year,
            tempDate.month,
            tempDate.day,
            notificationTime.hour,
            notificationTime.minute,
          );
          Debug.printLog(
              'currentNotificationDateTime 2: ${currentNotificationDateTime.toString()}');
          await addAndScheduleNotification(
              currentNotificationDateTime: currentNotificationDateTime,
              medicineTable: medicineTable);
        }
        tempDate = tempDate.add(const Duration(days: 1));
      }
      // List<MedicineNotificationTable> notificationDataList =
      //     await DataBaseHelper.instance.getNotificationData(result: medicineTable.mId);
      // FireStoreHelper().addAndUpdateNotificationBatch(notificationDataList);
    } else {
      final DateTime startDate = DateTime.parse(medicineTable.mStartDate!);
      final DateTime endDate = DateTime.parse(medicineTable.mEndDate!);
      List<TimeOfDay> timeList = parseTimeList(medicineTable.mTime!);
      DateTime tempDate = startDate;
      Debug.printLog('currentNotificationDateTime 1: ${tempDate.toString()}');
      Debug.printLog("Start Date: ${startDate.toString()}");
      Debug.printLog("End Date: ${endDate.toString()}");
      while (tempDate.isBefore(endDate) || tempDate.isAtSameMomentAs(endDate)) {
        Debug.printLog('currentNotificationDateTime 1: ${tempDate.toString()}');
        for (TimeOfDay notificationTime in timeList) {
          final tz.TZDateTime currentNotificationDateTime = tz.TZDateTime(
            tz.local,
            tempDate.year,
            tempDate.month,
            tempDate.day,
            notificationTime.hour,
            notificationTime.minute,
          );
          List<int> intList =
              List<int>.from(json.decode(medicineTable.mDayOfWeek!));
          if (intList.contains(currentNotificationDateTime.toLocal().weekday)) {



            await addAndScheduleNotification(
                currentNotificationDateTime: currentNotificationDateTime,
                medicineTable: medicineTable);
          }
        }
        tempDate = tempDate.add(const Duration(days: 1));
      }
      // List<MedicineNotificationTable> notificationDataList =
      // await DataBaseHelper.instance.getNotificationData(result: medicineTable.mId);
      // FireStoreHelper().addAndUpdateNotificationBatch(notificationDataList);
    }
  }

  // Future<void> scheduleAppointment(
  //     {required AppointmentTable appointmentTable}) async {
  //   final DateTime startDate =
  //       DateTime.parse(appointmentTable.appointmentDate!);
  //   TimeOfDay appointmentTime =
  //       parseTimeList(appointmentTable.appointmentTime!).first;
  //   final tz.TZDateTime initialNotificationDateTime = tz.TZDateTime(
  //     tz.local,
  //     startDate.year,
  //     startDate.month,
  //     startDate.day,
  //     appointmentTime.hour,
  //     appointmentTime.minute,
  //   );
  //   tz.TZDateTime currentNotificationDateTime;
  //
  //
  //   if (appointmentTable.reminderBeforeTime == null ||appointmentTable.reminderBeforeTime == 'null' ||
  //       appointmentTable.reminderBeforeTime == 'None') {
  //     currentNotificationDateTime = initialNotificationDateTime;
  //   } else {
  //     currentNotificationDateTime = initialNotificationDateTime.subtract(
  //         Duration(minutes: int.parse(appointmentTable.reminderBeforeTime!)));
  //   }
  //
  //   await addAndAndScheduleAppointment(
  //       currentNotificationDateTime: currentNotificationDateTime,
  //       appointmentTable: appointmentTable);
  // }
  //
  // addAndAndScheduleAppointment(
  //     {required tz.TZDateTime currentNotificationDateTime,
  //     required AppointmentTable appointmentTable}) async {
  //   DateTime notificationTime =
  //       getDateTimeFromTZDateTime(currentNotificationDateTime);
  //   AppointmentNotificationTable appointmentNotificationTable =
  //       AppointmentNotificationTable(
  //         anId: null,
  //     appointmentId: appointmentTable.aId,
  //     bookedForFamilyMemberId: appointmentTable.bookedForFamilyMemberId,
  //     doctorId: appointmentTable.doctorId,
  //     appointmentDate: appointmentTable.appointmentDate,
  //     appointmentTime: appointmentTable.appointmentTime,
  //     appointmentNotificationTime: notificationTime.toIso8601String(),
  //     appointmentNotificationTimeStamp: notificationTime.millisecondsSinceEpoch,
  //     mDeviceSoundUri: appointmentTable.mDeviceSoundUri,
  //     mSoundTitle: appointmentTable.mSoundTitle,
  //     mSoundType: appointmentTable.mSoundType,
  //     mIsFromDevice: appointmentTable.mIsFromDevice,
  //     reminderBeforeTime: appointmentTable.reminderBeforeTime.toString(),
  //     description: appointmentTable.description,
  //     mIsSynced: 0,
  //   );
  //   if(notificationTime.isAfter(DateTime.now())){
  //     var result = await DataBaseHelper.instance
  //         .insertOrUpdateAppointmentNotificationData(
  //         appointmentNotificationTable);
  //     appointmentNotificationTable.anId = result;
  //   }
  // }

  Future<void> checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var element in pendingNotificationRequests) {
      Debug.printLog(
          "_getPendingNotification===>> ${element.id} ${element.body} ${element.title} NotificationDateTime : ${element.payload}");
    }

    // return showDialog<void>(
    //   context: Get.context!,
    //   builder: (BuildContext context) => AlertDialog(
    //     content:
    //         Text('${pendingNotificationRequests.length} pending notification '
    //             'requests'),
    //     actions: <Widget>[
    //       TextButton(
    //         onPressed: () {
    //           Navigator.of(context).pop();
    //         },
    //         child: const Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
  }

  Future<int> checkPendingNotificationRequestsLength() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var element in pendingNotificationRequests) {
      Debug.printLog(
          "_getPendingNotification===>> ${element.id} ${element.body} ${element.title} NotificationDateTime : ${element.payload}");
    }
    return pendingNotificationRequests.length;

    // return showDialog<void>(
    //   context: Get.context!,
    //   builder: (BuildContext context) => AlertDialog(
    //     content:
    //         Text('${pendingNotificationRequests.length} pending notification '
    //             'requests'),
    //     actions: <Widget>[
    //       TextButton(
    //         onPressed: () {
    //           Navigator.of(context).pop();
    //         },
    //         child: const Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
  }

  tz.TZDateTime nextInstanceOfTime() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, now.hour, now.minute + 1, 30);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  List<TimeOfDay> parseTimeList(String data) {
    // Extract time strings from the data string
    final regex = RegExp(r"TimeOfDay\((\d{2}:\d{2})\)");
    final matches = regex.allMatches(data);

    List<TimeOfDay> timeList = [];
    for (Match match in matches) {
      String timeString = match.group(1)!; // Extract matched time string
      List<String> parts = timeString.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      timeList.add(TimeOfDay(hour: hour, minute: minute));
    }

    return timeList;
  }

  Future<void> addAndScheduleNotification(
      {required tz.TZDateTime currentNotificationDateTime,
      required MedicineTable medicineTable}) async {
    DateTime notificationTime =
        getDateTimeFromTZDateTime(currentNotificationDateTime);
    MedicineNotificationTable notificationTable = MedicineNotificationTable(
      nId: null,
      notificationMid: medicineTable.mId,
      nCurrentTime: DateTime.now().toIso8601String(),
      nName: medicineTable.mName,
      nDosage: medicineTable.mDosage,
      nUnits: medicineTable.mUnits,
      nSelectedShapeId: medicineTable.mSelectedShapeId,
      nColorPhotoType: medicineTable.mColorPhotoType,
      nColorPhoto: medicineTable.mColorPhoto.toString(),
      nIsBeforeOrAfterFood: medicineTable.mIsBeforeOrAfterFood,
      nSoundType: medicineTable.mSoundType.toString(),
      nStartDate: medicineTable.mStartDate,
      nEndDate: medicineTable.mEndDate,
      nIsNoEndDate: medicineTable.mIsNoEndDate,
      nFrequencyType: medicineTable.mFrequencyType,
      nDayOfWeek: medicineTable.mDayOfWeek,
      nTime: medicineTable.mTime,
      nIsActive: medicineTable.mIsActive,
      nNotificationTime: notificationTime.toIso8601String(),
      nNotificationTimeStamp: notificationTime.millisecondsSinceEpoch,
      nDeviceSoundUri: medicineTable.mDeviceSoundUri,
      nIsFromDevice: medicineTable.mIsFromDevice,
      nSoundTitle: medicineTable.mSoundTitle,
      nIsSynced: 0,
      nDoctorId: medicineTable.mDoctorId,
      nFamilyMemberId: medicineTable.mFamilyMemberId,
    );
    if(notificationTime.isAfter(DateTime.now())){
        await DataBaseHelper.instance
          .insertOrUpdateNotificationData(notificationTable);
    }
  }


  Future<void> scheduleNotification({
    required int result,
    required tz.TZDateTime currentNotificationDateTime,
    MedicineTable? medicineTable,
    MedicineNotificationTable? notificationTable,
    required String notificationPayload,
  }) async {
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 4000;
    vibrationPattern[2] = 4000;
    vibrationPattern[3] = 4000;
    Debug.printLog('nSoundTitle : ', notificationTable?.nSoundTitle
        ?.trim()
        .toLowerCase()
        .replaceAll(' ', ''));
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'daily_notification_channel_id_${medicineTable?.mSoundTitle ??
          notificationTable?.nSoundTitle}',
      'Daily Notification Channel ${medicineTable?.mSoundTitle ??
          notificationTable?.nSoundTitle}',
      channelDescription: 'Daily Notification Description ${medicineTable
          ?.mSoundTitle ?? notificationTable?.nSoundTitle}',
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.call,
      additionalFlags: Int32List.fromList(<int>[4]),
      vibrationPattern: vibrationPattern,
      sound: medicineTable?.mIsFromDevice == 1 ||
          notificationTable?.nIsFromDevice == 1
          ? UriAndroidNotificationSound(medicineTable?.mDeviceSoundUri ??
          notificationTable?.nDeviceSoundUri ?? '')
          : RawResourceAndroidNotificationSound(medicineTable?.mSoundTitle
          ?.trim()
          .toLowerCase()
          .replaceAll(' ', '') ??
          notificationTable?.nSoundTitle
              ?.trim()
              .toLowerCase()
              .replaceAll(' ', '')),
      visibility: NotificationVisibility.public,
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'ticker',
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          takenId,
          'Taken',
          titleColor: Get.theme.colorScheme.primary,
        ),
        AndroidNotificationAction(
          skipId,
          'Skip',
          titleColor: Get.theme.colorScheme.primary,
          // icon: DrawableResourceAndroidBitmap('secondary_icon'),
        ),
        AndroidNotificationAction(
          snoozeId,
          'Snooze for 5 minutes',
          titleColor: Get.theme.colorScheme.secondary,
          // icon: DrawableResourceAndroidBitmap('secondary_icon'),
        ),

      ],
    );

    DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      sound: medicineTable != null
          ? "${medicineTable.mSoundTitle?.trim().toLowerCase().replaceAll(
          ' ', '')}.mp3"
          : '${notificationTable?.nSoundTitle?.trim().toLowerCase().replaceAll(
          ' ', '')}.mp3',
      presentSound: true,

      categoryIdentifier: darwinNotificationCategoryPlain,
    );

    String nameOfFamilyMember = await getFamilyMember(medicineTable != null
        ? medicineTable.mFamilyMemberId
        : notificationTable?.nFamilyMemberId ?? 1)
        .then((value) {
      return value?.name ?? '';
    });

    String title =
        'Hi $nameOfFamilyMember It\'s Time';

    String description = 'To Take ${medicineTable?.mDosage ??
        notificationTable?.nDosage ?? ''} ${medicineTable?.mUnits ??
        notificationTable?.nUnits ?? ''} of ${medicineTable?.mName ??
        notificationTable?.nName ?? ''}';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      result,
      title,
      description,
      currentNotificationDateTime,
      NotificationDetails(
          android: androidNotificationDetails, iOS: iosNotificationDetails),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: notificationPayload,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     result,
  //     title,
  //     description,
  //     currentNotificationDateTime,
  //     NotificationDetails(
  //         android: androidNotificationDetails, iOS: iosNotificationDetails),
  //     androidScheduleMode: AndroidScheduleMode.alarmClock,
  //     payload: notificationPayload,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     matchDateTimeComponents: DateTimeComponents.dateAndTime,
  //   );
  // }

  // Future<void> scheduleAppointmentNotification({
  //   required int result,
  //   required tz.TZDateTime currentNotificationDateTime,
  //   AppointmentTable? appointmentTable,
  //   AppointmentNotificationTable? appointmentNotificationTable,
  //   required String notificationPayload,
  // }) async {
  //   final Int64List vibrationPattern = Int64List(4);
  //   vibrationPattern[0] = 0;
  //   vibrationPattern[1] = 4000;
  //   vibrationPattern[2] = 4000;
  //   vibrationPattern[3] = 4000;
  //
  //   AndroidNotificationDetails androidNotificationDetails =
  //       AndroidNotificationDetails(
  //     'daily_notification_channel_id_${appointmentTable?.mSoundTitle ?? appointmentNotificationTable?.mSoundTitle}',
  //     'Daily Notification Channel ${appointmentTable?.mSoundTitle ?? appointmentNotificationTable?.mSoundTitle}',
  //     channelDescription: 'Daily Notification Description ${appointmentTable?.mSoundTitle ?? appointmentNotificationTable?.mSoundTitle}' ,
  //     playSound: true,
  //     audioAttributesUsage: AudioAttributesUsage.alarm,
  //     category: AndroidNotificationCategory.call,
  //     additionalFlags: Int32List.fromList(<int>[4]),
  //     vibrationPattern: vibrationPattern,
  //     sound: appointmentTable?.mIsFromDevice == 1 ||
  //             appointmentNotificationTable?.mIsFromDevice == 1
  //         ? UriAndroidNotificationSound(appointmentTable?.mDeviceSoundUri ??
  //             appointmentNotificationTable!.mDeviceSoundUri??'')
  //         : RawResourceAndroidNotificationSound(appointmentTable?.mSoundTitle
  //                 ?.trim()
  //                 .toLowerCase()
  //                 .replaceAll(' ', '') ??
  //             appointmentNotificationTable?.mSoundTitle
  //                 ?.trim()
  //                 .toLowerCase()
  //                 .replaceAll(' ', '')),
  //     visibility: NotificationVisibility.public,
  //     importance: Importance.max,
  //     priority: Priority.max,
  //     ticker: 'ticker',
  //     fullScreenIntent: true,
  //     actions: <AndroidNotificationAction>[
  //       AndroidNotificationAction(
  //         acceptId,
  //         'Accept',
  //         titleColor: Get.theme.colorScheme.primary,
  //       ),
  //       // AndroidNotificationAction(
  //       //   reScheduleId,
  //       //   'Re-Schedule',
  //       //   titleColor: Get.theme.colorScheme.primary,
  //       //   // icon: DrawableResourceAndroidBitmap('secondary_icon'),
  //       // ),
  //       AndroidNotificationAction(
  //         snoozeId,
  //         'Snooze for 5 minutes',
  //         titleColor: Get.theme.colorScheme.secondary,
  //         // icon: DrawableResourceAndroidBitmap('secondary_icon'),
  //       ),
  //     ],
  //   );
  //
  //   DarwinNotificationDetails iosNotificationDetails =
  //       DarwinNotificationDetails(
  //     sound: appointmentTable != null
  //         ? "${appointmentTable.mSoundTitle?.trim().toLowerCase().replaceAll(' ', '')}.mp3"
  //         : '${appointmentNotificationTable?.mSoundTitle?.trim().toLowerCase().replaceAll(' ', '')}.mp3',
  //     presentSound: true,
  //     categoryIdentifier: darwinNotificationCategoryPlain,
  //   );
  //   String nameOfFamilyMember = await getFamilyMember(appointmentTable != null
  //           ? appointmentTable.bookedForFamilyMemberId
  //           : appointmentNotificationTable?.bookedForFamilyMemberId ?? 1)
  //       .then((value) {
  //     return value!.name!;
  //   });
  //
  //   String nameOfDoctor = await getDoctorData(appointmentTable != null
  //           ? appointmentTable.doctorId
  //           : appointmentNotificationTable?.doctorId ?? 1)
  //       .then((value) {
  //     return value!.name!;
  //   });
  //
  //   String title =
  //       'Appointment For $nameOfFamilyMember Is Schedule with';
  //   DateTime? startDate = DateTime.parse(appointmentTable?.appointmentDate ??
  //       appointmentNotificationTable?.appointmentDate ??
  //       '');
  //   TimeOfDay? tempSelectedTime = parseTimeList(
  //           appointmentTable?.appointmentTime ??
  //               appointmentNotificationTable?.appointmentTime ??
  //               '')
  //       .first;
  //   String time = DateFormat("HH:mm a").format(
  //       DateTime(2000, 1, 1, tempSelectedTime.hour, tempSelectedTime.minute));
  //   String description =
  //       '$nameOfDoctor On ${DateFormat('d MMM, yyyy').format(startDate)} at $time';
  //
  //   // await flutterLocalNotificationsPlugin.zonedSchedule(
  //   //   result,
  //   //   title,
  //   //   description,
  //   //   currentNotificationDateTime,
  //   //   NotificationDetails(
  //   //       android: androidNotificationDetails, iOS: iosNotificationDetails),
  //   //   androidScheduleMode: AndroidScheduleMode.alarmClock,
  //   //   payload: notificationPayload,
  //   //   uiLocalNotificationDateInterpretation:
  //   //       UILocalNotificationDateInterpretation.absoluteTime,
  //   //   matchDateTimeComponents: DateTimeComponents.dateAndTime,
  //   // );
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     result,
  //     title,
  //     description,
  //     currentNotificationDateTime,
  //     NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails),
  //     androidScheduleMode: AndroidScheduleMode.alarmClock,
  //     payload: notificationPayload,
  //     matchDateTimeComponents: DateTimeComponents.dateAndTime,
  //   );
  //
  // }

  DateTime getDateTimeFromTZDateTime(
      [tz.TZDateTime? currentNotificationDateTime]) {
    DateTime dateTime = DateTime(
      currentNotificationDateTime!.year,
      currentNotificationDateTime.month,
      currentNotificationDateTime.day,
      currentNotificationDateTime.hour,
      currentNotificationDateTime.minute,
    );
    return dateTime;
  }

  Future<FamilyMemberTable?> getFamilyMember(int? fId) async {
    Debug.printLog('getFamilyMember: $fId');
    return await DataBaseHelper.instance.getFamilyMemberData(fId).then((value) {
      if (value.isEmpty) return null;
      FamilyMemberTable familyMember = value.first;
      return familyMember;
    });
  }

  Future<DoctorsTable?> getDoctorData(int? dId) async {
    return await DataBaseHelper.instance.getDoctorsData(result: dId).then((value) {
      if (value.isEmpty) return null;
      DoctorsTable doctorsTable = value.first;
      return doctorsTable;
    });
  }
}
