import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_details_item.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_logic.dart';
import 'package:medinest/utils/color.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/sizer_utils.dart';

class MedicineDetailsDialog {
  final Function() onTapEdit;
  final Function() onTapDelete;
  final MedicineTable medicineData;

  MedicineDetailsDialog({required this.medicineData, required this.onTapEdit, required this.onTapDelete});

  void scaleDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(a1),
          child: _dialog(ctx),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _dialog(BuildContext context) {
    final logic = Get.find<MedicineScreenLogic>();
    Uint8List? imageData = logic.allShapeList.where((element) => element.sId == medicineData.mSelectedShapeId!).first.shapeImage;

    Color? otherColor;

    // if (medicineData.mColorPhotoType == "shadeColor") {
    //   Color color = Color(int.parse(medicineData.mColorPhoto!));
    //   String colorString = color.toString();
    //   String valueString = colorString.split('(0x')[1].split(')')[0];
    //   int value = int.parse(valueString, radix: 16);
    //   otherColor = Color(value);
    // }
    if (medicineData.mColorPhotoType == "shadeColor") {
      otherColor = Color(int.parse(medicineData.mColorPhoto!, radix: 16));
    }

    List<TimeOfDay> times = NotificationHelper().parseTimeList(medicineData.mTime!);

    DateTime startDate = DateTime.parse(medicineData.mStartDate!);
    DateTime endDate = DateTime.parse(medicineData.mEndDate!);

    FamilyMemberTable? familyMemberTable = logic.familyMembersList.where((element) => element!.fId! == medicineData.mFamilyMemberId).toList().first;

    String frequency = getDays();
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: AppSizes.fullWidth,
        height: AppSizes.fullHeight,
        padding: EdgeInsetsDirectional.fromSTEB(AppSizes.width_2, 0, AppSizes.width_2, 0),
        color: Get.theme.colorScheme.background,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: AppSizes.width_4),
                        child: Row(
                          children: [
                            Expanded(
                              child: CommonText(
                                  text: 'txtMedicineDetails'.tr,
                                  textColor: Get.theme.colorScheme.primary,
                                  textAlign: TextAlign.center,
                                  fontSize: AppFontSize.size_18,
                                  fontWeight: FontWeight.w600),
                            ),
                            InkWell(
                              onTap: () => Get.back(),
                              child: Image.asset(
                                Assets.iconsIcCloseDark,
                                color: Get.theme.colorScheme.tertiary,
                                height: AppSizes.height_2,
                                width: AppSizes.height_2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: AppSizes.height_16,
                            height: AppSizes.height_16,
                            padding: EdgeInsets.all(AppSizes.width_7),
                            margin: EdgeInsetsDirectional.only(start: AppSizes.width_3_5,top: AppSizes.width_5,bottom: AppSizes.width_5,end:AppSizes.width_4),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Color.lerp(otherColor, Colors.white, 0.40)),
                            child: Image.memory(imageData!, height: AppSizes.width_5, width: AppSizes.width_5),
                          ),
                          SizedBox(
                            width: AppSizes.width_1,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: AppSizes.fullWidth/2.1,
                                child: CommonText(
                                    text: medicineData.mName!,
                                    textColor: Get.theme.colorScheme.primary,
                                    textAlign: TextAlign.start,
                                    fontSize: AppFontSize.size_22,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: AppSizes.height_0_5,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                decoration: BoxDecoration(
                                    color: Get.theme.colorScheme.background,
                                    border: Border.all(color: Get.theme.colorScheme.onSurface),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(5),
                                    )),
                                child: CommonText(
                                    text: medicineData.mIsBeforeOrAfterFood ?? "",
                                    textColor: Get.theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppFontSize.size_10),
                              ),
                              SizedBox(
                                height: AppSizes.height_2,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          DetailItem(
                            subtitle: 'txtPatientName'.tr,
                            title: familyMemberTable!.name!,
                            icon: Assets.iconsIcUserName,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2_5,
                      ),
                      Row(
                        children: [
                          DetailItem(
                            subtitle: 'txtDosage'.tr,
                            title: '${medicineData.mDosage} ${medicineData.mUnits!.capitalizeFirst}',
                            iconWidget:Image.asset(Assets.iconsIcDosage,
                                color: Get.theme.colorScheme.onSurface,
                                height: AppSizes.width_4_5,
                                width: AppSizes.width_4_5),
                                // Image.memory(imageData, color: Get.theme.colorScheme.onSurface, height: AppSizes.width_4_5, width: AppSizes.width_4_5),
                          ),
                          DetailItem(
                            subtitle: 'txtStatusDetails'.tr,
                            title: medicineData.mIsActive == 1 ? 'Active' : 'Suspend',
                            textColor: medicineData.mIsActive == 1 ? AppColor.colorGreen : AppColor.colorOrange,
                            icon: Assets.iconsIcStatus,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2_5,
                      ),
                      Row(
                        children: [
                          DetailItem(
                            subtitle: 'txtFrequency'.tr,
                            title: frequency,
                            icon: Assets.iconsIcFrequency,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizes.height_2_5,
                      ),
                      DetailItem(
                        subtitle: 'txtStartEndDate'.tr,
                        titleWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CommonText(
                                text: DateFormat('dd-MM-yyyy').format(startDate),
                                textColor: Get.theme.colorScheme.primary,
                                textAlign: TextAlign.start,
                                fontSize: AppFontSize.size_12,
                                fontWeight: FontWeight.w600),
                            if(medicineData.mIsNoEndDate!=1)CommonText(
                                text: ' To ',
                                textColor: Get.theme.colorScheme.surface,
                                textAlign: TextAlign.start,
                                fontSize: AppFontSize.size_12,
                                fontWeight: FontWeight.w600),
                            if(medicineData.mIsNoEndDate!=1)CommonText(
                                text: DateFormat('dd-MM-yyyy').format(endDate),
                                textColor: Get.theme.colorScheme.primary,
                                textAlign: TextAlign.start,
                                fontSize: AppFontSize.size_12,
                                fontWeight: FontWeight.w600)
                          ],
                        ),
                        icon: Assets.iconsIcCalendar,
                      ),
                      SizedBox(
                        height: AppSizes.height_2_5,
                      ),
                      DetailItem(
                        subtitle: 'txtDosageTime'.tr,
                        titleWidget: Wrap(
                          spacing: 5,
                          runSpacing: -5,
                          alignment: WrapAlignment.start,
                          children: List.generate(times.length, (index) {
                            final time = times[index];
                            return InputChip(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              labelPadding: EdgeInsets.zero,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                              label: CommonText(
                                  text: time.format(Get.context!),
                                  textColor: Get.theme.colorScheme.inverseSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppFontSize.size_12),
                              onSelected: (bool selected) {},
                              backgroundColor: Get.theme.colorScheme.onSecondary,
                            );
                          }),
                        ),
                        icon: Assets.iconsIcWatch,
                      ),

                     
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonButtonOne(onTap: onTapEdit, backgroundColor: Get.theme.colorScheme.background, text: 'txtEdit'.tr),
                  SizedBox(
                    width: AppSizes.height_2,
                  ),
                  CommonButtonOne(onTap: onTapDelete, text: 'txtDelete'.tr),
                ],
              ),
              SizedBox(
                height: AppSizes.height_3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getDays() {
    if (medicineData.mFrequencyType == 'Every day') {
      return medicineData.mFrequencyType!;
    } else {
      String days = '';
      Debug.printLog('medicineData.mDayOfWeek : ${medicineData.mDayOfWeek}');
      String modifiedString = medicineData.mDayOfWeek!.replaceAll(' ', '').replaceAll('[', '').replaceAll(']', '');
      List<String> stringList = modifiedString.split(',');
      List<int> intList = stringList.map((string) => int.parse(string)).toList();
      for (var i in intList) {
        days = '$days${Constant.dayData[i]!},';
      }
      return days;
    }
  }
}
