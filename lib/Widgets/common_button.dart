import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/utils/sizer_utils.dart';

class CommonButton extends StatelessWidget {
  final void Function() onTap;

  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
   const CommonButton({super.key, required this.onTap, required this.text, this.backgroundColor, this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.fullWidth-50,
      height: AppSizes.height_7,
      child: ElevatedButton(
        onPressed: onTap,
        // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor?? Get.theme.colorScheme.primary,
          foregroundColor: foregroundColor?? Get.theme.colorScheme.background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          splashFactory: InkSplash.splashFactory,
        ),
        child: CommonText(
            text: text,
            textColor: Get.theme.colorScheme.inversePrimary,
            textAlign: TextAlign.center,
            fontSize: AppFontSize.size_14,
            fontWeight: FontWeight.w600),
      ),
    );
    // return InkWell(
    //   onTap: onTap,
    //   child: SizedBox(
    //     width: AppSizes.fullWidth,
    //     height: AppSizes.height_9,
    //     child: Stack(
    //       alignment: Alignment.topCenter,
    //       children: [
    //         Container(
    //           margin: const EdgeInsets.only(top: 4),
    //           width: AppSizes.fullWidth - 40,
    //           height: AppSizes.height_8,
    //           decoration: ShapeDecoration(
    //             color: Get.theme.colorScheme.errorContainer,
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(1000),
    //             ),
    //           ),
    //         ),
    //         Container(
    //           width: AppSizes.fullWidth - 40,
    //           height: AppSizes.height_8,
    //           alignment: Alignment.center,
    //           decoration: ShapeDecoration(
    //             color: Get.theme.colorScheme.secondary,
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(100),
    //             ),
    //           ),
    //           child: CommonText(
    //               text: text,
    //               textColor: Get.theme.colorScheme.background,
    //               fontWeight: FontWeight.w700,
    //               fontSize: AppFontSize.size_14),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}
