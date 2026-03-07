import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class DropdownWithPrefixSelectDoctor extends StatelessWidget {
  final Widget prefix;
  final Widget? suffix;
  final List<DoctorsTable> doctorsListItems;
  final DoctorsTable? selectedDoctorItem;
  final ValueChanged<DoctorsTable?> onChangedDoctor;

  const DropdownWithPrefixSelectDoctor({
    super.key,
    required this.prefix,
    required this.doctorsListItems,
    this.selectedDoctorItem,
    required this.onChangedDoctor, this.suffix,
  });




  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.fullWidth-105,
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
            child: DropdownButton<DoctorsTable>(
              isDense: true,
              isExpanded: true,
              dropdownColor: Get.theme.colorScheme.surfaceVariant,
              hint: CommonText(textColor: Get.theme.colorScheme.surface ,text: 'txtSelectDoctor'.tr, fontSize: AppFontSize.size_11,fontWeight: FontWeight.w400,),
              icon: suffix ?? Padding(
                padding:  EdgeInsets.symmetric(vertical: 2, horizontal: AppSizes.width_3),
                child: Image.asset(Assets.iconsIcDropdown,
                    width: AppSizes.width_5,
                    height: AppSizes.width_5),
              ),
              underline: Container(),
              value: selectedDoctorItem,
              items: doctorsListItems
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child:CommonText(text: item.name!,textColor: Get.theme.colorScheme.primary ,fontSize: AppFontSize.size_12,fontWeight: FontWeight.w400,fontFamily: Constant.fontFamilyNunitoSans),
              ))
                  .toList(),
              onChanged: onChangedDoctor,
            ),
          ),
        ],
      ),
    );
  }
}
