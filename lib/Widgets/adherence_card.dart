import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/services/adherence_service.dart';
import 'package:medinest/utils/sizer_utils.dart';

/// F08 — adherence card. Shown above the home tab strip when the user has
/// at least one logged action today or an active streak. Tappable to open a
/// 14-day weekly bottom sheet. Hidable via the small 'Hide' link.
class AdherenceCard extends StatelessWidget {
  final AdherenceSummary summary;
  final VoidCallback onHide;
  final VoidCallback onTap;

  const AdherenceCard({
    super.key,
    required this.summary,
    required this.onHide,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = summary.totalToday == 0
        ? 0.0
        : summary.takenToday / summary.totalToday;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSizes.width_4,
          vertical: AppSizes.height_1,
        ),
        padding: EdgeInsets.all(AppSizes.width_4),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.onTertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CommonText(
                  text: 'txtAdherenceTodayLabel'.tr,
                  textColor: Get.theme.colorScheme.surfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.size_13,
                ),
                const Spacer(),
                InkWell(
                  onTap: onHide,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.width_2,
                      vertical: AppSizes.height_0_5,
                    ),
                    child: CommonText(
                      text: 'txtAdherenceCardHide'.tr,
                      textColor: Get.theme.colorScheme.surfaceVariant,
                      fontWeight: FontWeight.w400,
                      fontSize: AppFontSize.size_11,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.height_1),
            CommonText(
              text:
                  '${summary.takenToday} / ${summary.totalToday}  ${'txtAdherenceDosesTakenOf'.tr}',
              textColor: Get.theme.colorScheme.surfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: AppFontSize.size_15,
            ),
            SizedBox(height: AppSizes.height_1),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor:
                    Get.theme.colorScheme.surfaceVariant.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Get.theme.colorScheme.primary,
                ),
              ),
            ),
            if (summary.currentStreakDays > 0) ...[
              SizedBox(height: AppSizes.height_1_5),
              CommonText(
                text: summary.currentStreakDays == 1
                    ? 'txtAdherenceStreakSingular'.tr
                    : '${summary.currentStreakDays} ${'txtAdherenceStreakPlural'.tr}',
                textColor: Get.theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: AppFontSize.size_12,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdherenceWeekSheet extends StatelessWidget {
  final AdherenceSummary summary;
  const AdherenceWeekSheet({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.width_5,
        vertical: AppSizes.height_3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            text: 'txtAdherenceWeekTitle'.tr,
            textColor: Get.theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: AppFontSize.size_16,
          ),
          SizedBox(height: AppSizes.height_2),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final d in summary.last14Days)
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _colorFor(d.mark),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSizes.height_2),
          Row(
            children: [
              _LegendDot(
                  color: _colorFor(DayAdherence.onTrack),
                  label: 'txtAdherenceLegendOnTrack'.tr),
              SizedBox(width: AppSizes.width_3),
              _LegendDot(
                  color: _colorFor(DayAdherence.partial),
                  label: 'txtAdherenceLegendPartial'.tr),
              SizedBox(width: AppSizes.width_3),
              _LegendDot(
                  color: _colorFor(DayAdherence.missed),
                  label: 'txtAdherenceLegendMissed'.tr),
            ],
          ),
          SizedBox(height: AppSizes.height_3),
        ],
      ),
    );
  }

  Color _colorFor(DayAdherence mark) {
    switch (mark) {
      case DayAdherence.onTrack:
        return Get.theme.colorScheme.primary;
      case DayAdherence.partial:
        return Colors.amber;
      case DayAdherence.missed:
        return Colors.redAccent;
      case DayAdherence.none:
        return Get.theme.colorScheme.onSecondary;
    }
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSizes.width_1_5),
        CommonText(
          text: label,
          textColor: Get.theme.colorScheme.primary,
          fontSize: AppFontSize.size_11,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }
}
