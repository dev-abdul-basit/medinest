import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/medicine_detail_dialog.dart';
import 'package:medinest/Widgets/no_data_widget.dart';
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
          return logic.medicineTableList.isNotEmpty &&
                  logic.medicineTableList
                      .where((element) =>
                          element!.mFamilyMemberId! == familyMemberId)
                      .toList()
                      .isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.symmetric(
                      vertical: AppFontSize.size_12,
                      horizontal: AppFontSize.size_4),
                  itemCount: logic.medicineTableList
                      .where((element) =>
                          element!.mFamilyMemberId! == familyMemberId &&
                          element.mIsDeleted != 1)
                      .toList()
                      .reversed
                      .toList()
                      .length,
                  itemBuilder: (context, index) {
                    return _medicine(
                        medicineData: logic.medicineTableList
                            .where((element) =>
                                element!.mFamilyMemberId! == familyMemberId &&
                                element.mIsDeleted != 1)
                            .toList()
                            .reversed
                            .toList()[index]!);
                  },
                )
              : NoDataWidget(
                  image: Assets.imagesImgNoMedicine,
                  text: 'txtYouDontHaveAnyMedicine'.tr,
                );
        });
  }

  _medicine({required MedicineTable medicineData}) {
    return GetBuilder<MedicineScreenLogic>(
        id: Constant.idMedicineItem,
        builder: (logic) {
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
          Uint8List? imageData = logic.allShapeList
              .where((element) => element.sId == medicineData.mSelectedShapeId!)
              .first
              .shapeImage;

          int times =
              NotificationHelper().parseTimeList(medicineData.mTime!).length;

          DateTime startDate = DateTime.parse(medicineData.mStartDate!);
          DateTime endDate = DateTime.parse(medicineData.mEndDate!);

          return InkWell(
            onTap: () {
              if (!Preference.shared.getIsPurchase()) {
                Get.find<HomeController>().showAd();
              }
                MedicineDetailsDialog(
                    medicineData: medicineData,
                    onTapEdit: () {
                      Get.back();
                      Get.toNamed(AppRoutes.add,
                              arguments: [true, medicineData])!
                          .then((value) => logic.getAllFamilyMembers());
                      // Get.find<DoctorsScreenLogic>()
                      //     .gotoEditDoctor(medicineData!);
                    },
                    onTapDelete: () {
                      Get.back();
                      deleteBottomSheet(Get.context!, medicineData);
                    }).scaleDialog(Get.context!);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25, right: 6, left: 6),
              child: Container(
                height: AppSizes.height_21,
                decoration: BoxDecoration(
                    color: Color.lerp(otherColor!, Colors.white, 0.90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 1.5,
                      color: otherColor,
                    ),
                    // Color.lerp(otherColor, Colors.white, 0.40)!),
                    boxShadow: [
                      BoxShadow(
                          color: Get.theme.colorScheme.secondaryContainer
                              .withOpacity(0.3),
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
                            color: otherColor,
                            // Color.lerp(otherColor, Colors.white, 0.40),
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
                                text: medicineData.mName ?? "",
                                maxLines: 1,
                                textColor:
                                    Color.lerp(otherColor, Colors.black, 0.60)!,
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
                                Image.asset(Assets.iconsIcWatch,
                                    color: Color.lerp(
                                        otherColor, Colors.black, 0.60)!,
                                    height: AppSizes.width_4_5,
                                    width: AppSizes.width_4_5),
                                SizedBox(width: AppSizes.width_2),
                                CommonText(
                                    text: '$times ${'txtTimes'.tr}',
                                    textColor: Color.lerp(
                                        otherColor, Colors.black, 0.60)!,
                                    fontWeight: FontWeight.w500,
                                    fontSize: AppFontSize.size_11),
                                SizedBox(width: AppSizes.width_5),
                                Image.asset(Assets.iconsIcDosage,
                                    color: Color.lerp(
                                        otherColor, Colors.black, 0.60)!,
                                    height: AppSizes.width_4_5,
                                    width: AppSizes.width_4_5),
                                // Image.memory(imageData,
                                //     color: Color.lerp(
                                //         otherColor, Colors.black, 0.60)!,
                                //     height: AppSizes.width_4_5,
                                //     width: AppSizes.width_4_5),
                                SizedBox(width: AppSizes.width_2),
                                Expanded(
                                  child: CommonText(
                                      text:
                                          '${medicineData.mDosage} ${medicineData.mUnits!.capitalizeFirst}',
                                      maxLines: 1,
                                      textColor: Color.lerp(
                                          otherColor, Colors.black, 0.60)!,
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
                                Image.asset(Assets.iconsIcCalendar,
                                    color: Color.lerp(
                                        otherColor, Colors.black, 0.60)!,
                                    height: AppSizes.width_4_5,
                                    width: AppSizes.width_4_5),
                                SizedBox(width: AppSizes.width_1),
                                CommonText(
                                    text: DateFormat('dd-MM-yyyy')
                                        .format(startDate),
                                    textColor: Color.lerp(
                                        otherColor, Colors.black, 0.60)!,
                                    fontWeight: FontWeight.w500,
                                    fontSize: AppFontSize.size_11),
                                if (medicineData.mIsNoEndDate == 0)
                                  CommonText(
                                      text: ' to ',
                                      textColor: Color.lerp(
                                          otherColor, Colors.black, 0.60)!,
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppFontSize.size_11),
                                if (medicineData.mIsNoEndDate == 0)
                                  CommonText(
                                      text: DateFormat('dd-MM-yyyy')
                                          .format(endDate),
                                      textColor: Color.lerp(
                                          otherColor, Colors.black, 0.60)!,
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppFontSize.size_11),
                              ],
                            ),
                            SizedBox(height: AppSizes.height_1),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsetsDirectional.fromSTEB(
                                0, 15, 10, 15),
                            child: Image.asset(
                              medicineData.mIsActive == 1
                                  ? Assets.iconsIcActive
                                  : Assets.iconsIcSuspand,
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
