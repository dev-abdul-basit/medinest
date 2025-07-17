import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/ui/add_medicine/add_medicine_controller.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class ChooseColor extends StatelessWidget {


  const ChooseColor({super.key,
    required this.title,
    required this.onTapSave, this.defaultColor});

  final String? title;
  final Color? defaultColor;

  final void Function(Color?) onTapSave;

  @override
  Widget build(BuildContext context) {
    Color? shadeColor;
    return Wrap(
      children: [
        Container(
          width: AppSizes.fullWidth,
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surfaceVariant,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(50),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: AppSizes.height_2,
              ),
              CommonText(
                  text: title ?? 'Test',
                  textColor: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.size_17),

              GetBuilder<AddMedicineController>(
                  id: Constant.idColorList,
                  builder: (logic) {
                    return GridView.builder(
                        padding: const EdgeInsets.all(25),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

                          crossAxisCount: 5,
                          mainAxisSpacing: 10, // spacing between rows
                          crossAxisSpacing: 10, // spacing between columns
                        ),
                        itemCount: logic.colorList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              logic.onSelectColor(index);
                              shadeColor = logic.colorList[index].color;
                            },
                            child: ColorItem(
                                colorPicker: logic.colorList[index]),
                          );
                        });
                  }),
              // GetBuilder<AddMedicineController>(builder: (logic) {
              //   return const Padding(
              //     padding: EdgeInsets.all(8.0),
              //     // child: MaterialColorPicker(
              //     //   selectedColor: defaultColor,
              //     //   onColorChange: (color) => shadeColor = color,
              //     //   spacing: 20,
              //     //   circleSize: 55,
              //     //   onMainColorChange: (value) {
              //     //    logic.shouldSaveShow = true;
              //     //    logic.update([Constant.idColourChooser]);
              //     //   },
              //     //   onBack: () => print("BackButtonPressed"),
              //     // ),
              //   );
              // }),
              GetBuilder<AddMedicineController>(
                  id: Constant.idColourChooser,
                  builder: (logic) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                    CommonButtonOne(
                        onTap: () {
                          Get.back();
                        },
                        backgroundColor: Get.theme.colorScheme.background,
                        text: 'txtCancel'.tr),
                    CommonButtonOne(
                        onTap: () => onTapSave(shadeColor), text: 'txtSave'.tr),
                  ],
                );
              }),
              SizedBox(
                height: AppSizes.height_4_5,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ColorItem extends StatelessWidget {
  final ColorPicker colorPicker;

  const ColorItem({super.key, required this.colorPicker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.all(AppSizes.width_4),
      margin: const EdgeInsets.all(5),
        decoration:
        BoxDecoration(color: colorPicker.color, shape: BoxShape.circle),
        child: colorPicker.isSelected?Image.asset(
          Assets.iconsIcSelectTick,
        ):const SizedBox(),
    );
  }
}
