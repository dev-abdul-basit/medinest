import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_button_with_image.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/sizer_utils.dart';

class DeleteConformation extends StatelessWidget {
  final String? title;
  final String? description, image, buttonText;
  final double? imageWidth, imageHeight;
  final bool isSubscription;

  final void Function() onTapDelete;

  const DeleteConformation(
      {super.key,
      required this.title,
      required this.description,
      required this.onTapDelete,
      this.image,
      this.buttonText,
      this.imageWidth,
      this.imageHeight,
      this.isSubscription = false});

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
                  textColor: Get.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w300,
                  textAlign: isSubscription?TextAlign.start:TextAlign.center,
                  fontSize: AppFontSize.size_13),
              SizedBox(
                height: AppSizes.height_5,
              ),
              isSubscription
                  ? CommonButtonWithImage(
                      onTap: onTapDelete,
                      icon: Assets.iconsIcKing,
                      width: AppSizes.fullWidth - 50,
                      iconSize: AppSizes.width_9,
                      fontSize: AppFontSize.size_16,
                      text: "txtSubscribeNow".tr.toUpperCase(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CommonButtonOne(
                            onTap: () {
                              Get.back();
                            },
                            backgroundColor: Get.theme.colorScheme.background,
                            text: 'txtCancel'.tr),
                        CommonButtonOne(
                            onTap: onTapDelete,
                      text: buttonText??'txtDelete'.tr),
                ],

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
