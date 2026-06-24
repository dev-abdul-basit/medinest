import 'package:get/get.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/services/adherence_service.dart';
import 'package:medinest/services/engagement_service.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';

/// F18 — engagement scheduler.
///
/// Orchestrates adherence state → [EngagementService] budget → notification.
/// First real consumer of the F15 guardrail: a milestone celebration only
/// fires if [EngagementService.canFire] allows (quiet hours + daily/weekly cap).
///
/// Takes an already-computed [AdherenceSummary] (no recompute) and an injectable
/// [at] so it stays testable, same discipline as [AdherenceService].
class EngagementScheduler {
  final EngagementService _budget;

  EngagementScheduler([EngagementService? budget])
      : _budget = budget ?? EngagementService();

  Future<void> evaluate({
    required AdherenceSummary summary,
    DateTime? at,
  }) async {
    final now = at ?? DateTime.now();
    await _maybeCelebrateStreak(summary, now);
  }

  Future<void> _maybeCelebrateStreak(
      AdherenceSummary summary, DateTime now) async {
    // Highest milestone the current streak has reached.
    int reached = 0;
    for (final m in Constant.engagementStreakMilestones) {
      if (summary.currentStreakDays >= m) reached = m;
    }
    if (reached == 0) return;

    // Already celebrated this milestone (or a higher one). Storing the highest
    // means a user who jumps past a milestone offline celebrates once, and a
    // dropped-then-recovered streak never re-fires a lower one.
    if (Preference.shared.getLastCelebratedMilestone() >= reached) return;

    final decision =
        _budget.canFire(now: now, kind: EngagementKind.milestone);
    if (!decision.allowed) {
      Debug.printLog(
          "EngagementScheduler: milestone $reached blocked (${decision.reason})");
      return;
    }

    await NotificationHelper().showEngagementNotification(
      id: Constant.milestoneNotificationId,
      title: 'txtStreakMilestoneTitle'.tr,
      body: '$reached ${'txtStreakMilestoneBody'.tr}',
    );
    await Preference.shared.setLastCelebratedMilestone(reached);
    await _budget.recordFired(now);
    Debug.printLog("EngagementScheduler: celebrated milestone $reached");
  }
}
