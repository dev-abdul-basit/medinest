import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/tables/journal_notification_table.dart';
import 'package:medinest/database/tables/journal_table.dart';
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

  /// Pick the strongest Android schedule mode the OS will actually allow.
  ///
  /// On Android 13+ exact alarms need permission (USE_EXACT_ALARM auto-grants it
  /// for reminder apps; otherwise the user must enable "Alarms & reminders").
  /// If exact isn't available we fall back to inexact so reminders still fire —
  /// a few minutes late beats never. iOS/other platforms ignore this.
  Future<AndroidScheduleMode> resolveAndroidScheduleMode() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;
    try {
      final android = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool canExact =
          await android?.canScheduleExactNotifications() ?? false;
      return canExact
          ? AndroidScheduleMode.alarmClock
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (e) {
      Debug.printLog('resolveAndroidScheduleMode failed, using inexact', e);
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

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
    // Resolve the schedule mode once for the whole batch (one platform call).
    final AndroidScheduleMode scheduleMode = await resolveAndroidScheduleMode();
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
      // Per-item guard: one bad reminder must never abort the whole batch.
      try {
        await scheduleNotification(
            result: tempNotificationData.nId! + Constant.notificationStartID,
            currentNotificationDateTime: currentNotificationDateTime,
            notificationTable: tempNotificationData,
            notificationPayload: notificationPayload,
            scheduleMode: scheduleMode);
      } catch (e) {
        Debug.printLog(
            'scheduleNotification failed for nId ${tempNotificationData.nId}',
            e);
      }
    }
    await reScheduleAppointmentNotification();
    await scheduleWinBackNotifications();
    checkPendingNotificationRequests();
  }

  /// F16 — schedule the offline win-back notifications. Called at the end of
  /// [scheduleMedicineNotification] (which `cancelAll()`s first), so every app
  /// open / medicine edit resets the "we miss you" countdown. An active user
  /// never sees these; a user who stops opening MediNest does. Zero backend.
  Future<void> scheduleWinBackNotifications() async {
    // Record this open — resets the resurrection countdown (F15 key).
    await Preference.shared
        .setLastOpenTs(DateTime.now().millisecondsSinceEpoch);

    // Restart both timers from now.
    await flutterLocalNotificationsPlugin
        .cancel(Constant.winBackD1NotificationId);
    await flutterLocalNotificationsPlugin
        .cancel(Constant.winBackD2NotificationId);

    await _scheduleWinBack(
      id: Constant.winBackD1NotificationId,
      afterDays: Constant.winBackD1AfterDays,
      title: 'txtWinBackD1Title'.tr,
      body: 'txtWinBackD1Body'.tr,
    );
    await _scheduleWinBack(
      id: Constant.winBackD2NotificationId,
      afterDays: Constant.winBackD2AfterDays,
      title: 'txtWinBackD2Title'.tr,
      body: 'txtWinBackD2Body'.tr,
    );
  }

  /// F18 — show an immediate engagement notification (e.g. a streak milestone)
  /// on the calm engagement channel. Gating (quiet hours / caps) is the caller's
  /// job via [EngagementService]; this just renders.
  Future<void> showEngagementNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      Constant.engagementNotificationChannelId,
      Constant.engagementNotificationChannelName,
      channelDescription: 'Gentle nudges from MediNest',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      visibility: NotificationVisibility.public,
    );
    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(presentSound: true);
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: Constant.engagementPayload,
    );
  }

  /// F19 — schedule an engagement notification for a specific future [fireAt]
  /// (e.g. the evening adherence nudge). One-shot, calm channel.
  Future<void> scheduleEngagementNotification({
    required int id,
    required DateTime fireAt,
    required String title,
    required String body,
  }) async {
    final tz.TZDateTime fireDate = tz.TZDateTime(
      tz.local,
      fireAt.year,
      fireAt.month,
      fireAt.day,
      fireAt.hour,
      fireAt.minute,
    );
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      Constant.engagementNotificationChannelId,
      Constant.engagementNotificationChannelName,
      channelDescription: 'Gentle nudges from MediNest',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      visibility: NotificationVisibility.public,
    );
    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(presentSound: true);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      fireDate,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: Constant.engagementPayload,
    );
  }

  Future<void> cancelEngagementNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// F19 — epoch-ms fire times of today's medicine reminders still ahead of
  /// [now], for the engagement budget's reminder-spacing check.
  Future<List<int>> todayRemainingReminderTimestamps(DateTime now) async {
    final List<MedicineNotificationTable> upcoming =
        await DataBaseHelper.instance.getNotificationData(
            startForm: now.millisecondsSinceEpoch,
            limit: Platform.isAndroid ? 400 : 45);
    final List<int> result = [];
    for (final n in upcoming) {
      final ts = n.nNotificationTimeStamp;
      if (ts == null) continue;
      final dt = DateTime.fromMillisecondsSinceEpoch(ts);
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        result.add(ts);
      }
    }
    return result;
  }

  Future<void> _scheduleWinBack({
    required int id,
    required int afterDays,
    required String title,
    required String body,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime fireDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      Constant.winBackFireHour,
    ).add(Duration(days: afterDays));
    // Safety: never schedule in the past.
    if (fireDate.isBefore(now)) {
      fireDate = fireDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      Constant.engagementNotificationChannelId,
      Constant.engagementNotificationChannelName,
      channelDescription: 'Gentle nudges to return to MediNest',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      visibility: NotificationVisibility.public,
    );
    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(presentSound: true);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      fireDate,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: Constant.winBackPayload,
    );
  }

  reScheduleAppointmentNotification() async {
    List<JournalNotificationTable>
        firstTempAppointmentNotificationDataList =
        await DataBaseHelper.instance.getAppointmentNotificationData();
    for (var tempNotificationData in firstTempAppointmentNotificationDataList) {
      await flutterLocalNotificationsPlugin.cancel(tempNotificationData.anId!);
    }

    Debug.printLog(
        "getLastNotificationTimeStamp===>> ${Preference.shared.getLastNotificationTimeStamp()}");

    List<JournalNotificationTable> tempAppointmentNotificationDataList =
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
    AndroidScheduleMode? scheduleMode,
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
          'txtTaken'.tr,
          titleColor: Get.theme.colorScheme.primary,
        ),
        AndroidNotificationAction(
          skipId,
          'txtSkip'.tr,
          titleColor: Get.theme.colorScheme.primary,
          // icon: DrawableResourceAndroidBitmap('secondary_icon'),
        ),
        AndroidNotificationAction(
          snoozeId,
          'txtSnoozeForFiveMinutes'.tr,
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

    final AndroidScheduleMode mode =
        scheduleMode ?? await resolveAndroidScheduleMode();
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        result,
        title,
        description,
        currentNotificationDateTime,
        NotificationDetails(
            android: androidNotificationDetails, iOS: iosNotificationDetails),
        androidScheduleMode: mode,
        payload: notificationPayload,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } on PlatformException catch (e) {
      // Exact alarms can still be refused at call time (e.g. user revoked the
      // permission after launch). Retry inexact so the reminder isn't lost.
      Debug.printLog('zonedSchedule exact refused, retrying inexact', e);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        result,
        title,
        description,
        currentNotificationDateTime,
        NotificationDetails(
            android: androidNotificationDetails, iOS: iosNotificationDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: notificationPayload,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
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
