import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/add_success_dialoge.dart';
import 'package:medinest/Widgets/select_sound_appointment_screen_view.dart';
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
import 'package:medinest/ui/appointment_screen/appointment_screen_logic.dart';
import 'package:medinest/utils/ringtone_service.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/utils.dart';

class AddOrEditAppointmentLogic extends GetxController {
  bool isShowProgress = false;
  final formKey = GlobalKey<FormState>();

  List<FamilyMemberTable> familyMembersList = [];
  FamilyMemberTable? selectedFamilyMembers;

  List<DoctorsTable> doctorsList = [];
  DoctorsTable? selectedDoctorItem;

  DateTime? startDate;

  TimeOfDay? tempSelectedTime;

  String? minutesChoose;

  TextEditingController commentController = TextEditingController();
  TextEditingController titleController = TextEditingController();


  bool isEdit = false;
  bool isReSchedule = false;
  AppointmentHistoryTable? appointmentHistoryTable;

  List<Ringtone> ringtones = [];
  static AudioPlayer audioPlayer = AudioPlayer();
  static const channel = MethodChannel('ringtone_channel');
  String pickedRingtoneTitle = "txtTakeRingtone".tr;

  String? pickedRingtoneUri;

  String pickedTempRingtoneTitle = "txtTakeRingtone".tr;

  String? pickedTempRingtoneUri;

  bool isRingPlaying = false;
  List<bool> selectedSoundList =
      List<bool>.filled(Constant.soundList.length, false);
  String? pickedSoundTitle;
  String? pickedTempSoundTitle;
  String? pickedSoundType;
  String? pickedSoundUri;
  String? pickedTempSoundUri;

  dynamic args = Get.arguments;
  AppointmentTable? appointmentData;



  @override
  Future<void> onInit() async {
    super.onInit();
    await getAllFamilyMembers();
    await getAllDoctors();
    getDataFromArgs();
  }

  getDataFromArgs() {
    if (Platform.isAndroid) {
      changeSelectedRing(sound: Constant.soundList.first, needToPlay: false);
      saveSound(needToBack: false, isFromInit: true);
    }
    if (args != null) {
      if (args[0] != null) {
        isEdit = args[0];
        update();
      }
      if (args[1] != null) {
        appointmentData = args[1];
      }
      if (args[2] != null) {
        isReSchedule = args[2];
      }
      if (args[3] != null) {
        appointmentHistoryTable = args[3];
      }
      if (isEdit) {
        // pickedSoundUri = appointmentData?.mDeviceSoundUri ?? '';
        // startDate = DateTime.parse(appointmentData!.appointmentDate!);
        // pickedSoundType = appointmentData?.mSoundType ?? '';
        // pickedSoundTitle = appointmentData?.mSoundTitle ?? '';
        // selectedFamilyMembers = familyMembersList
        //     .where((element) =>
        //         element.fId == appointmentData!.bookedForFamilyMemberId)
        //     .toList()
        //     .first;
        // selectedDoctorItem = doctorsList
        //     .where((element) => element.dId == appointmentData!.doctorId)
        //     .toList()
        //     .first;
        // isShowProgress = false;
        // Debug.printLog(":: ::: ::: ${appointmentData!.reminderBeforeTime}");
        // minutesChoose = (appointmentData?.reminderBeforeTime == null ||
        //         appointmentData?.reminderBeforeTime == 'null')
        //     ? null
        //     : appointmentData!.reminderBeforeTime;
        titleController.text = appointmentData?.mSoundTitle ?? '';
        commentController.text = appointmentData?.description ?? '';
        // tempSelectedTime =
        //     parseTimeList(appointmentData!.appointmentTime!).first;
      }
      update([
        Constant.idAppointmentTitle,
        Constant.addAppointment,
        Constant.idUserNameInput,
        Constant.idSelectMinutesBeforeTime,
        Constant.idSelectStartDate,
        Constant.idSelectedTime,
        Constant.idSelectAlertSound,
        Constant.idSelectMember,
        Constant.idSelectDoctor,
        Constant.idProVersionProgress,
      ]);
    }
  }

  List<TimeOfDay> parseTimeList(String data) {
    // Extract time strings from the data string
    final regex = RegExp(r"TimeOfDay\((\d{2}:\d{2})\)");
    final matches = regex.allMatches(data);
    List<TimeOfDay> selectedTimeList = [];
    for (Match match in matches) {
      String timeString = match.group(1)!;
      List<String> parts = timeString.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      selectedTimeList.add(TimeOfDay(hour: hour, minute: minute));
    }

    return selectedTimeList;
  }


  @override
  void onClose() {
    titleController.dispose();
    commentController.dispose();
    super.onClose();
  }

  Future<void> getAllFamilyMembers() async {
    familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
    // selectedFamilyMembers = familyMembersList[0];
    Debug.printLog(":: ::: ::: $familyMembersList");
    update([Constant.idSelectMember]);
  }

  Future<void> getAllDoctors() async {
    doctorsList = await DataBaseHelper.instance.getDoctorsData(isList: true);
    // selectedDoctorItem = doctorsList[0];
    Debug.printLog(":: ::: ::: $doctorsList");
    update([Constant.idSelectDoctor]);
  }

  goToAddMember() {
    Get.toNamed(AppRoutes.addOrEditFamilyMember, parameters: {
      Constant.isFromMedicineOrAppointment: "true",
    })!
        .then((value) {
      getAllFamilyMembers();
    });
  }

  goToAddDoctor() {
    Get.toNamed(AppRoutes.addOrEditDoctor)!.then((value) {
      getAllDoctors();
    });
  }

  Future<void> selectStartDate() async {
    Utils.unFocusKeyboard();
    final DateTime currentDate = DateTime.now();

// Ensure startDate is not before the current date
    if (startDate == null || startDate!.isBefore(currentDate)) {
      startDate = currentDate;
    }

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: startDate!,
      firstDate: currentDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: sampleDatePickerThemeData,
            colorScheme: ColorScheme.light(
              primary: Get.theme.colorScheme.primary,
              onPrimary: Get.theme.colorScheme.background,
              onSurface: Get.theme.colorScheme.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Get.theme.colorScheme.primary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != startDate) {
      startDate = picked;
      update([Constant.idSelectStartDate]);
    }
  }

  DatePickerThemeData sampleDatePickerThemeData = DatePickerThemeData(
    headerBackgroundColor: Get.theme.colorScheme.primary,
    headerForegroundColor: Get.theme.colorScheme.onError,
    headerHeadlineStyle:
        const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
    headerHelpStyle:
        const TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
    yearOverlayColor: MaterialStateProperty.all<Color>(Colors.blue[100]!),
    weekdayStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Get.theme.colorScheme.onError),
    shadowColor: Colors.grey[300],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    surfaceTintColor: Colors.white,
  );

  Future<void> selectTime(BuildContext context) async {
    Utils.unFocusKeyboard();

    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay? pickedS = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: sampleDatePickerThemeData,
            colorScheme: ColorScheme.light(
              primary: Get.theme.colorScheme.primary,
              onPrimary: Get.theme.colorScheme.background,
              onSurface: Get.theme.colorScheme.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Get.theme.colorScheme.primary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedS != null && pickedS != selectedTime) {
      selectedTime = pickedS;
      tempSelectedTime = selectedTime;
      update([Constant.idSelectedTime]);
    }
  }

  gotoSelectAlertSound() async {
    Utils.unFocusKeyboard();
    if (pickedTempRingtoneUri == null) {
      pickedTempSoundTitle = Constant.soundList[0];
    }
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        isScrollControlled: true,
        builder: (context) => const SelectSoundAppointmentScreenPage());

    // update([Constant.idSelectAlertSound]);
  }

  Future<void> getRingtones() async {
    try {
      selectedSoundList =
          List.generate(selectedSoundList.length, (index) => false);
      pickedSoundUri = null;
      pickedSoundTitle = null;
      FlutterRingtonePlayer().stop();
      update([Constant.idListOfSounds]);
      final Map<dynamic, dynamic>? result =
          await channel.invokeMethod('getSystemRingtones');
      if (result != null && result.entries.isNotEmpty) {
        Debug.printLog('ringtones invokeMethod: ${result.entries}');
        pickedTempRingtoneTitle = result['Title'];
        pickedTempRingtoneUri = result['URI'];
        pickedTempSoundTitle = null;
        pickedTempSoundUri = null;
        update([Constant.idSelectAlertSound, Constant.idListOfSounds]);
      }
    } on PlatformException catch (ex) {
      if (kDebugMode) {
        print('Exception: $ex.message');
      }
    }
  }

  Future<void> playRingtone() async {
    if (pickedTempRingtoneUri != null) {
      isRingPlaying = await channel.invokeMethod(
          'playSystemRingtone', pickedTempRingtoneUri);
      update([Constant.idSelectAlertSound]);
    }
  }

  Future<void> stopRingTone() async {
    isRingPlaying = await channel.invokeMethod('stopSystemRingtone');
    update([Constant.idSelectAlertSound]);
  }

  void changeSelectedRing({required String sound, bool needToPlay = true}) {
    stopRingTone();
    pickedTempRingtoneTitle = "txtTakeRingtone".tr;
    pickedTempRingtoneUri = null;
    update([Constant.idSelectAlertSound]);
    pickedTempSoundTitle = sound;
    pickedTempSoundUri =
        'assets/sounds/${sound.toLowerCase().removeAllWhitespace}.mp3';
    if (needToPlay) {
      FlutterRingtonePlayer().play(fromAsset: pickedTempSoundUri);
    }
    update([Constant.idListOfSounds]);
  }

  void saveSound({bool needToBack = true, bool isFromInit = false}) {
    stopRingTone();
    FlutterRingtonePlayer().stop();
    if (!isFromInit) {
      pickedSoundUri = pickedTempRingtoneUri ?? pickedTempSoundUri;
      pickedSoundType = pickedTempRingtoneUri != null ? "Ringtone" : "Sound";
      pickedSoundTitle = pickedTempRingtoneUri != null
          ? pickedTempRingtoneTitle
          : pickedTempSoundTitle;
      Debug.printLog(":: Sound ::: ${pickedSoundUri.toString()}");
      Debug.printLog(":: Sound ::: ${pickedSoundTitle.toString()}");
      Debug.printLog(":: Sound ::: ${pickedSoundType.toString()}");
      update([Constant.idSelectAlertSound]);
    }

    if (needToBack) {
      Get.back();
    }
  }

  void clearData() {
    pickedSoundUri = null;
    startDate = null;
    pickedSoundType = 'Sound';
    pickedSoundTitle = null;
    selectedDoctorItem = null;
    selectedFamilyMembers = null;
    isShowProgress = false;
    minutesChoose = null;
    titleController.text = '';
    commentController.text = '';
    tempSelectedTime = null;
    update([
      Constant.idAppointmentTitle,
      Constant.idUserNameInput,
      Constant.idUserNameInput,
      Constant.idSelectUnit,
      Constant.idSelectedShape,
      Constant.idSelectedColor,
      Constant.idSelectBeforeOrAfterMeal,
      Constant.idSelectMinutesBeforeTime,
      Constant.idSelectStartDate,
      Constant.idSelectEndDate,
      Constant.idNoEndDate,
      Constant.idSelectedTime,
      Constant.idSelectedTime,
      Constant.idSelectFrequency,
      Constant.idSelectAlertSound,
      Constant.idSelectMember,
      Constant.idSelectDoctor,
      Constant.isUserActive,
      Constant.idProVersionProgress,
    ]);
  }

  submitData(BuildContext context) async {
    isShowProgress = true;
    update([Constant.idProVersionProgress]);
    // if (selectedFamilyMembers == null) {
    //   Utils.showToast(context, 'toastSelectBookingForMember'.tr);
    //   isShowProgress = false;
    //   update([Constant.idProVersionProgress]);
    //   return false;
    // }
    // if (selectedDoctorItem == null) {
    //   Utils.showToast(context, 'txtSelectDoctor'.tr);
    //   isShowProgress = false;
    //   update([Constant.idProVersionProgress]);
    //   return false;
    // }
    // if (startDate == null) {
    //   Utils.showToast(context, 'txtSelectDate'.tr);
    //   isShowProgress = false;
    //   update([Constant.idProVersionProgress]);
    //   return false;
    // }
    // if (tempSelectedTime == null) {
    //   Utils.showToast(context, 'toastSelectTime'.tr);
    //   isShowProgress = false;
    //   update([Constant.idProVersionProgress]);
    //   return false;
    // }
    // // if (minutesChoose == null) {
    // //   Utils.showToast(context, 'toastSelectBeforeTime'.tr);
    // //   isShowProgress = false;
    // //   update([Constant.idProVersionProgress]);
    // //   return false;
    // // }
    // // if (commentController.text.trim().isEmpty) {
    // //   Utils.showToast(context, 'toastEnterDescription'.tr);
    // //   isShowProgress = false;
    // //   update([Constant.idProVersionProgress]);
    // //   return false;
    // // }
    // if (Platform.isAndroid && pickedSoundUri == null) {
    //   Utils.showToast(context, 'toastSelectSound'.tr);
    //   isShowProgress = false;
    //   update([Constant.idProVersionProgress]);
    //   return false;
    // }
    // int isFromDevice = pickedSoundType == "Sound" ? 0 : 1;
    Utils.unFocusKeyboard();
    final String title = titleController.text.trim();
    final String description = commentController.text.trim();
    AppointmentTable appointmentTable = AppointmentTable(
        aId: isEdit ? appointmentData!.aId! : null,
        // bookedForFamilyMemberId: selectedFamilyMembers!.fId!,
        // doctorId: selectedDoctorItem!.dId!,
        // appointmentDate: startDate.toString(),
        // appointmentTime: tempSelectedTime.toString(),
        // mDeviceSoundUri: pickedSoundUri,
        // mSoundTitle: pickedSoundTitle,
        // mSoundType: pickedSoundType,
        // mIsFromDevice: isFromDevice,
       // reminderBeforeTime: minutesChoose,
        mSoundTitle: title,
        description: commentController.text.toString(),
        mIsSynced: 0,
        mIsDeleted: 0);

    try {
      if (isEdit && appointmentTable.aId != null) {
        // update existing
        await DataBaseHelper.instance.updateAppointmentData(
          appointmentTable.aId!,
          appointmentTable,
        );
      } else {
        // insert new
        var result = await DataBaseHelper.instance.insertAppointment(
          appointmentTable,
        );
        appointmentTable.aId = result;
      }

      // Optional: sync to Firestore if available (keeps same flow as before)
      if (await InternetConnectivity.isInternetConnect(Get.context!)) {
        FireStoreHelper().addAndUpdateAppointment(appointmentTable);
      }

      // keep UX similar: stop progress, show success, clear form, update views
      isShowProgress = false;
      update([Constant.idProVersionProgress]);

      AddSuccessDialog(
        successTitle: isEdit ? 'txtYourEntryHasUpdated'.tr : 'txtYourEntryHasCreated'.tr,
        isFromAppointment: true,
        successDescription: title.isNotEmpty ? title : description,
        buttonText: 'txtBackToHome'.tr,
      ).scaleDialog(Get.context!);

      // Clear local fields after successful save
      clearData();

      // Refresh screens that used to rely on appointments
      Get.find<AppointmentScreenLogic>().getAllFamilyMembers(); // if you still rely on this
      update([Constant.idHome, Constant.idMedicineList]);
    } catch (e, st) {
      Debug.printLog("Error saving journal entry: $e\n$st");
      isShowProgress = false;
      update([Constant.idProVersionProgress]);
      Utils.showToast(context, 'toastSomethingWentWrong'.tr);
    }
  }
    // TimeOfDay appointmentTime =
    //     parseTimeList(appointmentTable.appointmentTime!).first;
    // DateTime initialNotificationDateTime;
    // initialNotificationDateTime = DateTime(
    //   startDate!.year,
    //   startDate!.month,
    //   startDate!.day,
    //   appointmentTime.hour,
    //   appointmentTime.minute,
    // );
    // Debug.printLog("minutesChoose : $minutesChoose");
    // if (minutesChoose != null &&
    //     minutesChoose != 'null' &&
    //     minutesChoose != 'None') {
    //   initialNotificationDateTime = initialNotificationDateTime
    //       .subtract(Duration(minutes: int.parse(minutesChoose!)));
    // }
    // Debug.printLog(
    //     "insert initialNotificationDateTime res: $initialNotificationDateTime");
    // DateTime now = DateTime.now();
    // if (initialNotificationDateTime.isAfter(now)) {
    //   if (isEdit) {
    //     await DataBaseHelper.instance.updateAppointmentData(
    //       appointmentTable.aId!,
    //       appointmentTable,
    //     );
    //     if (isReSchedule && appointmentHistoryTable != null) {
    //       await DataBaseHelper.instance
    //           .insertOrUpdateAppointmentHistoryData(appointmentHistoryTable!);
    //       if (await InternetConnectivity.isInternetConnect(Get.context!)) {
    //         FireStoreHelper()
    //             .addAndUpdateAppointmentHistory(appointmentHistoryTable!);
    //       }
    //     }
    //   } else {
    //     var result = await DataBaseHelper.instance.insertAppointment(
    //       appointmentTable,
    //     );
    //     appointmentTable.aId = result;
    //   }
    //
    //   if (await InternetConnectivity.isInternetConnect(Get.context!)) {
    //     FireStoreHelper().addAndUpdateAppointment(appointmentTable);
    //   }
      //
      // List<AppointmentTable> appointmentDataList = await DataBaseHelper.instance
      //     .getAppointmentTableData(result: appointmentTable.aId);
      // List<AppointmentNotificationTable> notificationDataList =
      //     await DataBaseHelper.instance
      //         .getAppointmentNotificationData(result: appointmentTable.aId);
      //
      // for (var notification in notificationDataList) {
      //   Debug.printLog(
      //       "----<>-<>--Get NotificationData res: ${notification.toJson()}----<>-<>--");
      //   await flutterLocalNotificationsPlugin.cancel(appointmentTable.aId!);
      // }
      //
      // await DataBaseHelper.instance
      //     .deleteAppointmentNotificationData(id: appointmentTable.aId!);
      //
      // await NotificationHelper()
      //     .scheduleAppointment(appointmentTable: appointmentDataList[0]);
      //
      // NotificationHelper().reScheduleAppointmentNotification();
      // // Get.put(HomeController());
      // // Get.find<HomeController>().getDataFromDatabase();
      // // Get.back();
      // Get.find<AppointmentScreenLogic>().getAllFamilyMembers();
      // update([Constant.idHome, Constant.idMedicineList]);
      // DateTime? tempStartDate =
      //     DateTime.parse(appointmentTable.appointmentDate!);
      // TimeOfDay? tempSelectedTimeTwo = NotificationHelper()
      //     .parseTimeList(appointmentTable.appointmentTime!)
      //     .first;

      // String description =
      //     '${'txtYourAppointmentWith'.tr} ${selectedDoctorItem!.name!} ${'txtHasBeenOn'.tr} ${DateFormat('d MMM, yyyy').format(tempStartDate)} at ${tempSelectedTimeTwo.format(Get.context!)}';
  //     isShowProgress = false;
  //     update([Constant.idProVersionProgress]);
  //     AddSuccessDialog(
  //       successTitle: isEdit
  //           ? 'txtYourAppointmentHasUpdated'.tr
  //           : 'txtYourAppointmentHasCreated'.tr,
  //       isFromAppointment: true,
  //       // tempStartDate: tempStartDate,
  //       // tempSelectedTime: tempSelectedTimeTwo,
  //       successDescription: selectedDoctorItem!.name!,
  //       buttonText: 'txtBackToHome'.tr,
  //     ).scaleDialog(Get.context!);
  //     clearData();
  //   } else {
  //     Utils.showToast(context, 'toastSelectDateAndTimeProperly'.tr);
  //     isShowProgress = false;
  //     update([Constant.idProVersionProgress]);
  //   }
  // }
}
