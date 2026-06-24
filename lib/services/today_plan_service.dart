import 'package:flutter/material.dart';
import 'package:medinest/database/tables/medicine_table.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/services/adherence_service.dart';

/// Computes the "Today" engagement summary shown on the Reminders tab:
/// how many doses are scheduled today, the next upcoming dose, plus the
/// taken-today count and streak (reused from [AdherenceService]).
///
/// Pure / read-only — it derives everything from the already-loaded medicine
/// rows and the adherence summary; it does not touch the DB or scheduler.
class TodayPlanService {
  TodayPlan compute({
    required List<MedicineTable> medicines,
    required AdherenceSummary adherence,
    DateTime? at,
  }) {
    final DateTime now = at ?? DateTime.now();
    final List<MedicineTable> active = medicines
        .where((m) => m.mIsDeleted != 1 && m.mIsActive == 1)
        .toList();

    int scheduledToday = 0;
    String? nextName;
    DateTime? nextAt;

    for (final m in active) {
      final List<TimeOfDay> times =
          NotificationHelper().parseTimeList(m.mTime ?? '');
      if (times.isEmpty) continue;

      if (_activeOn(m, now)) scheduledToday += times.length;

      // Earliest upcoming dose within the next week.
      for (int d = 0; d < 8; d++) {
        final DateTime day =
            DateTime(now.year, now.month, now.day).add(Duration(days: d));
        if (!_activeOn(m, day)) continue;
        for (final t in times) {
          final DateTime dt =
              DateTime(day.year, day.month, day.day, t.hour, t.minute);
          if (dt.isAfter(now) && (nextAt == null || dt.isBefore(nextAt))) {
            nextAt = dt;
            nextName = m.mName;
          }
        }
      }
    }

    return TodayPlan(
      scheduledToday: scheduledToday,
      takenToday: adherence.takenToday,
      streakDays: adherence.currentStreakDays,
      nextMedicineName: nextName,
      nextDoseAt: nextAt,
      hasMedicines: active.isNotEmpty,
    );
  }

  /// Is [m] scheduled on [day] (date range + weekday rule)?
  bool _activeOn(MedicineTable m, DateTime day) {
    final DateTime d0 = DateTime(day.year, day.month, day.day);

    final DateTime? start = DateTime.tryParse(m.mStartDate ?? '');
    if (start != null &&
        d0.isBefore(DateTime(start.year, start.month, start.day))) {
      return false;
    }
    if (m.mIsNoEndDate != 1) {
      final DateTime? end = DateTime.tryParse(m.mEndDate ?? '');
      if (end != null && d0.isAfter(DateTime(end.year, end.month, end.day))) {
        return false;
      }
    }
    if ((m.mFrequencyType ?? '') != 'Every day') {
      final List<int> days = _parseDays(m.mDayOfWeek);
      if (days.isNotEmpty && !days.contains(d0.weekday)) return false;
    }
    return true;
  }

  /// Parse a stored "[1, 2, 3]" weekday list to ints (1 = Mon … 7 = Sun).
  List<int> _parseDays(String? raw) {
    if (raw == null) return const [];
    return raw
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
  }
}

class TodayPlan {
  final int scheduledToday;
  final int takenToday;
  final int streakDays;
  final String? nextMedicineName;
  final DateTime? nextDoseAt;
  final bool hasMedicines;

  const TodayPlan({
    required this.scheduledToday,
    required this.takenToday,
    required this.streakDays,
    required this.nextMedicineName,
    required this.nextDoseAt,
    required this.hasMedicines,
  });

  /// Progress ratio of today's doses (0–1). 1.0 when nothing scheduled (so the
  /// ring reads "complete / nothing pending" rather than empty).
  double get progress {
    if (scheduledToday <= 0) return 1.0;
    final r = takenToday / scheduledToday;
    return r.clamp(0.0, 1.0);
  }

  bool get allDoneToday => scheduledToday > 0 && takenToday >= scheduledToday;
}
