import 'package:get/get.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/services/adherence_service.dart';
import 'package:medinest/services/engagement_service.dart';
import 'package:medinest/services/today_plan_service.dart';
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
    required TodayPlan todayPlan,
    DateTime? at,
  }) async {
    final now = at ?? DateTime.now();
    // Milestone runs first: if it fires it consumes today's budget slot, so the
    // evening nudge below is naturally suppressed (no stacking).
    await _maybeCelebrateStreak(summary, now);
    await _maybeScheduleEveningNudge(summary, todayPlan, now);
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

  /// F19 — schedule an evening nudge if doses remain untaken today. Copy is
  /// streak-at-risk when the user has a streak to protect, otherwise a gentle
  /// adherence tip. Scheduled (not immediate) for the evening slot.
  Future<void> _maybeScheduleEveningNudge(
      AdherenceSummary summary, TodayPlan plan, DateTime now) async {
    final int remaining = plan.scheduledToday - plan.takenToday;

    // Nothing left to nudge about (all taken, or no meds) — clear any stale one.
    if (remaining <= 0 || !plan.hasMedicines) {
      await NotificationHelper()
          .cancelEngagementNotification(Constant.eveningNudgeNotificationId);
      return;
    }

    // Already handled today — leave the existing schedule in place.
    final int lastTs = Preference.shared.getLastEveningNudgeScheduledTs();
    if (lastTs > 0) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastTs);
      if (last.year == now.year &&
          last.month == now.month &&
          last.day == now.day) {
        return;
      }
    }

    // Tonight's slot; if it has already passed, skip for today.
    final DateTime fireAt = DateTime(now.year, now.month, now.day,
        Constant.engagementEveningHour, Constant.engagementEveningMinute);
    if (!fireAt.isAfter(now)) return;

    final List<int> reminders =
        await NotificationHelper().todayRemainingReminderTimestamps(now);
    final bool atRisk = summary.currentStreakDays >= 3;
    final decision = _budget.canFire(
      now: fireAt,
      upcomingReminderTimestamps: reminders,
      kind: atRisk ? EngagementKind.milestone : EngagementKind.adherenceTip,
    );
    if (!decision.allowed) {
      Debug.printLog(
          "EngagementScheduler: evening nudge blocked (${decision.reason})");
      return;
    }

    await NotificationHelper().scheduleEngagementNotification(
      id: Constant.eveningNudgeNotificationId,
      fireAt: fireAt,
      title: atRisk ? 'txtAtRiskTitle'.tr : 'txtEveningTipTitle'.tr,
      body: atRisk
          ? '${summary.currentStreakDays} ${'txtAtRiskBody'.tr}'
          : '$remaining ${'txtEveningTipBody'.tr}',
    );
    await Preference.shared
        .setLastEveningNudgeScheduledTs(now.millisecondsSinceEpoch);
    await _budget.recordFired(now);
    Debug.printLog(
        "EngagementScheduler: scheduled evening nudge (remaining $remaining, atRisk $atRisk)");
  }
}
