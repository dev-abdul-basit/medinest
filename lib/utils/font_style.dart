import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/utils/color.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

class AppFontStyle {
  static var styleOrangeRighteous25_400 = TextStyle(
    color: Get.theme.colorScheme.onSecondary,
    fontSize: AppFontSize.size_27,
    fontWeight: FontWeight.normal,
    fontFamily: Constant.fontFamilyRighteous,

  );
  static var styleOrangeRighteous18_400 = TextStyle(
    color: Get.theme.colorScheme.secondary,
    fontSize: AppFontSize.size_14,
    fontWeight: FontWeight.normal,
    fontFamily: Constant.fontFamilyRighteous,

  );
  static var styleBlackRighteous25_400 = TextStyle(
    color: Utils.isLightTheme()?AppColor.black:AppColor.white,
    fontSize: AppFontSize.size_27,
    fontWeight: FontWeight.normal,
    fontFamily: Constant.fontFamilyRighteous,

  );

  static var styleGrayLexendDeca13_400 = TextStyle(
    color: Get.theme.colorScheme.inverseSurface,
    fontSize: AppFontSize.size_13,
    fontWeight: FontWeight.w300,
    fontFamily: Constant.fontFamilyLexendDeca,
  );

  static var styleGrayLexendDeca13_700 = TextStyle(
    color: Get.theme.colorScheme.inverseSurface,
    fontSize: AppFontSize.size_13,
    fontWeight: FontWeight.w700,
    fontFamily: Constant.fontFamilyLexendDeca,
  );

  static var styleWhiteRighteous25_400 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_25,
    fontWeight: FontWeight.normal,
    fontFamily: Constant.fontFamilyRighteous,

  );

  static var styleWhiteNunitoSans14_400 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_14,
    fontWeight: FontWeight.w400,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleBlackNunitoSans18_400 = TextStyle(
    color: Get.theme.colorScheme.errorContainer,
    fontSize: AppFontSize.size_14,
    fontWeight: FontWeight.w700,
    fontFamily: Constant.fontFamilyNunitoSans,
  );

  static var styleWhiteNunitoSans9_400 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_9,
    fontWeight: FontWeight.w400,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleWhiteNunitoSans10_400 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_10,
    fontWeight: FontWeight.w400,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleWhiteNunitoSans13_400 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_13,
    fontWeight: FontWeight.w400,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleWhiteNunitoSans10_600 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_10,
    fontWeight: FontWeight.w600,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleWhiteNunitoSans14_600 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_14,
    fontWeight: FontWeight.w600,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextSolidBlackNunitoSans20_600 = TextStyle(
    color: AppColor.black,
    fontSize: AppFontSize.size_20,
    fontWeight: FontWeight.w600,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleWhiteNunitoSans13_500 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_13,
    fontWeight: FontWeight.w500,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleWhiteNunitoSans14_500 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_14,
    fontWeight: FontWeight.w500,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleWhiteNunitoSans18_700 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_18,
    fontWeight: FontWeight.w700,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextBlackNunitoSans11_400 = TextStyle(
    color: AppColor.black,
    fontSize: AppFontSize.size_11,
    fontWeight: FontWeight.w400,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleWhiteNunitoSans11_400 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_11,
    fontWeight: FontWeight.w400,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextWhiteNunitoSans12_400 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_12,
    fontWeight: FontWeight.w400,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextWhiteNunitoSans9_400 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_9,
    fontWeight: FontWeight.w400,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextWhiteNunitoSans13_400 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_13,
    fontWeight: FontWeight.w400,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleWhiteNunitoSans11_500 = TextStyle(
    color: AppColor.white,
    fontSize: AppFontSize.size_11,
    fontWeight: FontWeight.w500,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextBlackNunitoSans12_400 = TextStyle(
    color: AppColor.black,
    fontSize: AppFontSize.size_12,
    fontWeight: FontWeight.w400,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextBlackNunitoSans12_700 = TextStyle(
    color: AppColor.black,
    fontSize: AppFontSize.size_12,
    fontWeight: FontWeight.w700,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextBlackNunitoSans15_700 = TextStyle(
    color: AppColor.black,
    fontSize: AppFontSize.size_15,
    fontWeight: FontWeight.w700,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextBlackNunitoSans14_500 = TextStyle(
    color: AppColor.black,
    fontSize: AppFontSize.size_14,
    fontWeight: FontWeight.w500,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextBlackNunitoSans25_700 = TextStyle(
    color: Get.theme.colorScheme.onErrorContainer,
    fontSize: AppFontSize.size_25,
    fontWeight: FontWeight.w700,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextBlackNunitoSans14_600 = TextStyle(
    color: AppColor.black,
    fontSize: AppFontSize.size_14,
    fontWeight: FontWeight.w600,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextBlackNunitoSans15_600 = TextStyle(
    color: AppColor.black,
    fontSize: AppFontSize.size_15,
    fontWeight: FontWeight.w600,
    fontFamily: Constant.fontFamilyNunitoSans,
  );
  static var styleTextBlackNunitoSans16_600 = TextStyle(
    color: AppColor.black,
    fontSize: AppFontSize.size_16,
    fontWeight: FontWeight.w600,
    fontFamily: Constant.fontFamilyNunitoSans,
  );

 

  static customizeStyle({fontFamily, color, fontSize, fontWeight, height}) {
    return TextStyle(
      fontFamily: fontFamily,
      height: height,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
  
  /// customise style
  static styleW400(Color? color, double? fontSize) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: Constant.fontFamilyLexendDeca,
      fontWeight: FontWeight.w400, /// Light
    );
  }

  static styleW500(Color? color, double? fontSize) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: Constant.fontFamilyLexendDeca,
      fontWeight: FontWeight.w500, /// Medium
    );
  }

  static styleW600(Color? color, double? fontSize) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: Constant.fontFamilyPoppins,
      fontWeight: FontWeight.w600, /// Regular
    );
  }

  static styleW700(Color? color, double? fontSize) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: Constant.fontFamilyPoppins,
      fontWeight: FontWeight.w700, /// Bold
    );
  }
}
