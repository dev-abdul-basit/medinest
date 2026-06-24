import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

/// iOS-style date & time pickers presented in a bottom popup with a
/// Cancel / Done header. Theme-aware (light & dark) and used app-wide so the
/// picker look matches the rest of the redesigned UI.

Future<DateTime?> showAppDatePicker({
  required DateTime initial,
  required DateTime minimum,
  required DateTime maximum,
}) {
  DateTime temp = initial;
  return _showPickerPopup<DateTime>(
    onDone: () => Get.back(result: temp),
    child: CupertinoDatePicker(
      mode: CupertinoDatePickerMode.date,
      initialDateTime: initial,
      minimumDate: minimum,
      maximumDate: maximum,
      onDateTimeChanged: (d) => temp = d,
    ),
  );
}

Future<TimeOfDay?> showAppTimePicker({required TimeOfDay initial}) {
  DateTime temp = DateTime(2020, 1, 1, initial.hour, initial.minute);
  return _showPickerPopup<TimeOfDay>(
    onDone: () =>
        Get.back(result: TimeOfDay(hour: temp.hour, minute: temp.minute)),
    child: CupertinoDatePicker(
      mode: CupertinoDatePickerMode.time,
      initialDateTime: temp,
      use24hFormat: MediaQuery.of(Get.context!).alwaysUse24HourFormat,
      onDateTimeChanged: (d) => temp = d,
    ),
  );
}

Future<T?> _showPickerPopup<T>({
  required Widget child,
  required VoidCallback onDone,
}) {
  final ColorScheme scheme = Get.theme.colorScheme;
  return showCupertinoModalPopup<T>(
    context: Get.context!,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: scheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cancel / Done header.
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(color: scheme.surface.withOpacity(0.2), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Get.back(),
                    child: CommonText(
                      text: 'txtCancel'.tr,
                      textColor: scheme.surface,
                      fontWeight: FontWeight.w500,
                      fontSize: AppFontSize.size_14,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: onDone,
                    child: CommonText(
                      text: 'txtDone'.tr,
                      textColor: scheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: AppFontSize.size_15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: AppSizes.height_30,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness:
                      Utils.isLightTheme() ? Brightness.light : Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: scheme.onSurface,
                      fontSize: AppFontSize.size_20,
                    ),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
