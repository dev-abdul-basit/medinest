import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class DropdownWithPrefixMinutes extends StatelessWidget {
  final Widget prefix;
  final Widget? suffix;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;

  const DropdownWithPrefixMinutes({
    super.key,
    required this.prefix,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: Get.theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color:  Get.theme.colorScheme.surfaceTint)),
      child: Row(
        children: [
          prefix,
          Expanded(
            child: DropdownButton<String>(
              isDense: true,
              isExpanded: true,
              hint: CommonText(
                  text: 'txtSelectRemindBeforeTime'.tr,
                  fontSize: AppFontSize.size_11,
                  fontWeight: FontWeight.w400,
                  textColor: Get.theme.colorScheme.surface),
              icon: suffix ??
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.width_4),
                    child: Image.asset(Assets.iconsIcDropdown,
                        width: AppSizes.width_5, height: AppSizes.width_5),
                  ),
              underline: Container(),
              value: selectedItem,
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: CommonText(
                          text: item=='None'?item.toString():'${item.toString()} Min',
                          textColor: Get.theme.colorScheme.primary,
                          fontSize: AppFontSize.size_12,
                          fontWeight: FontWeight.w400,
                            fontFamily: Constant.fontFamilyNunitoSans
                        ),
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
