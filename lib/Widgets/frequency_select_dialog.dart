import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/ui/add_medicine/add_medicine_controller.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class FrequencySelectDialog extends StatelessWidget {
  final void Function() onTapSave;

  const FrequencySelectDialog({super.key, required this.onTapSave});

  @override
  Widget build(BuildContext context) {
    return _dialogWidget();
  }

  _dialogWidget() {
    return Wrap(
      children: [
        Container(
          width: AppSizes.fullWidth,
          padding: EdgeInsets.symmetric(
              vertical: AppSizes.height_2, horizontal: AppSizes.width_2),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surfaceVariant,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CommonText(
                  text: "txtAddFrequency".tr,
                  textColor: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.size_17),
              SizedBox(
                height: AppSizes.height_2,
              ),
              GetBuilder<AddMedicineController>(
                id: Constant.idSelectEveryDay,
                builder: (logic) {
                  return CheckboxListTile(
                    title: CommonText(
                        text: 'Every Day',
                        textColor: Get.theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w400,
                        fontSize: AppFontSize.size_12),
                    value: logic.selectedEverydayFrequency,
                    activeColor: Get.theme.colorScheme.onSecondary,
                  //   checkColor: Get.theme.colorScheme.background,
                  //   overlayColor: MaterialStateProperty.all<Color>(
                  //       Get.theme.colorScheme.primary),
                  //   fillColor: MaterialStateProperty.all<Color>(
                  // logic.selectedEverydayFrequency? Get.theme.colorScheme.onSecondary
                  //       : Get.theme.colorScheme.primaryContainer,),
                    onChanged: (value) {
                      logic.changeSelectEveryDay(value: value!);
                    },
                  );
                },
              ),
              SizedBox(
                height: AppFontSize.size_8_5,
              ),
              CommonText(
                  text: "txtSelectSpecific".tr,
                  textColor: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.size_17),
              buildWeekDaysList(),
              SizedBox(
                height: AppFontSize.size_8_5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonButtonOne(
                      onTap: () {
                        Get.back();
                      },
                      backgroundColor: Get.theme.colorScheme.background,
                      text: 'txtCancel'.tr),
                  SizedBox(
                    width: AppSizes.width_5,
                  ),
                  CommonButtonOne(onTap: onTapSave, text: 'txtSave'.tr),
                ],
              ),
              SizedBox(
                height: AppSizes.height_2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget buildWeekDaysList() {
    return GetBuilder<AddMedicineController>(
        id: Constant.idSelectSpecificDay,
        builder: (logic) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: Constant.weekDaysList.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: CommonText(
                    text: Constant.weekDaysList[index],
                    textColor: Get.theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w400,
                    fontSize: AppFontSize.size_12),
                activeColor: Get.theme.colorScheme.onSecondary,
                // checkColor: Get.theme.colorScheme.background,
                // overlayColor: MaterialStateProperty.all<Color>(
                //     Get.theme.colorScheme.primary),
                // fillColor: MaterialStateProperty.all<Color>(
                //   logic.selectedWeekDaysList[index]? Get.theme.colorScheme.onSecondary
                //     : Get.theme.colorScheme.primaryContainer,),
                value: logic.selectedWeekDaysList[index],
                onChanged: (value) {
                  logic.selectSpecificDay(index: index, value: value!);
                },
              );
            },
          );
        });
  }
}
