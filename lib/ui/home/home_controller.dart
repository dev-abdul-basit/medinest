import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/common_subscribe_dialog.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/journal_history_table.dart';
import 'package:medinest/database/tables/journal_table.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_history_table.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/database/tables/user_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/google_ads/ad_helper.dart';
import 'package:medinest/in_app_purchase/iap_callback.dart';
import 'package:medinest/in_app_purchase/in_app_purchase_helper.dart';
import 'package:medinest/main.dart';
import 'package:medinest/Widgets/adherence_card.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/services/adherence_service.dart';
import 'package:medinest/services/engagement_scheduler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:medinest/services/today_plan_service.dart';
import 'package:medinest/services/review_prompt_service.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_logic.dart';
import 'package:medinest/ui/get_started_screen/get_started_screen_logic.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/enums.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements IAPCallback {
  String theme = AppThemeMode.light.toString();
  bool notificationsEnabled = false;
  InterstitialAd? interstitialAd;
  bool isInterstitialAdLoaded = false;
  bool canPop = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserTable? userData;
  int selectedTabIndex = 0;
  bool isFromLogin = false;
  var data = Get.parameters;

  TabController? mainTabController;

  /// F08 — adherence card state
  AdherenceSummary? adherenceSummary;
  bool adherenceCardHidden = Preference.shared.getAdherenceCardHidden();

  /// "Today" engagement summary (doses scheduled/taken today + next dose).
  TodayPlan? todayPlan;

  @override
  Future<void> onInit() async {
    update([Constant.idHome]);
    /// F14 — three tabs: Reminders (0) · Journal (1) · Family (2).
    mainTabController =
        mainTabController ?? TabController(length: 3, vsync: this);
    Debug.printLog("isFromLogin: ${data[Constant.idIsFromLogIn]}");
    isFromLogin = data[Constant.idIsFromLogIn] == 'true';
    if (isFullScreenNotification &&
        selectedNotificationPayload != null &&
        // F16/F18 — a win-back or milestone tap just opens the app to Home;
        // never route it into the full-screen medicine reminder (its payload
        // isn't a medicine JSON).
        !selectedNotificationPayload!.contains(Constant.winBackPayload) &&
        !selectedNotificationPayload!.contains(Constant.engagementPayload)) {
      if (selectedNotificationPayload!
          .contains(DataBaseHelper().appointmentId)) {
        Get.toNamed(AppRoutes.fullScreenAppointmentNotification,
            arguments: [selectedNotificationPayload]);
      } else {
        Get.offAndToNamed(AppRoutes.fullScreenNotification,
            arguments: [selectedNotificationPayload]);
      }
    }
    getCurrentTheme();
    _loadInterstitialAd();
    await _isAndroidPermissionGranted();

    await DataBaseHelper.instance
        .getUserData(Preference.shared.getString(Preference.firebaseEmail))
        .then((value) {
      // F07 — guests (deferred sign-in) have no user row yet; don't assume one.
      userData = value.isNotEmpty ? value.first : null;
    });
    // Guarantee the "Me" self profile exists & its id is resolved, so users who
    // reached Home without onboarding (e.g. straight Google sign-in) can still
    // own medicines and edit themselves from the Family tab / Edit Profile.
    await DataBaseHelper.instance
        .ensureSelfMember(selfName: 'txtSelfProfileName'.tr);
    // Backfill data ownership for users who were already signed in before
    // account-isolation existed, so a later account switch correctly isolates.
    if (Preference.shared.getIsUserLogin() &&
        Preference.shared.getDataOwnerUid() == null) {
      final String? uid = Preference.shared.getString(Preference.firebaseAuthUid);
      if (uid != null && uid.isNotEmpty) {
        Preference.shared.setDataOwnerUid(uid);
      }
    }
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    // F07 — guests (deferred sign-in) have no Firebase auth, so a Firestore
    // sync would fail with PERMISSION_DENIED. Only sync when signed in.
    if (Preference.shared.getIsUserLogin() &&
        await InternetConnectivity.isInternetConnect(Get.context!)) {
      syncDataToFirebase();
    }
    InAppPurchaseHelper().getAlreadyPurchaseItems(this);
    await _requestPermissions().then((value) {
      if (value) {
        reScheduleNotifications();
      } else {
        showAlertDialog(Get.context!);
      }
    });

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    /// F02 — review-prompt: gate-checked inside the service. 3 s delay so it
    /// never collides with launch-time dialogs (full-screen reminder, sign-in).
    Future.delayed(const Duration(seconds: 3), () {
      ReviewPromptService.maybeShow();
    });
    refreshAdherence();
    _maybeShowFirstMedicineTooltip();
  }

  /// F07 — one-shot confirmation after the onboarding first-medicine flow, so
  /// the user lands on Home knowing the reminder is set. Fires at most once.
  void _maybeShowFirstMedicineTooltip() {
    if (Preference.shared.getFirstMedicineCreated() &&
        !Preference.shared.getSeenFirstMedicineTooltip()) {
      Preference.shared.setSeenFirstMedicineTooltip(true);
      Future.delayed(const Duration(milliseconds: 700), () {
        Get.snackbar(
          'txtFirstMedTooltipTitle'.tr,
          'txtFirstMedTooltipBody'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Colors.white,
          margin: EdgeInsets.all(AppSizes.width_3),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );
      });
    }
  }

  /// F08 — refresh adherence + the "Today" summary card data.
  Future<void> refreshAdherence() async {
    adherenceSummary = await AdherenceService().compute();
    final List<MedicineTable> meds =
        await DataBaseHelper.instance.getMedicineData();
    todayPlan = TodayPlanService()
        .compute(medicines: meds, adherence: adherenceSummary!);
    update([Constant.idAdherenceCard]);
    // F18 — celebrate a streak milestone if the engagement budget allows.
    await EngagementScheduler().evaluate(summary: adherenceSummary!);
  }

  void hideAdherenceCard() {
    adherenceCardHidden = true;
    Preference.shared.setAdherenceCardHidden(true);
    update([Constant.idAdherenceCard]);
  }

  void openAdherenceWeek(BuildContext context) {
    if (adherenceSummary == null) return;
    Get.bottomSheet(
      AdherenceWeekSheet(summary: adherenceSummary!),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  /// F17 — notification permission rescue. A denied permission silently kills
  /// every reminder, so instead of a placeholder loop we explain why and deep-
  /// link to OS settings (the only thing that re-enables notifications after a
  /// denial on Android 13+).
  showAlertDialog(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('txtPermRescueTitle'.tr),
          content: Text('txtPermRescueBody'.tr),
          actions: [
            TextButton(
              child: Text('txtNotNow'.tr),
              onPressed: () => Get.back(),
            ),
            TextButton(
              child: Text('txtOpenSettings'.tr),
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      notificationsEnabled = granted;
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          )
          .then((value) {
        return notificationsEnabled = value ?? false;
      });
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();

      final bool? grantedAlarmPermission =
          await androidImplementation?.requestExactAlarmsPermission();

      return notificationsEnabled =
          (grantedNotificationPermission! && grantedAlarmPermission!);
    }
    return false;
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      ///IN android Notification Tap will get here Second
      // F16/F18 — win-back or milestone tap while app is alive: nothing to
      // route, already on Home.
      if (payload != null &&
          (payload.contains(Constant.winBackPayload) ||
              payload.contains(Constant.engagementPayload))) {
        return;
      }
      if (payload != null && payload.contains(DataBaseHelper().appointmentId)) {
        Get.toNamed(AppRoutes.fullScreenAppointmentNotification,
            arguments: [payload]);
      } else {
        Get.toNamed(AppRoutes.fullScreenNotification, arguments: [payload]);
      }
    });
  }

  void onWillPop(didPop) {
    /// F14 — drawer is gone; only the press-back-twice-to-exit branch remains.
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'txtPressBackAgainToExitTheApp'.tr);
      canPop = true;
    } else {
      canPop = false;
    }
    update([Constant.idHome]);
  }

  @override
  void dispose() {
    try {
      interstitialAd?.dispose();
      interstitialAd = null;
    } catch (ex) {
      Debug.printLog("banner dispose error");
    }
    super.dispose();
  }

  onThemeChanged(value) {
    theme = value.toString();
    if (theme == AppThemeMode.light.toString()) {
      Get.changeThemeMode(ThemeMode.light);
      Preference.shared.setAppTheme(Constant.appThemeLight);
    } else {
      Get.changeThemeMode(ThemeMode.dark);
      Preference.shared.setAppTheme(Constant.appThemeDark);
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      Get.back();
      update(
          [Constant.idSettingsTheme, Constant.idHome, Constant.idDrawerSheet]);
    });
  }


  getCurrentTheme() {
    theme = Utils.isLightTheme()
        ? AppThemeMode.light.toString()
        : AppThemeMode.dark.toString();
    update([Constant.idSettingsTheme, Constant.idHome, Constant.idDrawerSheet]);
  }

  singOut(context) async {
    if (await InternetConnectivity.isInternetConnect(context)) {
      try {
        await syncDataToFirebase();
        await _auth.signOut();
        await Get.put<GetStartedScreenLogic>(GetStartedScreenLogic()).logoutGoogle();
        Preference.shared.setIsUserLogin(false);
        Preference.shared.setProfileAdded(false);
        await DataBaseHelper.instance.deleteAppointmentNotificationData();
        await DataBaseHelper.instance.deleteAppointment();
        await DataBaseHelper.instance.deleteAppointmentHistory();
        await DataBaseHelper.instance.deleteMedicineData();
        await DataBaseHelper.instance.deleteMedicineHistory();
        await DataBaseHelper.instance.deleteNotificationData();
        await DataBaseHelper.instance.deleteFamilyMemberData();
        await DataBaseHelper.instance.deleteDoctor();
        await DataBaseHelper.instance.deleteUser();
        await flutterLocalNotificationsPlugin.cancelAll();
        Get.deleteAll(force: true);

        Get.offAllNamed(AppRoutes.getStarted);
        Utils.showToast(context, "toastLogOut".tr);
        debugPrint('Home:Logout Success');
      } catch (e) {
        debugPrint('Home:Logout Fail');
        debugPrint(e.toString());
        Utils.showToast(context, e.toString());
      }
    } else {
      Utils.showToast(context, "txtCheckYourInternetConnectivity".tr);
    }
  }

  onTapSingOut(BuildContext context) {
    Scaffold.of(context).closeDrawer();
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        builder: (context) => DeleteConformation(
            title: 'txtQLogOut'.tr,
            description: 'txtLogOutDescription'.tr,
            buttonText: 'txtLogOut'.tr,
            image: Utils.isLightTheme()
                ? Assets.icons.icLogoutImg.path
                : Assets.icons.icLogoutImgDark.path,
            imageHeight: AppSizes.height_21,
            imageWidth: AppSizes.height_21,
            onTapDelete: () {
              singOut(context);
            }));
    // Get.dialog(const SignOutDialog(), useSafeArea: false);
  }

  getThemeString() {
    if (theme == AppThemeMode.dark.toString()) {
      return "txtDark".tr;
    } else {
      return "txtLight".tr;
    }
  }

  Future<void> syncDataToFirebase() async {
    // No Firebase auth for guest users → skip cloud sync entirely (data stays
    // safe in the local SQLite source of truth and syncs once they sign in).
    if (!Preference.shared.getIsUserLogin()) return;
    List<MedicineTable> medicineList =
        await DataBaseHelper.instance.getMedicineData(isNotSynced: true);
    if (medicineList.isNotEmpty) {
      medicineList = medicineList.map((e) {
        e.mIsSynced = 1;
        return e;
      }).toList();
      await FireStoreHelper().updateMedicineBatchByMid(medicineList);
      await DataBaseHelper.instance.updateAllMedicineDataToSync();
    }

    List<MedicineHistoryTable> medicineHistoryDataList =
        await DataBaseHelper.instance.getMedicineHistoryData(isNotSynced: true);
    if (medicineHistoryDataList.isNotEmpty) {
      medicineHistoryDataList = medicineHistoryDataList.map((e) {
        e.mIsSynced = 1;
        return e;
      }).toList();
      await FireStoreHelper()
          .updateMedicineHistoryBatchByHid(medicineHistoryDataList);
      await DataBaseHelper.instance.updateAllMedicineHistoryDataToSync();
    }

    List<JournalTable> appointmentDataList =
        await DataBaseHelper.instance.getAppointmentTableData(isNotSynced: true);
    if (appointmentDataList.isNotEmpty) {
      appointmentDataList = appointmentDataList.map((e) {
        e.mIsSynced = 1;
        return e;
      }).toList();
      await FireStoreHelper()
          .updateAppointmentBatchByAid(appointmentDataList);
      await DataBaseHelper.instance.updateAllAppointmentDataToSync();
    }

    List<JournalHistoryTable> appointmentHistoryDataList =
        await DataBaseHelper.instance.getAppointmentHistoryData(isNotSynced: true);
    if (appointmentHistoryDataList.isNotEmpty) {
      appointmentHistoryDataList = appointmentHistoryDataList.map((e) {
        e.mIsSynced = 1;
        return e;
      }).toList();
      await FireStoreHelper()
          .updateAppointmentHistoryBatchByAHid(appointmentHistoryDataList);
      await DataBaseHelper.instance.updateAllAppointmentHistoryDataToSync();
    }

    List<FamilyMemberTable> familyMemberDataList =
        await DataBaseHelper.instance.getFamilyMemberData(null, true);
    if (familyMemberDataList.isNotEmpty) {
      familyMemberDataList = familyMemberDataList.map((e) {
        e.mIsSynced = 1;
        return e;
      }).toList();
      await FireStoreHelper()
          .updateFamilyMemberBatch(familyMemberDataList);
      await DataBaseHelper.instance.updateAllFamilyMemberDataToSync();
    }

    List<DoctorsTable> doctorsDataList =
        await DataBaseHelper.instance.getDoctorsData(isNotSynced  :true);
    if (doctorsDataList.isNotEmpty) {
      doctorsDataList = doctorsDataList.map((e) {
        e.mIsSynced = 1;
        return e;
      }).toList();
      await FireStoreHelper()
          .updateDoctorsBatch(doctorsDataList);
      await DataBaseHelper.instance.updateAllDoctorsDataToSync();
    }

    update([Constant.idHome]);
  }

  showAd() async {
    if (interstitialAd != null &&
        isInterstitialAdLoaded &&
        Preference.shared.getInterstitialAdCount() %
                Constant.interstitialCount ==
            0) {
      // Utils.showHideStatusBar();
      Debug.printLog('showAd :');
      await interstitialAd!.show();
    }
    Preference.shared
        .setInterstitialAdCount(Preference.shared.getInterstitialAdCount() + 1);
  }

  void _loadInterstitialAd() {
    if (Debug.googleAd) {
      InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();

                _loadInterstitialAd();
              },
            );

            interstitialAd = ad;
            isInterstitialAdLoaded = true;
            update([Constant.idHome]);
          },
          onAdFailedToLoad: (err) {
            Debug.printLog('Failed to load an interstitial ad: ${err.message}');
          },
        ),
      );
    }
  }

  @override
  void onBillingError(error) {
    update([Constant.idHome, Constant.idDrawerSheet]);
  }

  @override
  void onLoaded(bool initialized) {}

  @override
  void onPending(PurchaseDetails product) {}

  @override
  void onSuccessPurchase(PurchaseDetails product) {
    update([Constant.idHome, Constant.idDrawerSheet]);
  }

  goToProfile(BuildContext context) {
    if (!Preference.shared.getIsPurchase()) {
      showAd();
    }
    Scaffold.of(context).closeDrawer();
    Get.toNamed(AppRoutes.addOrEditProfile,
        parameters: {Constant.idIsEditProfile: "true"});
  }

  void onTabSelected(int tabIndex) {
    selectedTabIndex = tabIndex;
    mainTabController!.index = selectedTabIndex;
    update([Constant.idHome]);
  }

  void gotoAddMedicine(BuildContext context) {
    int length = Get.find<MedicineScreenLogic>()
        .medicineTableList
        .where((element) => element!.mIsDeleted != 1)
        .toList()
        .length;
    Debug.printLog('appointmentList length : $length');
    if (Preference.shared.getIsPurchase() || length < 10) {
      if (!Preference.shared.getIsPurchase()) {
        showAd();
        Get.toNamed(AppRoutes.add)!.then((value) {
          Debug.printLog('showAd getAllFamilyMembers:');
          Get.find<MedicineScreenLogic>().getAllFamilyMembers();
        });
      } else {
        Debug.printLog('showAd 2:');
        Get.toNamed(AppRoutes.add)!.then((value) {
          Get.find<MedicineScreenLogic>().getAllFamilyMembers();
        });
      }
    } else {
      Preference.shared
          .setLastPaywallTs(DateTime.now().millisecondsSinceEpoch);
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: true,
          builder: (context) => CommonSubscriptionDialog(
                title: 'txtPaywallTitleMedicines'.tr,
                description: 'txtPaywallBodyMedicines'.tr,
                buttonText: 'txtPaywallCtaUpgrade'.tr,
                ctaSubtext: 'txtPaywallCtaSubtext'.tr,
                priceLabel: InAppPurchaseHelper().monthlyPriceLabel,
                image: Assets.images.imgSuscription.path,
                imageWidth: AppSizes.height_35,
                onTapDelete: () {
                  Get.back();
                  Get.toNamed(AppRoutes.proVersion);
                },
              ));
    }
  }

  void goToAddJournal(BuildContext context) {
    int length = Get.find<JournalScreenLogic>()
        .journalList
        .where((element) => element!.mIsDeleted != 1)
        .toList()
        .length;
    if (Preference.shared.getIsPurchase() || length < 10) {
      if (!Preference.shared.getIsPurchase()) {
        Debug.printLog('showAd 1:');
        showAd();
        Get.toNamed(AppRoutes.addOrEditJournal)!.then((value) =>
            Get.find<JournalScreenLogic>().getAllFamilyMembers());
      } else {
        Debug.printLog('showAd 2:');
        Get.toNamed(AppRoutes.addOrEditJournal)!.then((value) =>
            Get.find<JournalScreenLogic>().getAllFamilyMembers());
      }
    } else {
      Preference.shared
          .setLastPaywallTs(DateTime.now().millisecondsSinceEpoch);
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: true,
          builder: (context) => CommonSubscriptionDialog(
                title: 'txtPaywallTitleAppointments'.tr,
                description: 'txtPaywallBodyAppointments'.tr,
                buttonText: 'txtPaywallCtaUpgrade'.tr,
                ctaSubtext: 'txtPaywallCtaSubtext'.tr,
                priceLabel: InAppPurchaseHelper().monthlyPriceLabel,
                image: Assets.images.imgSuscription.path,
                imageWidth: AppSizes.height_35,
                onTapDelete: () {
                  Get.back();
                  Get.toNamed(AppRoutes.proVersion);
                },
              ));
    }
  }

  Future<void> reScheduleNotifications() async {
    List<MedicineTable> medicineDataList =
        await DataBaseHelper.instance.getMedicineData(isNotDeletedOnly: true);
    DateTime today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    Debug.printLog("isFromLogin: $isFromLogin");
    for (var medicineTable in medicineDataList) {
      Debug.printLog("medicineTable  : ${medicineTable.toJson()}");
      if (isFromLogin) {
        await NotificationHelper()
            .scheduleDailyNotificationNew(medicineTable: medicineTable);
      }

      if (medicineTable.mIsNoEndDate == 1) {
        Duration diffInDays =
            DateTime.parse(medicineTable.mStartDate!).difference(today);
        Debug.printLog("difference In days ${diffInDays.inDays}");
        if (diffInDays.inDays > 0) {
          medicineTable.mStartDate = medicineTable.mEndDate;
          medicineTable.mEndDate = DateTime.parse(medicineTable.mEndDate!)
              .add(Duration(days: diffInDays.inDays))
              .toString();
          await NotificationHelper()
              .scheduleDailyNotificationNew(medicineTable: medicineTable);
        }
      }
    }

    List<JournalTable> appointmentDataList =
        await DataBaseHelper.instance.getAppointmentTableData();
    // for (var appointmentTable in appointmentDataList) {
    //   if (isFromLogin) {
    //     await NotificationHelper()
    //         .scheduleAppointment(appointmentTable: appointmentTable);
    //   }
    // }
    NotificationHelper().scheduleMedicineNotification();
  }

  void goToSetting(BuildContext context) {
    if (!Preference.shared.getIsPurchase()) {
      showAd();
    }
    Get.toNamed(AppRoutes.setting);
  }

  Future<void> getUserData() async {
    await DataBaseHelper.instance
        .getUserData(Preference.shared.getString(Preference.firebaseEmail))
        .then((value) {
      userData = value.isNotEmpty ? value.first : null;
      update([Constant.idHome, Constant.idDrawerSheet]);
    });
  }

  void gotoFamilyMember() {
    if (!Preference.shared.getIsPurchase()) {
      showAd();
    }
    Get.toNamed(AppRoutes.familyMember)!.then((value) {
      Get.find<MedicineScreenLogic>().getAllFamilyMembers();
      Get.find<JournalScreenLogic>().getAllFamilyMembers();
    });
  }

  /// F14 — Family is now a tab. FAB on the Family tab calls this to push
  /// the Add Family Member screen and refresh dependent lists on return.
  void gotoAddFamilyMember(BuildContext context) {
    if (!Preference.shared.getIsPurchase()) {
      showAd();
    }
    Get.toNamed(AppRoutes.addOrEditFamilyMember)!.then((value) {
      Get.find<MedicineScreenLogic>().getAllFamilyMembers();
      Get.find<JournalScreenLogic>().getAllFamilyMembers();
    });
  }

  /// Deprecated — Doctor screen is out of MVP scope (2026-05-10).
  /// Kept because notification deep-links may still reach this controller
  /// method via legacy payloads. Don't surface in nav.
  void gotoDoctorScreen() {
    if (!Preference.shared.getIsPurchase()) {
      showAd();
    }
    Get.toNamed(AppRoutes.doctorsScreen);
  }

  void gotoHistoryScreen() {
    if (!Preference.shared.getIsPurchase()) {
      showAd();
    }
    Get.toNamed(AppRoutes.historyScreen)!.then((value) {
      Get.find<MedicineScreenLogic>().getAllFamilyMembers();
      Get.find<JournalScreenLogic>().getAllFamilyMembers();
    });
  }
}
