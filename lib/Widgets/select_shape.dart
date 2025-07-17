import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/database/tables/shape_table.dart';
import 'package:medinest/ui/add_medicine/add_medicine_controller.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class SelectShape extends StatelessWidget {
  const SelectShape(
      {super.key,
      required this.title,
      required this.onTapSave});

  final String? title;

  final void Function() onTapSave;

  @override
  Widget build(BuildContext context) {
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
                  id: Constant.idShapeList,
                  builder: (logic) {
                    return GridView.builder(
                        padding: const EdgeInsets.all(15),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisExtent: AppSizes.height_11_5,
                          mainAxisSpacing: 13.0, // spacing between rows
                          crossAxisSpacing: 13.0, // spacing between columns
                        ),
                        itemCount: logic.allShapeList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              logic.onSelectShape(index);
                            },
                            child: ShapeItem(
                              shapeListItem: logic.allShapeList[index]),
                          );
                        });
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CommonButtonOne(
                      onTap: () {
                        Get.back();
                      },
                      backgroundColor: Get.theme.colorScheme.background,
                      text: 'txtCancel'.tr),
                  CommonButtonOne(onTap: onTapSave, text: 'txtSave'.tr),
                ],
              ),
              SizedBox(
                height: AppSizes.height_2,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ShapeItem extends StatelessWidget {
  final ShapeTable shapeListItem;

  const ShapeItem({
    super.key,
    required this.shapeListItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            color: shapeListItem.isSelected
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.onInverseSurface,
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                side: BorderSide(
                    color: shapeListItem.isSelected
                        ? Get.theme.colorScheme.onTertiary
                        : Get.theme.colorScheme.onInverseSurface,
                    width: 1.5)),
            child: Center(
                child: Image.memory(shapeListItem.shapeImage!,
                    height: AppSizes.height_5, width: AppSizes.height_5)),
          ),
        ),
        CommonText(
            text: shapeListItem.shapeName!,
            textColor: shapeListItem.isSelected
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.onSurface,
            fontWeight:
                shapeListItem.isSelected ? FontWeight.w700 : FontWeight.w400,
            fontSize: AppFontSize.size_8),
      ],
    );
  }
}
