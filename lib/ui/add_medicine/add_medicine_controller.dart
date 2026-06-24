import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/add_success_dialoge.dart';
import 'package:medinest/Widgets/choose_color.dart';
import 'package:medinest/Widgets/cupertino_pickers.dart';
import 'package:medinest/Widgets/select_shape.dart';
import 'package:medinest/Widgets/select_sound_screen_view.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/database/tables/shape_table.dart';
import 'package:medinest/Widgets/frequency_select_dialog.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_logic.dart';
import 'package:medinest/utils/ringtone_service.dart';
import 'package:medinest/utils/color.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/utils.dart';

class AddMedicineController extends GetxController with WidgetsBindingObserver {
  final formKey = GlobalKey<FormState>();
  TextEditingController medicineNameController = TextEditingController();
  TextEditingController dosageController = TextEditingController();
  bool isEdit = false;
  MedicineTable? medicines;
  ShapeTable? selectedShape;
  List<ShapeTable> allShapeList = [];
  dynamic args = Get.arguments;
  String? dosage;
  bool isUserActive = true;
  bool? isSuspend = false;

  bool isShowProgress = false;

  bool shouldSaveShow = false;

  bool isNoEndDate = false;


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

  List<FamilyMemberTable> familyMembersList = [];
  FamilyMemberTable? selectedFamilyMembers;

  List<DoctorsTable> doctorsList = [];
  DoctorsTable? selectedDoctorItem;

  AppLifecycleState? _appLifecycleState;
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(isRingPlaying){
      stopRingTone();
    }
  }
  @override
  Future<void> onInit() async {
    WidgetsBinding.instance.addObserver(this);
    await getAllShape();
    await getAllFamilyMembers();
    await getAllDoctors();

    getDataFromArgs();

    medicineNameController.text = (isEdit ? medicines?.mName : "")!;
    dosageController.text = (isEdit ? dosage : "")!;

    // Open a fresh add-form ready to save — only Name, Dose and Time are left
    // for the user; everything else is pre-filled with a sensible default.
    applyDefaults();

    super.onInit();
  }

  /// Brand-blue default pill colour (matches AppColor.colorSecondaryLight).
  static const Color _defaultPillColor = AppColor.colorSecondaryLight;

  /// Fill any unset optional field with a sensible default so a medicine can be
  /// saved with just Name + Dose + Time. Mirrors the onboarding "first medicine"
  /// defaults. Safe to call repeatedly (only fills nulls).
  void _ensureSaveDefaults() {
    dosageChoose ??= 'PILLS';
    if (selectedShape == null && allShapeList.isNotEmpty) {
      selectedShape = allShapeList.first;
    }
    shadeColor ??= _defaultPillColor;
    beforeOrAfterMeal ??= 'Take Any Time';
    startDate ??= DateTime.now();
    // No explicit end date → treat as ongoing rather than blocking the save.
    if (endDate == null) isNoEndDate = true;
    if (frequency == null) {
      selectedEverydayFrequency = true;
      updateFrequency();
    }
    selectedFamilyMembers ??= _resolveSelfMember();
  }

  /// The current user's own "Me" profile, used as the default owner so the user
  /// doesn't have to pick themselves every time.
  FamilyMemberTable? _resolveSelfMember() {
    if (familyMembersList.isEmpty) return null;
    final int? selfId = Preference.shared.getSelfMemberId();
    if (selfId != null) {
      final matches = familyMembersList.where((m) => m.fId == selfId);
      if (matches.isNotEmpty) return matches.first;
    }
    return familyMembersList.first;
  }

  /// Pre-fill defaults for a brand-new medicine (no-op while editing — there we
  /// load the medicine's own saved values).
  void applyDefaults() {
    if (isEdit) return;
    _ensureSaveDefaults();
    update([
      Constant.idSelectUnit,
      Constant.idSelectedShape,
      Constant.idSelectedColor,
      Constant.idSelectBeforeOrAfterMeal,
      Constant.idSelectStartDate,
      Constant.idSelectEndDate,
      Constant.idNoEndDate,
      Constant.idSelectFrequency,
      Constant.idSelectMember,
    ]);
  }

  splitDosage() {
    List<String>? mDosage = medicines?.mDosage?.split(" ");
    dosage = mDosage?[0];
    dosageChoose = medicines?.mUnits ?? '';
  }

  splitColor() {
    if (medicines?.mColorPhotoType == "shadeColor") {
      shadeColor = Color(int.parse(medicines!.mColorPhoto!, radix: 16));
    }
    // if (medicines?.mColorPhotoType == "shadeColor") {
    //   Color color = Color(int.parse(medicines!.mColorPhoto!));
    //   String colorString = color.toString();
    //   String valueString = colorString.split('(0x')[1].split(')')[0];
    //   int value = int.parse(valueString, radix: 16);
    //   shadeColor = Color(value);
    // }
  }

  getDataFromArgs() {
    if (Platform.isAndroid) {
      changeSelectedRing(sound: Constant.soundList.first, needToPlay: false);
      saveSound(needToBack: false, isFromInit: true);
    }
    if (args != null) {
      if (args[0] != null) {
        isEdit = args[0];
      }
      if (args[1] != null) {
        medicines = args[1];
      }
      if (isEdit) {
        splitDosage();
        splitColor();
        pickedSoundTitle = medicines?.mSoundTitle;
        frequency = medicines!.mFrequencyType!;
        if (frequency != "Every day") {
          String modifiedString = medicines!.mDayOfWeek!
              .replaceAll(' ', '')
              .replaceAll('[', '')
              .replaceAll(']', '');
          List<String> stringList = modifiedString.split(',');
          List<int> intList =
              stringList.map((string) => int.parse(string)).toList();
          for (var i in intList) {
            selectSpecificDay(index: i - 1, value: true);
          }
        }
        selectedShape = allShapeList
            .where((element) => element.sId == medicines!.mSelectedShapeId)
            .toList()
            .first;
        parseTimeList(medicines!.mTime!);
        startDate = DateTime.parse(medicines!.mStartDate!);
        pickedSoundType = medicines?.mSoundType;
        endDate = DateTime.parse(medicines!.mEndDate!);
        pickedSoundUri = medicines?.mDeviceSoundUri ?? '';
        pickedTempSoundTitle = medicines?.mSoundTitle ?? '';
        beforeOrAfterMeal = medicines!.mIsBeforeOrAfterFood!;
        isNoEndDate = medicines!.mIsNoEndDate == 1;
        if (familyMembersList
            .where((element) => element.fId == medicines!.mFamilyMemberId)
            .isNotEmpty) {
          selectedFamilyMembers = familyMembersList
              .where((element) => element.fId == medicines!.mFamilyMemberId)
              .toList()
              .first;
        } else {
          selectedFamilyMembers = null;
        }
        if (doctorsList
            .where((element) => element.dId == medicines!.mDoctorId)
            .toList()
            .isNotEmpty) {
          selectedDoctorItem = doctorsList
              .where((element) => element.dId == medicines!.mDoctorId)
              .toList()
              .first;
        } else {
          selectedDoctorItem = null;
        }
        isUserActive = medicines?.mIsActive == 0 ? false : true;
      }
      update([
        Constant.idUserNameInput,
        Constant.idUserNameInput,
        Constant.idSelectUnit,
        Constant.idSelectedShape,
        Constant.idSelectedColor,
        Constant.idSelectBeforeOrAfterMeal,
        Constant.idSelectStartDate,
        Constant.idSelectEndDate,
        Constant.idNoEndDate,
        Constant.idSelectedTime,
        Constant.idSelectedTime,
        Constant.idSelectFrequency,
        Constant.idSelectEveryDay,
        Constant.idSelectAlertSound,
        Constant.idSelectMember,
        Constant.idSelectDoctor,
        Constant.isUserActive,
        Constant.idProVersionProgress,
      ]);
    }
  }

  String? dosageChoose;

  String? beforeOrAfterMeal;
  String? pickedSoundTitle;
  String? pickedTempSoundTitle;
  String? pickedSoundType;
  String? pickedSoundUri;
  String? pickedTempSoundUri;
  Color? shadeColor;
  DateTime? startDate, endDate;

  List<int> selectedDayInt = [];

  String? frequency; //'Specific day';

  bool selectedEverydayFrequency = true;
  List<TimeOfDay> selectedTimeList = [];
  int id = 1;
  List<bool> selectedWeekDaysList =
      List<bool>.filled(Constant.weekDaysList.length, true);



  void onDropDownItemSelected(String newSelectedBank) {
    dosageChoose = newSelectedBank;
    update([Constant.idSelectedDosage]);
  }

  List<TimeOfDay> parseTimeList(String data) {
    // Extract time strings from the data string
    final regex = RegExp(r"TimeOfDay\((\d{2}:\d{2})\)");
    final matches = regex.allMatches(data);

    for (Match match in matches) {
      String timeString = match.group(1)!;
      List<String> parts = timeString.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      selectedTimeList.add(TimeOfDay(hour: hour, minute: minute));
    }

    return selectedTimeList;
  }

  gotoSelectColor(BuildContext context) async {
    Utils.unFocusKeyboard();

    shadeColor = null;
    shouldSaveShow = false;
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => ChooseColor(
              title: "txtChooseColor".tr,
              defaultColor: shadeColor,
              onTapSave: (color) {
                if (color != null) {
                  shadeColor = color;
                  Debug.printLog(
                      ":: shadeColor!.value.toString() ::: ${shadeColor!.value.toString()}");
                  update([Constant.idSelectedColor]);
                }
                Get.back();
              },
            ));

    // Map<String, dynamic> map = await Get.toNamed(AppRoutes.selectColor);
    //
    // if (map[Constant.idImageArg] != null) {
    //   image = map[Constant.idImageArg];
    // } else if (map[Constant.idColorArg] != null) {
    //   shadeColor = map[Constant.idColorArg];
    // }
    // update([Constant.idSelectedColor]);
  }

  gotoSelectAlertSound() async {
    Utils.unFocusKeyboard();
    if (pickedTempRingtoneUri == null) {
      pickedTempSoundTitle = pickedSoundTitle ?? Constant.soundList[0];
    }
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        isScrollControlled: true,
        builder: (context) => const SelectSoundScreenPage());

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

  Future<void> selectStartDate() async {
    Utils.unFocusKeyboard();
    final DateTime currentDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

// Ensure startDate is not before the current date
    if (startDate == null || startDate!.isBefore(currentDate)) {
      startDate = currentDate;
    }

    final DateTime? picked = await showAppDatePicker(
      initial: startDate!,
      minimum: currentDate,
      maximum: endDate ?? DateTime(2101),
    );

    if (picked != null) {
      startDate = picked;
      Debug.printLog("Start Date: ${startDate.toString()}");
      update([Constant.idSelectStartDate]);
    }
  }

  Future<void> selectEndDateDate() async {
    Utils.unFocusKeyboard();
    final DateTime currentDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if (startDate != null &&
        (endDate == null || endDate!.isBefore(startDate!))) {
      endDate = startDate;
    } else if (startDate == null && endDate == null) {
      endDate = currentDate;
      startDate = currentDate;
    } else if (startDate == null && endDate != null) {
      startDate = endDate;
    }

    final DateTime? picked = await showAppDatePicker(
      initial: endDate!,
      minimum: startDate!,
      maximum: DateTime(2101),
    );
    if (picked != null) {
      endDate = picked;
      update([Constant.idSelectEndDate]);
    }
  }

  selectFrequency() {
    Utils.unFocusKeyboard();

    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        isScrollControlled: true,
        builder: (context) => FrequencySelectDialog(
              onTapSave: () {
                updateFrequency();
                Get.back();
              },
            ));
  }

  insertMedicineToDatabase(context) async {
    // Required: Name + Dose + at least one Time. Everything else is optional and
    // gets a sensible default via _ensureSaveDefaults() below.
    if (medicineNameController.text.trim().isEmpty) {
      Utils.showToast(context, 'toastMedicineName'.tr);
      return false;
    }
    if (dosageController.text.trim().isEmpty) {
      Utils.showToast(context, 'toastDosageName'.tr);
      return false;
    }
    if (selectedTimeList.isEmpty) {
      Utils.showToast(context, 'toastSelectTime'.tr);
      return false;
    }
    _ensureSaveDefaults();
    if (selectedFamilyMembers == null) {
      // Safety net — a self profile is normally guaranteed to exist.
      Utils.showToast(context, 'txtSelectMember'.tr);
      return false;
    }

    // Construct the mDosage string using dosageController and dosageChoose
    String dosage = dosageController.text.trim();

    // Determine mColorPhoto based on whether image is available
    String? colorPhoto = shadeColor?.value.toString();

    // Determine mFrequencyType based on selectedEverydayFrequency
    String frequencyType =
        selectedEverydayFrequency ? "Every day" : "Specific day";

    // Construct mDayOfWeek string using selectedDayInt
    String dayOfWeek = selectedDayInt.toString();

    // Construct mTime string using selectedTimeList
    String time = selectedTimeList.toString();

    // Determine mIsFromDevice based on pickedSoundType
    int isFromDevice = pickedSoundType == "Sound" ? 0 : 1;
    // Insert medicine data into database
    Utils.unFocusKeyboard();
    MedicineTable medicineTable = MedicineTable(
        mId: null,
        mName: medicineNameController.text.trim(),
        mDosage: dosage,
        mUnits: dosageChoose,
        mSelectedShapeId: selectedShape!.sId!,
        mColorPhoto: colorPhoto,
        mIsBeforeOrAfterFood: beforeOrAfterMeal,
        mDeviceSoundUri: pickedSoundUri,
        mStartDate: startDate.toString(),
        mEndDate: isNoEndDate
            ? startDate!.add(const Duration(days: 30)).toString()
            : endDate.toString(),
        mIsNoEndDate: isNoEndDate ? 1 : 0,
        mCurrentTime: DateTime.now().toString(),
        mColorPhotoType: "shadeColor",
        mFrequencyType: frequencyType,
        mSoundType: pickedSoundType,
        mDayOfWeek: dayOfWeek,
        mTime: time,
        mIsFromDevice: isFromDevice,
        mIsActive: isUserActive ? 1 : 0,
        mSoundTitle: pickedSoundTitle,
        mDoctorId: selectedDoctorItem?.dId,
        mFamilyMemberId: selectedFamilyMembers!.fId,
        mIsSynced: 0,
        mIsDeleted: 0);
    Debug.printLog("Start Date: ${medicineTable.mStartDate.toString()}");
    Debug.printLog("End Date: ${medicineTable.mEndDate.toString()}");

    isShowProgress = true;
    update([Constant.idProVersionProgress]);

    var result = await DataBaseHelper.instance.insertMedicineData(
      medicineTable,
    );
    medicineTable.mId = result;

    // Cloud write only when signed in — a guest's data stays local (mIsSynced=0)
    // and is pushed automatically once they sign in. Never write to a stale or
    // null account.
    if (Preference.shared.getIsUserLogin() &&
        await InternetConnectivity.isInternetConnect(Get.context!)) {
      FireStoreHelper().addAndUpdateMedicine(result.toString(), medicineTable);
    }
    List<MedicineTable> medicineDataList =
        await DataBaseHelper.instance.getMedicineData(result: result);
    // Debug.printLog("insert MedicineData res: $result");

    // for (MedicineTable medicineTable in medicineDataList) {
    //   Debug.printLog("insert MedicineData res: ${medicineTable.toJson()}");
    // }

    await NotificationHelper()
        .scheduleDailyNotificationNew(medicineTable: medicineDataList[0]);
    NotificationHelper().scheduleMedicineNotification();
    Get.find<MedicineScreenLogic>().getAllFamilyMembers();
    // Get.back();
    update([
      Constant.idHome,
      Constant.idMedicineList,
    ]);
    clearData();
    AddSuccessDialog(
      successTitle: 'txtCongratulations'.tr,
      successDescription: 'txtSuccessfullyAddMedicine'.tr,
      buttonText: 'txtBackToHome'.tr,
    ).scaleDialog(Get.context!);
  }

  updateMedicineToDatabase(context) async {
    // Required: Name + Dose + at least one Time. Everything else is optional and
    // gets a sensible default via _ensureSaveDefaults() below.
    if (medicineNameController.text.trim().isEmpty) {
      Utils.showToast(context, 'toastMedicineName'.tr);
      return false;
    }
    if (dosageController.text.trim().isEmpty) {
      Utils.showToast(context, 'toastDosageName'.tr);
      return false;
    }
    if (selectedTimeList.isEmpty) {
      Utils.showToast(context, 'toastSelectTime'.tr);
      return false;
    }
    _ensureSaveDefaults();
    if (selectedFamilyMembers == null) {
      // Safety net — a self profile is normally guaranteed to exist.
      Utils.showToast(context, 'txtSelectMember'.tr);
      return false;
    }

    // Construct the mDosage string using dosageController and dosageChoose
    String dosage = dosageController.text.trim();

    // Determine mColorPhoto based on whether image is available
    String? colorPhoto = shadeColor?.value.toString();

    // Determine mFrequencyType based on selectedEverydayFrequency
    String frequencyType =
        selectedEverydayFrequency ? "Every day" : "Specific day";

    // Construct mDayOfWeek string using selectedDayInt
    String dayOfWeek = selectedDayInt.toString();

    // Construct mTime string using selectedTimeList
    String time = selectedTimeList.toString();

    // Determine mIsFromDevice based on pickedSoundType
    int isFromDevice = pickedSoundType == "Sound" ? 0 : 1;

    // Insert medicine data into database
    Utils.unFocusKeyboard();
    MedicineTable medicineTable = MedicineTable(
        mId: medicines?.mId,
        mName: medicineNameController.text.trim(),
        mDosage: dosage,
        mUnits: dosageChoose,
        mSelectedShapeId: selectedShape!.sId!,
        mColorPhoto: colorPhoto,
        mIsBeforeOrAfterFood: beforeOrAfterMeal,
        mDeviceSoundUri: pickedSoundUri,
        mStartDate: startDate.toString(),
        mEndDate: isNoEndDate
            ? startDate!.add(const Duration(days: 30)).toString()
            : endDate.toString(),
        mIsNoEndDate: isNoEndDate ? 1 : 0,
        mCurrentTime: DateTime.now().toString(),
        mColorPhotoType: "shadeColor",
        mFrequencyType: frequencyType,
        mSoundType: pickedSoundType,
        mDayOfWeek: dayOfWeek,
        mTime: time,
        mIsFromDevice: isFromDevice,
        mIsActive: isUserActive ? 1 : 0,
        mSoundTitle: pickedSoundTitle,
        mDoctorId: selectedDoctorItem?.dId,
        mFamilyMemberId: selectedFamilyMembers!.fId,
        mIsSynced: 0,
        mIsDeleted: 0);
    isShowProgress = true;
    update([Constant.idProVersionProgress]);
    await DataBaseHelper.instance.updateMedicineData(
      medicines!.mId!,
      medicineTable,
    );

    if (Preference.shared.getIsUserLogin() &&
        await InternetConnectivity.isInternetConnect(Get.context!)) {
      FireStoreHelper()
          .addAndUpdateMedicine(medicines!.mId!.toString(), medicineTable);
    }

    /// medicine

    List<MedicineTable> medicineDataList =
        await DataBaseHelper.instance.getMedicineData(result: medicines!.mId!);
    // Debug.printLog("insert MedicineData res: $result");
    //
    // for (MedicineTable medicineTable in medicineDataList) {
    //   Debug.printLog("insert MedicineData res: ${medicineTable.toJson()}");
    // }

    // FireStoreHelper().deleteNotificationsBatchByMid(medicines!.mId!);
    await DataBaseHelper.instance.deleteNotificationData(id: medicines!.mId!);

    await NotificationHelper()
        .scheduleDailyNotificationNew(medicineTable: medicineDataList[0]);
    NotificationHelper().scheduleMedicineNotification();
    Get.find<MedicineScreenLogic>().getAllFamilyMembers();
    Get.find<MedicineScreenLogic>().update(
        [Constant.idHome, Constant.idMedicineList, Constant.isMedicineDetails]);
    clearData();
    AddSuccessDialog(
      successTitle: 'txtCongratulations'.tr,
      successDescription: 'txtSuccessfullyUpdateMedicine'.tr,
      buttonText: 'txtBackToHome'.tr,
    ).scaleDialog(Get.context!);
  }

  void selectSpecificDay({required int index, required bool value}) {
    selectedEverydayFrequency = false;
    selectedWeekDaysList[index] = value;
    int lengthOfSelectedWeekDaysList =
        selectedWeekDaysList.where((element) => element == true).length;

    if (lengthOfSelectedWeekDaysList == 0) {
      selectedEverydayFrequency = true;
    }

    update([Constant.idSelectEveryDay, Constant.idSelectSpecificDay]);
  }

  onTapUserActive() {
    isUserActive = !isUserActive;
    isSuspend = false;
    update([Constant.isUserActive]);
  }

  onTapSuspend() {
    isUserActive = !isUserActive;
    isSuspend = true;
    update([Constant.isUserActive]);
  }

  void changeSelectEveryDay({required bool value}) {
    if (value) {
      selectedEverydayFrequency = value;
      selectedWeekDaysList =
          List.generate(selectedWeekDaysList.length, (index) => true);
    } else {
      selectedEverydayFrequency = value;
      selectedWeekDaysList = List.generate(
          selectedWeekDaysList.length, (index) => index == 0 ? true : false);
    }
    update([Constant.idSelectEveryDay, Constant.idSelectSpecificDay]);
  }

  void updateFrequency() {
    frequency = selectedEverydayFrequency ? 'Every day' : 'Specific day';

    selectedDayInt.clear();

    if (selectedEverydayFrequency) {
      for (var i = 1; i < 8; i++) {
        selectedDayInt.add(i);
      }
    } else {
      for (var i = 0; i < selectedWeekDaysList.length; i++) {
        if (selectedWeekDaysList[i]) {
          selectedDayInt.add(i + 1);
        }
      }
    }

    update([Constant.idSelectFrequency]);
  }

  Future<void> selectTime(BuildContext context) async {
    Utils.unFocusKeyboard();

    final TimeOfDay? pickedS = await showAppTimePicker(initial: TimeOfDay.now());

    if (pickedS != null) {
      selectedTimeList.add(pickedS); // Directly add to list
      update([Constant.idSelectedTime]);
    }
  }

  void deleteSelectedTime({required int index}) {
    selectedTimeList.removeAt(index);
    update([Constant.idSelectedTime]);
  }

  gotoSelectShape(BuildContext context) {
    allShapeList
        .map((e) => selectedShape != null
            ? e.sId == selectedShape!.sId
                ? e.isSelected = true
                : e.isSelected = false
            : e.isSelected = false)
        .toList();
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => SelectShape(
              title: 'txtSelectShape'.tr,
              onTapSave: () {
                if (allShapeList
                    .where((element) => element.isSelected)
                    .toList()
                    .isNotEmpty) {
                  selectedShape =
                      allShapeList.firstWhere((element) => element.isSelected);
                  update([Constant.idSelectedShape]);
                  Get.back();
                }
              },
            ));
  }

  Future<void> getAllShape() async {
    allShapeList = await DataBaseHelper.instance.getAllShapesData();
  }

  void onSelectShape(int index) {
    allShapeList.map((e) => e.isSelected = (e.sId == (index + 1))).toList();
    update([Constant.idShapeList]);
  }



  void deleteTimeFormList(int index) {
    selectedTimeList.removeAt(index);
    update([Constant.idSelectedTime]);
  }

  Future<void> getAllFamilyMembers() async {
    familyMembersList = await DataBaseHelper.instance.getFamilyMemberData();
    selectedFamilyMembers = null;
    update([Constant.idSelectMember]);
  }

  Future<void> getAllDoctors() async {
    try {
      doctorsList = await DataBaseHelper.instance.getDoctorsData(isList: true);
      selectedDoctorItem = null;
      update([Constant.idSelectDoctor]);
    } catch (e) {
      Debug.printLog(e.toString());
    }
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

  void onChangedActiveStatus(bool value) {
    isUserActive = value;
    update([Constant.isUserActive]);
  }

  void clearData() {
    medicineNameController.text = '';
    dosageController.text = '';
    dosageChoose = null;
    beforeOrAfterMeal = null;
    selectedShape = null;
    shadeColor = null;
    pickedSoundUri = null;
    startDate = null;
    endDate = null;
    isNoEndDate = false;
    selectedEverydayFrequency = true;
    updateFrequency();
    pickedSoundType = 'Sound';
    selectedDayInt = [];
    selectedTimeList.clear();
    isUserActive = true;
    pickedSoundTitle = null;
    selectedDoctorItem = null;
    selectedFamilyMembers = null;
    isShowProgress = false;
    update([
      Constant.idUserNameInput,
      Constant.idUserNameInput,
      Constant.idSelectUnit,
      Constant.idSelectedShape,
      Constant.idSelectedColor,
      Constant.idSelectBeforeOrAfterMeal,
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
    // Leave the form ready-to-use after a Reset (fresh add only).
    applyDefaults();
  }

  void onSelectColor(int index) {
    colorList.map((e) => e.isSelected = (e.indexColor == (index))).toList();
    update([Constant.idColorList]);
  }

  List<ColorPicker> colorList = [
    ColorPicker(
        indexColor: 0, color: const Color(0XFF8FF2DE), isSelected: false),
    ColorPicker(
        indexColor: 1, color: const Color(0XFFF0E28A), isSelected: false),
    ColorPicker(
        indexColor: 2, color: const Color(0XFFF9DDD9), isSelected: false),
    ColorPicker(
        indexColor: 3, color: const Color(0XFF81D5F8), isSelected: false),
    ColorPicker(
        indexColor: 4, color: const Color(0XFF9CAAFA), isSelected: false),
    ColorPicker(
        indexColor: 5, color: const Color(0XFF99D0FB), isSelected: false),
    ColorPicker(
        indexColor: 6, color: const Color(0XFF9EDFFD), isSelected: false),
    ColorPicker(
        indexColor: 7, color: const Color(0XFF9FF1FC), isSelected: false),
    ColorPicker(
        indexColor: 8, color: const Color(0XFF95F5EB), isSelected: false),
    ColorPicker(
        indexColor: 9, color: const Color(0XFF95F499), isSelected: false),
    ColorPicker(
        indexColor: 10, color: const Color(0XFFCCF79A), isSelected: false),
    ColorPicker(
        indexColor: 11, color: const Color(0XFFEFF993), isSelected: false),
    ColorPicker(
        indexColor: 12, color: const Color(0XFFFAF19D), isSelected: false),
    ColorPicker(
        indexColor: 13, color: const Color(0XFFF9E197), isSelected: false),
    ColorPicker(
        indexColor: 14, color: const Color(0XFFFFD79D), isSelected: false),
    ColorPicker(
        indexColor: 15, color: const Color(0XFFFDB29A), isSelected: false),
    ColorPicker(
        indexColor: 16, color: const Color(0XFFFBB599), isSelected: false),
    ColorPicker(
        indexColor: 17, color: const Color(0XFFFC9A9A), isSelected: false),
    ColorPicker(
        indexColor: 18, color: const Color(0XFF9CDFFF), isSelected: false),
  ];
}
