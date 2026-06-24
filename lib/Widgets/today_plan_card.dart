import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/glass/liquid_glass.dart';
import 'package:medinest/services/today_plan_service.dart';
import 'package:medinest/utils/glass_tokens.dart';
import 'package:medinest/utils/sizer_utils.dart';

/// "Today" engagement summary on the Reminders tab — a liquid-glass card with a
/// progress ring (doses taken vs scheduled today), the next upcoming dose, and
/// the current streak. Tapping opens the 14-day adherence sheet.
class TodayPlanCard extends StatelessWidget {
  final TodayPlan plan;
  final VoidCallback onTap;

  const TodayPlanCard({super.key, required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Get.theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.width_4,
        AppSizes.height_1,
        AppSizes.width_4,
        AppSizes.height_0_5,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: LiquidGlass(
          borderRadius: GlassTokens.radiusLg,
          elevated: true,
          sheen: true,
          padding: EdgeInsets.all(AppSizes.width_4),
          child: Row(
            children: [
              _progressRing(scheme),
              SizedBox(width: AppSizes.width_4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CommonText(
                            text: 'txtToday'.tr,
                            textColor: scheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: AppFontSize.size_16,
                          ),
                        ),
                        if (plan.streakDays > 0) _streakPill(scheme),
                      ],
                    ),
                    SizedBox(height: AppSizes.height_0_5),
                    CommonText(
                      text: _progressText(),
                      maxLines: 1,
                      textColor: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: AppFontSize.size_13,
                    ),
                    if (plan.nextDoseAt != null) ...[
                      SizedBox(height: AppSizes.height_0_8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: AppFontSize.size_15,
                            color: scheme.primary,
                          ),
                          SizedBox(width: AppSizes.width_1_5),
                          Expanded(
                            child: CommonText(
                              text: _nextText(),
                              maxLines: 1,
                              textColor: scheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                              fontSize: AppFontSize.size_12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressRing(ColorScheme scheme) {
    return SizedBox(
      width: AppSizes.height_7,
      height: AppSizes.height_7,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: AppSizes.height_7,
            height: AppSizes.height_7,
            child: CircularProgressIndicator(
              value: plan.progress,
              strokeWidth: 5,
              backgroundColor: scheme.primary.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
          if (plan.allDoneToday)
            Icon(Icons.check_rounded,
                color: scheme.primary, size: AppFontSize.size_22)
          else
            CommonText(
              text: '${plan.takenToday}/${plan.scheduledToday}',
              textColor: scheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: AppFontSize.size_13,
            ),
        ],
      ),
    );
  }

  Widget _streakPill(ColorScheme scheme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.width_2,
        vertical: AppSizes.height_0_3,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          SizedBox(width: AppSizes.width_1),
          CommonText(
            text: '${plan.streakDays}',
            textColor: scheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: AppFontSize.size_12,
          ),
        ],
      ),
    );
  }

  String _progressText() {
    if (plan.scheduledToday <= 0) return 'txtNoDosesToday'.tr;
    if (plan.allDoneToday) return 'txtAllDoneToday'.tr;
    return '${plan.takenToday}/${plan.scheduledToday} ${'txtDosesToday'.tr}';
  }

  String _nextText() {
    final DateTime at = plan.nextDoseAt!;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(at.year, at.month, at.day);
    final String time = DateFormat('h:mm a').format(at);

    String whenPrefix;
    final int diff = day.difference(today).inDays;
    if (diff == 0) {
      whenPrefix = '';
    } else if (diff == 1) {
      whenPrefix = '${'txtTomorrow'.tr} ';
    } else {
      whenPrefix = '${DateFormat('EEE').format(at)} ';
    }

    final String name = plan.nextMedicineName ?? '';
    final String tail = name.isEmpty ? '' : ' • $name';
    return '${'txtNext'.tr}: $whenPrefix$time$tail';
  }
}
