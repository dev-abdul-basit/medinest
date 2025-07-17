
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/date_time_line/easy_date_timeline.dart';
import 'package:medinest/utils/sizer_utils.dart';

class DateTimeline extends StatelessWidget {
  final void Function(DateTime)? onDateChange;
  final DateTime? focusDate;
  const DateTimeline({
    super.key,
    required this.onDateChange,
    required this.focusDate
  });

  @override
  Widget build(BuildContext context) {
    return EasyInfiniteDateTimeLine(
      // initialDate: DateTime.now(),
      onDateChange: onDateChange,
      activeColor: Get.theme.colorScheme.onSurfaceVariant,
      // headerProps:  EasyHeaderProps(
      //     centerHeader: true,
      //     monthPickerType: MonthPickerType.switcher,
      //     selectedDateFormat: SelectedDateFormat.fullDateDMonthAsStrY,
      //     monthStyle: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant,fontSize: AppFontSize.size_12,fontWeight: FontWeight.w500),
      //     selectedDateStyle: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant,fontSize: AppFontSize.size_12,fontWeight: FontWeight.w500)
      // ),
      dayProps:  EasyDayProps(
        dayStructure: DayStructure.dayNumDayStr,
        height: AppSizes.height_7,
        width: AppSizes.height_4_5,
        activeDayStyle: DayStyle(
          borderRadius: 32.0,
          dayNumStyle: TextStyle(color: Get.theme.colorScheme.inverseSurface,fontSize: AppFontSize.size_12,fontWeight: FontWeight.w700),
          dayStrStyle: TextStyle(color: Get.theme.colorScheme.inverseSurface,fontSize: AppFontSize.size_10,fontWeight: FontWeight.w500),
        ),
        inactiveDayStyle: DayStyle(
            dayNumStyle: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant,fontSize: AppFontSize.size_12,fontWeight: FontWeight.w500),
            dayStrStyle: TextStyle(color: Get.theme.colorScheme.onSurface,fontSize: AppFontSize.size_10,fontWeight: FontWeight.w500),
            splashBorder: BorderRadius.zero,
            decoration: const BoxDecoration(
                border: Border()
            )
        ), todayStyle:  DayStyle(
          dayNumStyle: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant,fontSize: AppFontSize.size_12,fontWeight: FontWeight.w500),
          dayStrStyle: TextStyle(color: Get.theme.colorScheme.onSurface,fontSize: AppFontSize.size_10,fontWeight: FontWeight.w500),
          splashBorder: BorderRadius.zero,
          decoration: const BoxDecoration(
              border: Border()
          )
      ),

      ),
      timeLineProps: const EasyTimeLineProps(
        hPadding: 0, // padding from left and right
        vPadding: 0,
        margin: EdgeInsets.symmetric(vertical: 10,horizontal: 7),
        separatorPadding: 20,
      ), firstDate: DateTime(2023), lastDate: DateTime.now(), focusDate: focusDate,
    );
  }
}