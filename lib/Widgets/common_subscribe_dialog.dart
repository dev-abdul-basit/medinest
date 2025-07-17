import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button_with_image.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/sizer_utils.dart';

class CommonSubscriptionDialog extends StatelessWidget {
  final String? title;
  final String? description, image, buttonText;
  final double? imageWidth, imageHeight;

  final void Function() onTapDelete;

  const CommonSubscriptionDialog(
      {super.key,
      required this.title,
      required this.description,
      required this.onTapDelete,
      this.image,
      this.buttonText,
      this.imageWidth,
      this.imageHeight,});

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
                height: AppSizes.height_5,
              ),
              if(image==null)Container(
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Get.theme.colorScheme.onSecondary
                ),
                child: Image.asset(Assets.iconsIcDeleteAlert,
                    height: AppSizes.height_6,
                    width: AppSizes.height_6),
              ),
              if(image!=null)Image.asset(image!,width: imageWidth,height: imageHeight,),
              SizedBox(
                height: AppSizes.height_2,
              ),
              CommonText(
                  text: description ?? 'test',
                  textColor: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                  fontSize: AppFontSize.size_12),
              SizedBox(height: AppSizes.height_3),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: AppSizes.width_7),
                  Image.asset(
                    Assets.iconsIcDoneSubscription,
                    color: Get.theme.colorScheme.onPrimary,
                    height: AppSizes.height_2_5,
                  ),
                  SizedBox(width: AppSizes.width_3),
                  CommonText(
                      text: 'txtRemoveAds'.tr,
                      textColor: Get.theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: AppFontSize.size_12),
                ],
              ),
              SizedBox(height: AppSizes.width_3),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: AppSizes.width_7),
                  Image.asset(
                    Assets.iconsIcDoneSubscription,
                    color: Get.theme.colorScheme.onPrimary,
                    height: AppSizes.height_2_5,
                  ),
                  SizedBox(width: AppSizes.width_3),
                  CommonText(
                      text: 'txtAddUnlimitedMedicines'.tr,
                      textColor: Get.theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: AppFontSize.size_12),
                ],
              ),
              SizedBox(height: AppSizes.width_3),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: AppSizes.width_7),
                  Image.asset(
                    Assets.iconsIcDoneSubscription,
                    color: Get.theme.colorScheme.onPrimary,
                    height: AppSizes.height_2_5,
                  ),
                  SizedBox(width: AppSizes.width_3),
                  CommonText(
                      text: 'txtAddUnlimitedAppointment'.tr,
                      textColor: Get.theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: AppFontSize.size_12),
                ],
              ),
              SizedBox(height: AppSizes.width_5),
              CommonButtonWithImage(
                      onTap: onTapDelete,
                      icon: Assets.iconsIcKing,
                      width: AppSizes.fullWidth - 50,
                      iconSize: AppSizes.width_9,
                      fontSize: AppFontSize.size_16,
                      text: "txtSubscribeNow".tr.toUpperCase(),
                    ),

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
