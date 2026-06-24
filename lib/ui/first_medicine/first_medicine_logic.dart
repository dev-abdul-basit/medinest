import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/database/tables/shape_table.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

/// F07 — onboarding "set your first medicine in under 60 seconds".
///
/// A stripped-down medicine form: name + frequency only. Every other field the
/// full Add-Medicine screen requires (dose, unit, shape, colour, meal timing,
/// sound, dates) is filled with a sensible default here, so the user reaches a
/// scheduled reminder without any decisions. The row is written through the
/// exact same `medicine_table` + notification path as the full flow.
class FirstMedicineLogic extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final FocusNode nameFocus = FocusNode();

  /// 0 = once daily, 1 = twice daily, 2 = three times daily.
  int selectedFrequency = 0;
  bool isSaving = false;

  int? _selfMemberId;
  List<ShapeTable> _shapes = [];

  @override
  void onInit() {
    super.onInit();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      _shapes = await DataBaseHelper.instance.getAllShapesData();
      await _ensureSelfProfile();
    } catch (e) {
      Debug.printLog('F07 prepare failed: $e');
    }
  }

  /// Silently guarantee the "Me" profile exists so the first medicine has an
  /// owner, without forcing the profile screen. Resolves the canonical self row
  /// (and persists its id) so the medicine attaches to *self*, not to whatever
  /// dependent happened to be added first.
  Future<void> _ensureSelfProfile() async {
    _selfMemberId = await DataBaseHelper.instance
        .ensureSelfMember(selfName: 'txtSelfProfileName'.tr);
  }

  void selectFrequency(int index) {
    selectedFrequency = index;
    update([Constant.idFirstMedicine]);
  }

  /// Smart default times per frequency. The scheduler only fires times in the
  /// future, so a reminder always lands on the next upcoming slot.
  List<TimeOfDay> get reminderTimes {
    switch (selectedFrequency) {
      case 1:
        return const [
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 20, minute: 0),
        ];
      case 2:
        return const [
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 14, minute: 0),
          TimeOfDay(hour: 20, minute: 0),
        ];
      case 0:
      default:
        return const [TimeOfDay(hour: 8, minute: 0)];
    }
  }

  String formatTime(TimeOfDay t) {
    final int h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final String m = t.minute.toString().padLeft(2, '0');
    final String ap = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $ap';
  }

  String get reminderTimesLabel => reminderTimes.map(formatTime).join(', ');

  /// Power-user path: hand off to the full Add-Medicine form. The basic profile
  /// already exists, so the full form can attach to it.
  void openMoreOptions() {
    Get.toNamed(AppRoutes.add);
  }

  Future<void> saveFirstMedicine(BuildContext context) async {
    final String name = nameController.text.trim();
    if (name.isEmpty) {
      Utils.showToast(context, 'txtFirstMedNameError'.tr);
      nameFocus.requestFocus();
      return;
    }
    if (isSaving) return;
    isSaving = true;
    update([Constant.idFirstMedicine]);
    Utils.unFocusKeyboard();

    if (_selfMemberId == null) {
      await _ensureSelfProfile();
    }

    final DateTime now = DateTime.now();
    final DateTime startDate = DateTime(now.year, now.month, now.day);
    final List<TimeOfDay> times = reminderTimes;
    final int shapeId = _shapes.isNotEmpty ? (_shapes.first.sId ?? 1) : 1;

    final MedicineTable medicine = MedicineTable(
      mId: null,
      mName: name,
      mDosage: '1',
      mUnits: 'PILLS',
      mSelectedShapeId: shapeId,
      mColorPhoto: const Color(0xFF81D5F8).value.toString(),
      mColorPhotoType: 'shadeColor',
      mIsBeforeOrAfterFood: 'Take Any Time',
      mDeviceSoundUri: 'assets/sounds/defaulttone.mp3',
      mSoundType: 'Sound',
      mSoundTitle: 'Default Tone',
      mIsFromDevice: 0,
      mStartDate: startDate.toString(),
      mEndDate: startDate.add(const Duration(days: 30)).toString(),
      mIsNoEndDate: 1,
      mCurrentTime: now.toString(),
      mFrequencyType: 'Every day',
      mDayOfWeek: '[1, 2, 3, 4, 5, 6, 7]',
      mTime: times.toString(),
      mIsActive: 1,
      mDoctorId: null,
      mFamilyMemberId: _selfMemberId,
      mIsSynced: 0,
      mIsDeleted: 0,
    );

    try {
      final int id = await DataBaseHelper.instance.insertMedicineData(medicine);
      medicine.mId = id;
      final List<MedicineTable> inserted =
          await DataBaseHelper.instance.getMedicineData(result: id);
      if (inserted.isNotEmpty) {
        await NotificationHelper()
            .scheduleDailyNotificationNew(medicineTable: inserted.first);
        await NotificationHelper().scheduleMedicineNotification();
      }
      await Preference.shared.setFirstMedicineCreated(true);
    } catch (e) {
      Debug.printLog('F07 first-medicine save failed: $e');
    }

    isSaving = false;
    update([Constant.idFirstMedicine]);
    _celebrateAndGoHome();
  }

  /// Brief Lottie celebration, then straight to Home with the new reminder
  /// visible. Auto-dismisses so the user never has to tap through.
  void _celebrateAndGoHome() {
    Get.dialog(
      Center(
        child: Lottie.asset(
          'assets/animation/celibretion1.json',
          width: AppSizes.fullWidth / 1.4,
          repeat: false,
          fit: BoxFit.contain,
        ),
      ),
      barrierDismissible: false,
      barrierColor: Get.theme.colorScheme.primary.withOpacity(0.15),
    );
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(AppRoutes.home);
    });
  }

  /// "I'll add it later" — land on Home; they can add from there anytime.
  void skipForNow() {
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    nameController.dispose();
    nameFocus.dispose();
    super.onClose();
  }
}
