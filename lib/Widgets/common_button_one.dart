import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/utils/sizer_utils.dart';

class CommonButtonOne extends StatelessWidget {
  final void Function() onTap;

  final String text;
  final Color? backgroundColor,textColor,borderColor;

  const CommonButtonOne(
      {super.key,
      required this.onTap,
      required this.text,
      this.backgroundColor, this.textColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.fullWidth / 2.5,
      height: AppSizes.height_7,
      child: ElevatedButton(
        onPressed: onTap,
        // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          elevation: 0,
            shape: RoundedRectangleBorder(
                side:
                    BorderSide(width: 2, color: borderColor??Get.theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(20)),
            splashFactory: InkSplash.splashFactory,
            surfaceTintColor: Get.theme.colorScheme.primary,
            foregroundColor: backgroundColor != null
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.background,
            backgroundColor: backgroundColor ?? Get.theme.colorScheme.primary),
        child: CommonText(
            text: text,
            textColor: backgroundColor != null
                ? textColor??Get.theme.colorScheme.primary
                : Get.theme.colorScheme.inverseSurface,
            textAlign: TextAlign.center,
            fontSize: AppFontSize.size_14,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
