import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/date_timeline.dart';
import 'package:medinest/Widgets/no_history_widget.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/medicine_history_table.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

import 'medicine_history_screen_logic.dart';

class MedicineHistoryScreenPage extends StatelessWidget {
  const MedicineHistoryScreenPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Get.theme.colorScheme.background,
      child: Column(
        children: [
          Container(
            width: AppSizes.fullWidth,
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.onPrimaryContainer,
              borderRadius: const BorderRadiusDirectional.only(
                bottomStart: Radius.circular(35),
                bottomEnd: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(
                      0.2),
                  spreadRadius: 0.5,
                  blurRadius: 7,
                  offset: const Offset(0, 5), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    GetBuilder<MedicineHistoryScreenLogic>(
                        id:Constant.idHistoryTimeLine,
                        builder: (logic) {
                          return DateTimeline(
                            onDateChange: logic.onDateChanged,
                            focusDate: logic.currantDate,
                          );
                        }),
                    GetBuilder<MedicineHistoryScreenLogic>(
                      id : Constant.idMedicineHistory,
                        builder: (logic) {
                      return Positioned(
                          bottom: 15,
                          right: 30,
                          child: InkWell(
                            onTap: logic.filteredMedicineHistoryTableList.isNotEmpty?logic.onDeleteHistory:null,
                            child: Image.asset(
                              Assets.iconsIcDeleteHistory,
                              color: logic.filteredMedicineHistoryTableList.isNotEmpty?Get.theme.colorScheme.secondary:Get.theme.colorScheme.surface,
                              height: AppSizes.width_5_5,
                              width: AppSizes.width_5_5,
                            ),
                          ));
                    })
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: GetBuilder<MedicineHistoryScreenLogic>(
                id: Constant.idMedicineHistory,
                builder: (logic) {
                  return logic.filteredMedicineHistoryTableList.isNotEmpty
                      ? ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: AppFontSize.size_16,
                        horizontal: AppFontSize.size_4),
                    itemCount: logic.filteredMedicineHistoryTableList.length,
                    itemBuilder: (context, index) {
                      return _medicine(medicineHistoryData: logic
                          .filteredMedicineHistoryTableList[index]!);
                    },
                  )
                      : NoHistoryWidget(
                    image: Assets.imagesImgNoHistory,
                    text: 'txtHistoryNotFound'.tr,
                    description: 'txtHistoryNotFoundDescription'.tr,
                    buttonText: 'txtCreateMedicineReminder'.tr,
                    onTapCreate: () {
                      logic.gotoAddMedicine(context);
                    },
                  );
                }),
          )
        ],
      ),
    );
  }

  _medicine({required MedicineHistoryTable medicineHistoryData}) {
    return GetBuilder<MedicineHistoryScreenLogic>(
        id: Constant.idMedicineItem,
        builder: (logic) {
          MedicineTable medicineData = logic.medicineTableList
              .where((element) =>
          element!.mId == medicineHistoryData.medicineId)
              .toList()
              .first!;
          FamilyMemberTable familyMember = logic.familyMembersList
              .where((element) => element!.fId == medicineHistoryData.takenById)
              .toList()
              .first!;

          Color? otherColor;

          if (medicineData.mColorPhotoType == "shadeColor") {
            Color color = Color(int.parse(medicineData.mColorPhoto!));
            String colorString = color.toString();
            String valueString = colorString.split('(0x')[1].split(')')[0];
            int value = int.parse(valueString, radix: 16);
            otherColor = Color(value);
          }
          Uint8List? imageData = logic.allShapeList
              .where((element) => element.sId == medicineData.mSelectedShapeId!)
              .first
              .shapeImage;

          // int times =
          //     NotificationHelper().parseTimeList(medicineData.mTime!).length;

          DateTime startDate = DateTime.parse(medicineHistoryData.takenTime!);

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 25,
              right: 10,
              left: 10,
            ),
            child: InkWell(
              onTap: () => logic.editHistory(medicineHistoryData),
              child: Container(
                height: AppSizes.height_21,
                decoration: BoxDecoration(
                    color: Color.lerp(otherColor!, Colors.white, 0.90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 1,
                        color: Color.lerp(otherColor, Colors.white, 0.40)!),
                    boxShadow: [
                      BoxShadow(
                          color: Get.context!.theme.primaryColor.withOpacity(
                              0.3),
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                          blurRadius: 8)
                    ]),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                          width: AppSizes.width_20,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.lerp(otherColor, Colors.white, 0.40),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Image.memory(imageData!,
                              fit: BoxFit.scaleDown,
                              height: AppSizes.width_5,
                              width: AppSizes.width_5),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                                text: medicineHistoryData.medicineName ?? "",
                                textColor:
                                Color.lerp(otherColor, Colors.black, 0.60)!,
                                maxLines: 1,
                                fontWeight: FontWeight.w500,
                                fontSize: AppFontSize.size_18),
                            SizedBox(
                              height: AppSizes.height_0_2,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: otherColor.withOpacity(0.4)),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  )),
                              child: CommonText(
                                  text: medicineData.mIsBeforeOrAfterFood ?? "",
                                  textColor: Color.lerp(
                                      otherColor, Colors.black, 0.60)!,
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppFontSize.size_8),
                            ),
                            SizedBox(
                              height: AppSizes.height_2,
                            ),
                            Row(
                              children: [
                                Image.asset(Assets.iconsIcUserName,
                                    color: Color.lerp(
                                        otherColor, Colors.black, 0.60)!,
                                    height: AppSizes.width_4_5,
                                    width: AppSizes.width_4_5),
                                SizedBox(width: AppSizes.width_2),
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth: AppSizes.fullWidth / 2.1),
                                  child: CommonText(
                                      text:
                                      '${'txtTakenBy'.tr} ${familyMember.name}',
                                      textColor: Color.lerp(
                                          otherColor, Colors.black, 0.60)!,
                                      maxLines: 1,
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppFontSize.size_11),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: AppSizes.height_2,
                            ),
                            Row(
                              children: [
                                Image.asset(Assets.iconsIcWatch,
                                    color: Color.lerp(
                                        otherColor, Colors.black, 0.60)!,
                                    height: AppSizes.width_4_5,
                                    width: AppSizes.width_4_5),
                                SizedBox(width: AppSizes.width_2),
                                CommonText(
                                    text: DateFormat('hh:mm a').format(
                                        startDate),
                                    textColor: Color.lerp(
                                        otherColor, Colors.black, 0.60)!,
                                    fontWeight: FontWeight.w500,
                                    fontSize: AppFontSize.size_11),
                                SizedBox(width: AppSizes.width_5),
                                // Image.memory(imageData,
                                //     color: Color.lerp(
                                //         otherColor, Colors.black, 0.60)!,
                                //     height: AppSizes.width_4_5,
                                //     width: AppSizes.width_4_5),
                                SizedBox(width: AppSizes.width_2),
                                // CommonText(
                                //     text:
                                //     '${medicineData.mDosage} ${medicineData.mUnits!.capitalizeFirst}',
                                //     textColor: Color.lerp(
                                //         otherColor, Colors.black, 0.60)!,
                                //     fontWeight: FontWeight.w500,
                                //     fontSize: AppFontSize.size_11),
                              ],
                            ),

                            SizedBox(
                              height: AppSizes.height_1,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsetsDirectional.fromSTEB(
                                0, 15, 15, 15),
                            child: Image.asset(
                              medicineHistoryData.isTaken == 1 ? Assets
                                  .iconsIcTaken : Assets.iconsIcSuspand,
                              width: AppSizes.width_6,
                              height: AppSizes.width_6,
                            ),
                          ),
                        ],
                      )
                    ]),
              ),
            ),
          );
        });
  }
}
