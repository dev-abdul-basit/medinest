import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/tables/medicine_history_table.dart';
import 'package:medinest/utils/debug.dart';

/// F08 — adherence service.
///
/// Computes today's adherence ratio + current consecutive-day streak from
/// `medicine_history_table`. A day "counts" toward the streak when its
/// adherence (taken / (taken + skipped)) is ≥ [streakThreshold] AND the user
/// had at least one logged action that day. Days with zero logged actions are
/// neutral — they don't count, but they don't break the streak either.
class AdherenceService {
  static const double streakThreshold = 0.8;

  Future<AdherenceSummary> compute({DateTime? at}) async {
    final now = at ?? DateTime.now();
    final List<MedicineHistoryTable?> all =
        await DataBaseHelper.instance.getMedicineHistoryData();

    int takenToday = 0;
    int skippedToday = 0;

    final byDay = <String, _DayCounts>{};
    for (final row in all) {
      if (row == null || row.takenTime == null) continue;
      final dt = DateTime.tryParse(row.takenTime!);
      if (dt == null) continue;
      final key = _dayKey(dt);
      final counts = byDay.putIfAbsent(key, () => _DayCounts());
      if (row.isTaken == 1) {
        counts.taken++;
      } else if (row.isSkipped == 1) {
        counts.skipped++;
      }
      if (_sameDay(dt, now)) {
        if (row.isTaken == 1) takenToday++;
        if (row.isSkipped == 1) skippedToday++;
      }
    }

    final totalToday = takenToday + skippedToday;

    int streak = 0;
    DateTime cursor = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    while (true) {
      final key = _dayKey(cursor);
      final c = byDay[key];
      if (c == null) {
        // No activity that day — neutral, do not extend streak but do not break it either
        cursor = cursor.subtract(const Duration(days: 1));
        if (now.difference(cursor).inDays > 60) break;
        continue;
      }
      final total = c.taken + c.skipped;
      if (total == 0) break;
      final ratio = c.taken / total;
      if (ratio >= streakThreshold) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    final last14 = <DayMark>[];
    for (int i = 13; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final c = byDay[_dayKey(d)];
      if (c == null || c.taken + c.skipped == 0) {
        last14.add(DayMark(date: d, mark: DayAdherence.none));
      } else {
        final ratio = c.taken / (c.taken + c.skipped);
        last14.add(DayMark(
          date: d,
          mark: ratio >= streakThreshold
              ? DayAdherence.onTrack
              : (ratio > 0 ? DayAdherence.partial : DayAdherence.missed),
        ));
      }
    }

    Debug.printLog(
        "AdherenceService: today $takenToday/$totalToday, streak $streak");

    return AdherenceSummary(
      takenToday: takenToday,
      totalToday: totalToday,
      currentStreakDays: streak,
      last14Days: last14,
    );
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class AdherenceSummary {
  final int takenToday;
  final int totalToday;
  final int currentStreakDays;
  final List<DayMark> last14Days;
  const AdherenceSummary({
    required this.takenToday,
    required this.totalToday,
    required this.currentStreakDays,
    required this.last14Days,
  });

  /// True when there is nothing to show — no doses today AND no streak.
  bool get isEmpty => totalToday == 0 && currentStreakDays == 0;
}

enum DayAdherence { onTrack, partial, missed, none }

class DayMark {
  final DateTime date;
  final DayAdherence mark;
  const DayMark({required this.date, required this.mark});
}

class _DayCounts {
  int taken = 0;
  int skipped = 0;
}
