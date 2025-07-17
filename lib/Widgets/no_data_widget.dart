import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/utils/sizer_utils.dart';

class NoDataWidget extends StatelessWidget {
  final String image,text;
  const NoDataWidget({
    super.key, required this.image, required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      width: AppSizes.fullWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height:AppSizes.height_14),
          Image.asset(image),
          SizedBox(height:AppSizes.height_1),
          CommonText(
              text: text,
              textColor: Get.theme.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
              fontSize: AppFontSize.size_12)
        ],
      ),
    );
  }
}