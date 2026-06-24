import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';

/// F15 — engagement notification budget.
///
/// The gatekeeper every NON-medicine notification (win-back, streak milestone,
/// adherence tip, journal prompt) must pass before it fires. Medicine reminders
/// are user-set and bypass this entirely.
///
/// Pure logic — the caller injects [now] and the list of upcoming medicine
/// reminder timestamps (epoch ms, from `notification_table`). No DB or UI
/// coupling, so it stays unit-testable like [AdherenceService]. All thresholds
/// read from [Constant]; rationale + locked values live in
/// docs/feature-improvements/engagement-system.md §9.
///
/// Priority ordering ([EngagementKind]) lets a caller resolve same-window
/// contention: fire the higher-priority kind and drop the rest. This slice does
/// not itself send anything — wiring is F16.
enum EngagementKind {
  resurrection, // highest — winning back a dark user beats everything
  milestone,
  journal,
  adherenceTip, // lowest
}

class EngagementDecision {
  final bool allowed;
  final String reason;
  const EngagementDecision(this.allowed, this.reason);
}

class EngagementService {
  /// Decide whether an engagement notification may fire right now.
  ///
  /// [upcomingReminderTimestamps] are epoch-ms fire times of scheduled medicine
  /// reminders; we refuse to fire within [Constant.engagementMinGapToReminderMinutes]
  /// of any of them so engagement nudges never crowd a real dose reminder.
  EngagementDecision canFire({
    required DateTime now,
    List<int> upcomingReminderTimestamps = const [],
    EngagementKind? kind,
  }) {
    // (a) Quiet hours — no engagement notifications in [start, end).
    final hour = now.hour;
    final inQuietHours = hour >= Constant.engagementQuietHourStart ||
        hour < Constant.engagementQuietHourEnd;
    if (inQuietHours) {
      return const EngagementDecision(false, 'quiet-hours');
    }

    // (b) Spacing — keep clear of any nearby medicine reminder.
    final nowMs = now.millisecondsSinceEpoch;
    final gapMs = Constant.engagementMinGapToReminderMinutes * 60 * 1000;
    for (final ts in upcomingReminderTimestamps) {
      if ((ts - nowMs).abs() < gapMs) {
        return const EngagementDecision(false, 'too-close-to-reminder');
      }
    }

    // (c) Daily cap. Locked value is 1/day, enforced as "already fired today".
    // (If engagementMaxPerDay is ever raised this needs a per-day counter.)
    final lastTs = Preference.shared.getLastEngagementNotifTs();
    if (Constant.engagementMaxPerDay <= 1 && lastTs > 0) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastTs);
      if (_sameDay(last, now)) {
        return const EngagementDecision(false, 'daily-cap');
      }
    }

    // (d) Weekly cap — rolling 7-day window.
    final weekStartTs = Preference.shared.getEngagementWeekStartTs();
    final windowLive = weekStartTs > 0 &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(weekStartTs)).inDays <
            7;
    if (windowLive &&
        Preference.shared.getEngagementWeekCount() >=
            Constant.engagementMaxPerWeek) {
      return const EngagementDecision(false, 'weekly-cap');
    }

    return EngagementDecision(true, 'ok${kind == null ? '' : ':${kind.name}'}');
  }

  /// Record that an engagement notification fired at [now]. Advances the daily
  /// marker and rolls / increments the weekly window. Call only after a fire
  /// that [canFire] allowed.
  Future<void> recordFired(DateTime now) async {
    final nowMs = now.millisecondsSinceEpoch;
    await Preference.shared.setLastEngagementNotifTs(nowMs);

    final weekStartTs = Preference.shared.getEngagementWeekStartTs();
    final windowExpired = weekStartTs == 0 ||
        now.difference(DateTime.fromMillisecondsSinceEpoch(weekStartTs)).inDays >=
            7;
    if (windowExpired) {
      await Preference.shared.setEngagementWeekStartTs(nowMs);
      await Preference.shared.setEngagementWeekCount(1);
    } else {
      await Preference.shared
          .setEngagementWeekCount(Preference.shared.getEngagementWeekCount() + 1);
    }
    Debug.printLog(
        "EngagementService: recorded fire, week count ${Preference.shared.getEngagementWeekCount()}");
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
