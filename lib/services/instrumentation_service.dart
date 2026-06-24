import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';

/// F20 — lightweight, local retention instrumentation.
///
/// No new package: counts live in `Preference`, events stream to [Debug]. With
/// `firstInstallTs` (F02) + `lastOpenTs` (F15) + `openCount` we can read basic
/// D1/D7/D30 windows and notification effectiveness without a backend.
///
/// NOTE: for real funnels/dashboards these same calls should also forward to
/// Firebase Analytics — deferred until the `firebase_analytics` package is
/// approved (architecture-canon: new package needs sign-off). The call sites
/// are centralised here so that becomes a one-line-per-event change.
class InstrumentationService {
  /// Call once per app open (Home entry). Advances open count + last-open time
  /// and logs a coarse retention snapshot.
  Future<void> recordAppOpen({DateTime? at}) async {
    final now = at ?? DateTime.now();
    final int count = Preference.shared.getOpenCount() + 1;
    await Preference.shared.setOpenCount(count);
    await Preference.shared.setLastOpenTs(now.millisecondsSinceEpoch);

    final int installTs = Preference.shared.getFirstInstallTs();
    final int daysSinceInstall = installTs == 0
        ? 0
        : now
            .difference(DateTime.fromMillisecondsSinceEpoch(installTs))
            .inDays;
    Debug.printLog(
        "Instrumentation: appOpen #$count, day $daysSinceInstall since install");
  }

  /// Call when the user taps an engagement (win-back / milestone / nudge / FCM)
  /// notification — a proxy for notification effectiveness.
  Future<void> recordEngagementTap() async {
    final int count = Preference.shared.getEngagementTapCount() + 1;
    await Preference.shared.setEngagementTapCount(count);
    Debug.printLog("Instrumentation: engagement tap #$count");
  }
}
