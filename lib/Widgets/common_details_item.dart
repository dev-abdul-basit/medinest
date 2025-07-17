import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/utils/sizer_utils.dart';

class DetailItem extends StatelessWidget {
  const DetailItem({
    super.key,
    this.title,
    required this.subtitle,
    this.icon,
    this.iconWidget,
    this.textColor,
    this.titleWidget, this.maxWidth,
  });

  final String? title, subtitle, icon;
  final double? maxWidth;
  final Widget? iconWidget, titleWidget;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
            spreadRadius: 0.2,
            blurRadius: 5,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: [
          if (icon != null)
            Image.asset(
              icon!,
              color: Get.theme.colorScheme.onSurface,
              height: AppSizes.height_2_5,
              width: AppSizes.height_2_5,
            ),
          if (iconWidget != null) iconWidget!,
          SizedBox(width: AppSizes.width_3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth:maxWidth??AppSizes.fullWidth-120),
                child: CommonText(
                    text: subtitle!,
                    textColor: Get.theme.colorScheme.onSurface,
                    textAlign: TextAlign.start,
                    fontSize: AppFontSize.size_10,
                    fontWeight: FontWeight.w300),
              ),
              if (title != null)
                Container(
                  constraints: BoxConstraints(maxWidth:maxWidth??AppSizes.fullWidth-120),
                  child: CommonText(
                      text: title!,
                      textColor: textColor ?? Get.theme.colorScheme.primary,
                      textAlign: TextAlign.start,
                      fontSize: AppFontSize.size_12,
                      maxLines: 10,
                      fontWeight: FontWeight.w600),
                ),
              if (titleWidget != null) titleWidget!,
            ],
          )
        ],
      ),
    );
  }
}