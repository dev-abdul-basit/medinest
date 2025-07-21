import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/appointment_history_table.dart';
import 'package:medinest/database/tables/appointment_notification_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_history_table.dart';
import 'package:medinest/database/tables/notification_table.dart';
import 'package:medinest/in_app_purchase/in_app_purchase_helper.dart';
import 'package:medinest/localization/locale_constant.dart';
import 'package:medinest/localization/localizations_delegate.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/routes/app_pages.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/themes/app_theme.dart';
import 'package:medinest/utils/color.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/utils.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// Platform  Firebase App Id
// android   1:969115537915:android:5e1bdb424b0f7d19d47b5e
// ios       1:969115537915:ios:b3a7f912b94c5e26d47b5e

int id = 0;
DateTime? currentBackPressTime;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;
bool isFullScreenNotification = false;

/// A notification action which triggers a Taken event
const String takenId = 'id_taken';
const String acceptId = 'id_accept';
const String reScheduleId = 'id_re_schedule';
const String snoozeId = 'id_snooze';
const String skipId = 'id_skip';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
Future<void> notificationTapBackground(
    NotificationResponse? notificationResponse) async {
  // ignore: avoid_print
  if (notificationResponse != null) {
    if (notificationResponse.payload != null) {
      if (notificationResponse.payload!.contains('notificationMid')) {
        MedicineNotificationTable? notificationTable =
            MedicineNotificationTable.fromRawJson(
                notificationResponse.payload!);
        if (notificationResponse.actionId == takenId) {
          takeMedicine(isSkipped: false, notificationTable: notificationTable);
        } else if (notificationResponse.actionId == snoozeId) {
          await _configureLocalTimeZone();
          int notificationId =
              notificationTable.nId! + Constant.notificationStartID;
          await flutterLocalNotificationsPlugin
              .cancel(notificationId + Constant.notificationStartID);

          final DateTime nNotificationTime = DateTime.now();

          tz.TZDateTime scheduledDate = tz.TZDateTime(
              tz.local,
              nNotificationTime.year,
              nNotificationTime.month,
              nNotificationTime.day,
              nNotificationTime.hour,
              nNotificationTime.minute + 5);

          DateTime notificationTime =
              NotificationHelper().getDateTimeFromTZDateTime(scheduledDate);
          notificationTable.nNotificationTime =
              notificationTime.toIso8601String();

          await NotificationHelper().scheduleNotification(
              result: notificationTable.nId! + Constant.notificationStartID,
              currentNotificationDateTime: scheduledDate,
              notificationPayload: notificationTable.toRawJson(),
              notificationTable: notificationTable);
        } else if (notificationResponse.actionId == skipId) {
          takeMedicine(isSkipped: true, notificationTable: notificationTable);
        }
      } else if (notificationResponse.payload!.contains('AppointmentId')) {
        AppointmentNotificationTable? appointmentNotificationTable =
            AppointmentNotificationTable.fromRawJson(
                notificationResponse.payload!);
        if (notificationResponse.actionId == acceptId) {
          acceptAppointment(
              isReSchedule: false,
              appointmentNotificationTable: appointmentNotificationTable);
        } else if (notificationResponse.actionId == reScheduleId) {
          acceptAppointment(
              isReSchedule: true,
              appointmentNotificationTable: appointmentNotificationTable);
        } else if (notificationResponse.actionId == snoozeId) {
          await _configureLocalTimeZone();
          int notificationId = appointmentNotificationTable.anId!;
          await flutterLocalNotificationsPlugin
              .cancel(notificationId + Constant.notificationStartID);

          final DateTime nNotificationTime = DateTime.now();

          tz.TZDateTime scheduledDate = tz.TZDateTime(
              tz.local,
              nNotificationTime.year,
              nNotificationTime.month,
              nNotificationTime.day,
              nNotificationTime.hour,
              nNotificationTime.minute + 5);

          await NotificationHelper().scheduleAppointmentNotification(
              result: appointmentNotificationTable.anId!,
              currentNotificationDateTime: scheduledDate,
              notificationPayload: appointmentNotificationTable.toRawJson(),
              appointmentNotificationTable: appointmentNotificationTable);
        }
        // else if (notificationResponse.actionId == reScheduleId) {
        //   acceptAppointment(
        //       isReSchedule: true,
        //       appointmentNotificationTable: appointmentNotificationTable);
        // }
      }
    }
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_
    }
  }
}

Future<void> takeMedicine(
    {required bool isSkipped,
    required MedicineNotificationTable notificationTable}) async {
  List<FamilyMemberTable?> familyMembersList =
      List<FamilyMemberTable?>.empty(growable: true);
  familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
  FamilyMemberTable? familyMemberTable = familyMembersList
      .where((element) => element!.fId! == notificationTable.nFamilyMemberId!)
      .toList()
      .first;
  MedicineHistoryTable historyTableData = MedicineHistoryTable(
      hId: null,
      doctorId: notificationTable.nDoctorId!,
      medicineId: notificationTable.notificationMid!,
      medicineName: notificationTable.nName!,
      medicineTakenBy: familyMemberTable?.name ?? '',
      takenById: notificationTable.nFamilyMemberId!,
      isSkipped: isSkipped ? 1 : 0,
      isTaken: isSkipped ? 0 : 1,
      takenTime: DateTime.now().toIso8601String(),
      mIsSynced: 0);
  var result =
      await DataBaseHelper.instance.insertHistoryData(historyTableData);
  historyTableData.hId = result;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Preference().instance();

  if (await InternetConnectivity.isInternetConnect()) {
    await FireStoreHelper()
        .addAndUpdateHistory(historyTableData.hId!, historyTableData);
  }

  await flutterLocalNotificationsPlugin
      .cancel(notificationTable.nId! + Constant.notificationStartID);
}

Future<void> acceptAppointment(
    {required bool isReSchedule,
    required AppointmentNotificationTable appointmentNotificationTable}) async {
  List<FamilyMemberTable?> familyMembersList =
      List<FamilyMemberTable?>.empty(growable: true);
  familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
  FamilyMemberTable? familyMemberTable = familyMembersList
      .where((element) =>
          element!.fId! ==
          appointmentNotificationTable.bookedForFamilyMemberId!)
      .toList()
      .first;
  AppointmentHistoryTable appointmentHistoryTableData = AppointmentHistoryTable(
      ahId: null,
      doctorId: appointmentNotificationTable.doctorId!,
      acceptTime: DateTime.now().toIso8601String(),
      isAccept: isReSchedule ? 0 : 1,
      mIsSynced: 0,
      appointmentId: appointmentNotificationTable.appointmentId,
      appointmentFor: familyMemberTable!.name,
      appointmentForId: appointmentNotificationTable.bookedForFamilyMemberId!,
      isReSchedule: isReSchedule ? 1 : 0);
  var result = await DataBaseHelper.instance
      .insertAppointmentHistoryData(appointmentHistoryTableData);
  appointmentHistoryTableData.ahId = result;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Preference().instance();

  if (await InternetConnectivity.isInternetConnect()) {
    await FireStoreHelper()
        .addAndUpdateAppointmentHistory(appointmentHistoryTableData);
  }

  await flutterLocalNotificationsPlugin
      .cancel(appointmentNotificationTable.anId!);
}

void main() async {
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (Platform.isAndroid) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,

    );
  } else if (Platform.isIOS) {
    await FirebaseAppCheck.instance.activate(
      appleProvider: AppleProvider.appAttest,

    );
  }


  await _configureLocalTimeZone();

  /// Initialize Internet connectivity manger
  await InternetConnectivity().instance();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  // String initialRoute = HomePage.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    isFullScreenNotification =
        notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
    // initialRoute = SecondPage.routeName;
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  // final DarwinInitializationSettings initializationSettingsDarwin =
  //     DarwinInitializationSettings(
  //   requestAlertPermission: false,
  //   requestBadgePermission: false,
  //   requestSoundPermission: false,
  //   onDidReceiveLocalNotification:
  //       (int id, String? title, String? body, String? payload) async {
  //     didReceiveLocalNotificationStream.add(
  //       ReceivedNotification(
  //         id: id,
  //         title: title,
  //         body: body,
  //         payload: payload,
  //       ),
  //     );
  //   },
  //   notificationCategories: darwinNotificationCategories,
  // );
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
   // iOS: initializationSettingsDarwin,
   // macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      ///IN android Notification Tap will get here first

      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  /// Initialize Shared Preference
  await Preference().instance();

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: AppColor.transparent));

  // InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();

  if (Platform.isIOS) {
    final transactions = await SKPaymentQueueWrapper().transactions();

    for (SKPaymentTransactionWrapper element in transactions) {
      await SKPaymentQueueWrapper().finishTransaction(element);
      await SKPaymentQueueWrapper()
          .finishTransaction(element.originalTransaction!);
    }
  }
  InAppPurchaseHelper().initStoreInfo();
  runApp(const MyApp());
}

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  static const eventChannel = EventChannel('step_count_channel');
  static final StreamController purchaseStreamController =
      StreamController<PurchaseDetails>.broadcast();
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        bool isUserLoggedIn = Preference.shared.getIsUserLogin();

        bool isUserGetStarted = Preference.shared.getIsGetStarted();
        bool isUserIntroduction = Preference.shared.getIsIntroduction();
        bool isUserProfileAdded = Preference.shared.getProfileAdded();
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Utils.isLightTheme() ? Brightness.dark : Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.light,
        ));
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return GetMaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          color: AppColor.white,
          themeMode: Utils.isLightTheme() ? ThemeMode.light : ThemeMode.dark,
          locale: getLocale(),
          translations: AppLanguages(),
          fallbackLocale:
              const Locale(Constant.languageEn, Constant.countryCodeEn),
          getPages: AppPages.list,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          defaultTransition: Transition.fade,
          transitionDuration: const Duration(milliseconds: 200),
          initialRoute: isUserIntroduction
              ? isUserGetStarted
                  ? isUserLoggedIn
                      ? isUserProfileAdded
                          ? AppRoutes.home
                          : AppRoutes.addOrEditProfile
                      : AppRoutes.signIn
                  : AppRoutes.getStarted
              : AppRoutes.introduction,
        );
      },
    );
  }
}
