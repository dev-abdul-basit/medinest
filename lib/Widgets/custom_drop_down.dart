import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class DropdownWithPrefix extends StatelessWidget {
  final Widget prefix;
  final Widget? suffix;
  final List<String> items;
  final String? selectedItem;
  final String hintText;
  final ValueChanged<String?> onChanged;

  const DropdownWithPrefix({
    super.key,
    required this.prefix,
    required this.items,
    this.selectedItem,
    required this.hintText,
    required this.onChanged,
    this.suffix,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.symmetric(vertical: AppSizes.width_3_5),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1,color: Get.theme.colorScheme.surfaceTint)
      ),
      child: Row(
        children: [
          prefix,
          Expanded(
            child: DropdownButton<String>(
              isDense: true,
              isExpanded: true,
              hint: Text(hintText,
                  style: TextStyle(
                    fontSize: AppFontSize.size_11,
                    fontWeight: FontWeight.w400,
                    color: Get.theme.colorScheme.surface,
                    fontFamily: Constant.fontFamilyNunitoSans,
                  )),
              icon: suffix ??
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                        top: 2, end: AppSizes.width_3),
                    child: Image.asset(Assets.iconsIcDropdown,
                        fit: BoxFit.cover,
                        width: AppSizes.width_5,
                        height: AppSizes.width_5),
                  ),
              underline: Container(),
              value: selectedItem,
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child:
                            CommonText(text: item,textColor: Get.theme.colorScheme.primary ,fontSize: AppFontSize.size_12,fontWeight: FontWeight.w400,fontFamily: Constant.fontFamilyNunitoSans),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
