import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/utils/sizer_utils.dart';

class CommonButtonWithImage extends StatelessWidget {
  final void Function() onTap;

  final String text, icon;
  final double? iconSize, fontSize, width;
  final Color? backgroundColor, textColor, borderColor;

  const CommonButtonWithImage(
      {super.key,
      required this.onTap,
      required this.text,
      this.iconSize,
      this.fontSize,
      this.width,
      this.backgroundColor,
      this.textColor,
      this.borderColor,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? (AppSizes.fullWidth - 80),
      height: AppSizes.height_7,
      child: ElevatedButton(
        onPressed: onTap,
        // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
        style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: borderColor ?? Get.theme.colorScheme.primary), borderRadius: BorderRadius.circular(10)),
            splashFactory: InkSplash.splashFactory,
            surfaceTintColor: Get.theme.colorScheme.primary,
            foregroundColor: backgroundColor != null ? Get.theme.colorScheme.primary : Get.theme.colorScheme.background,
            backgroundColor: backgroundColor ?? Get.theme.colorScheme.primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: iconSize ?? AppSizes.width_6,
              height: iconSize ?? AppSizes.width_6,
            ),
            SizedBox(
              width: AppSizes.height_1,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: AppSizes.fullWidth-150),
              child: CommonText(
                  text: text,
                  maxLines: 1,
                  textColor: backgroundColor != null ? textColor ?? Get.theme.colorScheme.primary : Get.theme.colorScheme.inverseSurface,
                  textAlign: TextAlign.center,
                  fontSize: fontSize ?? AppFontSize.size_14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
