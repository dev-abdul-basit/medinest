import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/illustrated_empty_state.dart';
import 'package:medinest/Widgets/medicine_detail_dialog.dart';
import 'package:medinest/Widgets/onboarding_illustrations.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/ui/home/home_controller.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';

class MedicineListScreen extends StatelessWidget {
  final int familyMemberId;

  const MedicineListScreen({super.key, required this.familyMemberId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MedicineScreenLogic>(
        id: Constant.idMedicineList,
        builder: (logic) {
          // Only this member's *non-deleted* medicines. Deletes are soft
          // (mIsDeleted == 1) and stay in the list, so the empty check MUST
          // filter them — otherwise a deleted-only list renders an empty
          // ListView (a blank white screen) instead of the empty state.
          final List<MedicineTable> meds = logic.medicineTableList
              .where((element) =>
                  element!.mFamilyMemberId == familyMemberId &&
                  element.mIsDeleted != 1)
              .cast<MedicineTable>()
              .toList()
              .reversed
              .toList();

          if (meds.isEmpty) {
            return IllustratedEmptyState(
              art: OnboardArt.pill,
              title: 'txtNoRemindersTitle'.tr,
              subtitle: 'txtNoRemindersSub'.tr,
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppFontSize.size_4,
                AppFontSize.size_12,
                AppFontSize.size_4,
                AppSizes.height_16), // clear the floating glass nav
            itemCount: meds.length,
            itemBuilder: (context, index) =>
                _medicine(medicineData: meds[index]),
          );
        });
  }

  _medicine({required MedicineTable medicineData}) {
    return GetBuilder<MedicineScreenLogic>(
        id: Constant.idMedicineItem,
        builder: (logic) {
          final scheme = Get.theme.colorScheme;

          // Per-medicine accent colour chosen by the user.
          Color accent = scheme.primary;
          if (medicineData.mColorPhotoType == "shadeColor") {
            accent = Color(int.parse(medicineData.mColorPhoto!, radix: 16));
          }

          final shapeMatch = logic.allShapeList
              .where((element) => element.sId == medicineData.mSelectedShapeId);
          final Uint8List? imageData =
              shapeMatch.isNotEmpty ? shapeMatch.first.shapeImage : null;

          final List<TimeOfDay> timeList =
              NotificationHelper().parseTimeList(medicineData.mTime ?? '');
          final int times = timeList.length;
          final String? nextLabel = _nextTimeLabel(timeList);

          final DateTime startDate = DateTime.parse(medicineData.mStartDate!);
          final DateTime endDate = DateTime.parse(medicineData.mEndDate!);
          final bool active = medicineData.mIsActive == 1;

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (!Preference.shared.getIsPurchase()) {
                Get.find<HomeController>().showAd();
              }
              MedicineDetailsDialog(
                  medicineData: medicineData,
                  onTapEdit: () {
                    Get.back();
                    Get.toNamed(AppRoutes.add, arguments: [true, medicineData])!
                        .then((value) => logic.getAllFamilyMembers());
                  },
                  onTapDelete: () {
                    Get.back();
                    deleteBottomSheet(Get.context!, medicineData);
                  }).scaleDialog(Get.context!);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 4, left: 4),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: scheme.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withOpacity(0.22), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.12),
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left accent bar = medicine identity colour.
                      Container(width: 5, color: accent),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Pill avatar.
                              Container(
                                width: AppSizes.height_8,
                                height: AppSizes.height_8,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: imageData != null
                                    ? Image.memory(imageData,
                                        fit: BoxFit.contain, color: accent)
                                    : Icon(Icons.medication_rounded,
                                        color: accent),
                              ),
                              SizedBox(width: AppSizes.width_3_5),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CommonText(
                                            text: medicineData.mName ?? "",
                                            maxLines: 1,
                                            textColor: scheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                            fontSize: AppFontSize.size_16,
                                          ),
                                        ),
                                        Image.asset(
                                          active
                                              ? Assets.icons.icActive.path
                                              : Assets.icons.icSuspand.path,
                                          width: AppSizes.width_5_5,
                                          height: AppSizes.width_5_5,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppSizes.height_1),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        _chip(
                                          accent: accent,
                                          icon: Icons.restaurant_rounded,
                                          text:
                                              medicineData.mIsBeforeOrAfterFood ??
                                                  '',
                                        ),
                                        _chip(
                                          accent: accent,
                                          icon: Icons.medication_liquid_rounded,
                                          text:
                                              '${medicineData.mDosage} ${medicineData.mUnits?.capitalizeFirst ?? ''}',
                                        ),
                                        _chip(
                                          accent: accent,
                                          icon: Icons.repeat_rounded,
                                          text: '$times ${'txtTimes'.tr}',
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppSizes.height_1),
                                    Row(
                                      children: [
                                        Icon(
                                          nextLabel != null
                                              ? Icons.schedule_rounded
                                              : Icons.event_rounded,
                                          size: AppFontSize.size_15,
                                          color: accent,
                                        ),
                                        SizedBox(width: AppSizes.width_1_5),
                                        Expanded(
                                          child: CommonText(
                                            text: nextLabel != null
                                                ? '${'txtNext'.tr}: $nextLabel'
                                                : _dateRange(
                                                    medicineData, startDate,
                                                    endDate),
                                            maxLines: 1,
                                            textColor: scheme.onSurface
                                                .withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                            fontSize: AppFontSize.size_11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  /// Small rounded info chip tinted with the medicine's accent colour.
  Widget _chip({
    required Color accent,
    required IconData icon,
    required String text,
  }) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppFontSize.size_12, color: accent),
          const SizedBox(width: 4),
          CommonText(
            text: text,
            textColor: Color.lerp(accent, Get.theme.colorScheme.onSurface, 0.35)!,
            fontWeight: FontWeight.w600,
            fontSize: AppFontSize.size_10,
          ),
        ],
      ),
    );
  }

  /// Next upcoming time today (else the first scheduled time), formatted.
  String? _nextTimeLabel(List<TimeOfDay> times) {
    if (times.isEmpty) return null;
    final now = TimeOfDay.now();
    final int nowMins = now.hour * 60 + now.minute;
    final sorted = [...times]
      ..sort((a, b) =>
          (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    final TimeOfDay next = sorted.firstWhere(
      (t) => (t.hour * 60 + t.minute) > nowMins,
      orElse: () => sorted.first,
    );
    return DateFormat('h:mm a')
        .format(DateTime(2020, 1, 1, next.hour, next.minute));
  }

  String _dateRange(
      MedicineTable m, DateTime startDate, DateTime endDate) {
    final start = DateFormat('dd-MM-yyyy').format(startDate);
    if (m.mIsNoEndDate == 0) {
      return '$start  →  ${DateFormat('dd-MM-yyyy').format(endDate)}';
    }
    return start;
  }

  Future<dynamic> deleteBottomSheet(
      BuildContext context, MedicineTable medicineData) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => DeleteConformation(
              title: 'txtDeleteMedicine'.tr,
              description: 'txtAreYouSureYouWantToDeleteThisMedicine'.tr,
              onTapDelete: () {
                Get.find<MedicineScreenLogic>().deleteMedicine(medicineData);
              },
            ));
  }
}
