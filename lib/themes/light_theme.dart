import 'package:flutter/material.dart';

import '../utils/color.dart';

ThemeData lightTheme = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.colorPrimaryLight, // background (button) color
      foregroundColor: Colors.white, // foreground (text) color
    ),
  ),
  tabBarTheme: TabBarThemeData(
    splashFactory: NoSplash.splashFactory,
    overlayColor: MaterialStateProperty.all(Colors.white),
  ),
  // appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
  scaffoldBackgroundColor: AppColor.white,
  cardColor: AppColor.white,
  primaryColor: AppColor.colorPrimaryLight,
  useMaterial3: true,
  // timePickerTheme: _timePickerTheme,
  // datePickerTheme: _datePickerTheme,
  scrollbarTheme: ScrollbarThemeData(
    thumbColor: MaterialStateProperty.all(AppColor.black.withOpacity(.3)),
  ),
  highlightColor: AppColor.colorTransparent,
  splashColor: AppColor.colorTransparent,
  checkboxTheme: CheckboxThemeData(
    side: const BorderSide(color: AppColor.colorSecondaryLight),
    checkColor: MaterialStateProperty.all(AppColor.colorBackGroundLight),
  ),
  colorScheme: const ColorScheme(
    background: AppColor.colorBackGroundLight,
    //for background
    inverseSurface: AppColor.colorBackGroundLight,
    // for Icons
    tertiary: AppColor.colorInputBackground,
    tertiaryContainer: AppColor.colorInputBackground,
    onTertiary: AppColor.colorSecondaryLight,
    brightness: Brightness.light,
    primary: AppColor.colorPrimaryLight,
    primaryContainer: AppColor.colorPrimaryLight,
    onPrimary: AppColor.colorPrimaryLight,
    secondary: AppColor.colorSecondaryLight,
    secondaryContainer: AppColor.colorPrimaryLight,
    onSecondary: AppColor.colorSecondaryLight,
    error: AppColor.colorTextWhite,
    onError: AppColor.colorTextWhite,
    onBackground: AppColor.colorBackGroundLight,
    surface: AppColor.colorTextGray,
    onSurface: AppColor.colorTextGray,
    surfaceTint: AppColor.colorTextGray,
    onInverseSurface: AppColor.grayLight,
    errorContainer: AppColor.darkBlue,
    onSurfaceVariant: AppColor.colorPrimaryLight,
    //for text
    surfaceVariant: AppColor.colorBackGroundLight,
    inversePrimary: AppColor.colorBackGroundLight,
    onPrimaryContainer: AppColor.colorBackGroundLight,
  ),
);
