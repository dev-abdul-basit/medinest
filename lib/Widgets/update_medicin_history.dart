import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button_with_image.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/sizer_utils.dart';

class UpdateMedicineHistory extends StatelessWidget {
  final String? title;
  final bool isMedicine;

  final void Function() onTapTaken,onSkipped;

  const UpdateMedicineHistory({super.key, required this.title, required this.onTapTaken, required this.onSkipped, this.isMedicine=true});

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
                  text: title??'Test',
                  textColor: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.size_17),
              SizedBox(
                height: AppSizes.height_2,
              ),
              CommonButtonWithImage(
                icon: isMedicine?Assets.iconsIcTaken:Assets.iconsIcActive,
                  onTap: onTapTaken,
                  text: isMedicine?'txtTaken'.tr:'txtAccept'.tr),
              SizedBox(
                height: AppSizes.height_2,
              ),
              CommonButtonWithImage(
                  icon: isMedicine?Assets.iconsIcSuspand:Assets.iconsIcReSchedule,
                  onTap: onSkipped,
                  backgroundColor: Get.theme.colorScheme.background,
                  text: isMedicine?'txtSkipped'.tr:'txtReSchedule'.tr),
              SizedBox(
                height: AppSizes.height_5,
              ),
            ],
          ),
        )
      ],
    );
  }
}
