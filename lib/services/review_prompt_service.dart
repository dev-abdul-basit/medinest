import 'package:in_app_review/in_app_review.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';

/// F02 — gates the system review prompt to fire only after a user has had a
/// positive interaction with the app (≥3 doses taken, ≥7 days since install,
/// ≥90 days since last prompt, ≥24 h since last paywall). Caller is the home
/// controller's onReady, behind a small delay so it never collides with launch
/// or other dialogs.
class ReviewPromptService {
  static const int _sevenDaysMs = 7 * 24 * 60 * 60 * 1000;
  static const int _ninetyDaysMs = 90 * 24 * 60 * 60 * 1000;
  static const int _oneDayMs = 24 * 60 * 60 * 1000;
  static const int _minDosesTaken = 3;

  static Future<void> maybeShow() async {
    final p = Preference.shared;
    final now = DateTime.now().millisecondsSinceEpoch;

    final firstInstallTs = p.getFirstInstallTs();
    final daysSinceInstall = firstInstallTs == 0 ? 0 : (now - firstInstallTs);
    final lastPromptTs = p.getLastReviewPromptTs();
    final daysSincePrompt = lastPromptTs == 0 ? _ninetyDaysMs + 1 : (now - lastPromptTs);
    final lastPaywallTs = p.getLastPaywallTs();
    final daysSincePaywall = lastPaywallTs == 0 ? _oneDayMs + 1 : (now - lastPaywallTs);
    final dosesTaken = p.getDosesMarkedTaken();

    if (dosesTaken < _minDosesTaken) {
      Debug.printLog("ReviewPromptService: skip — only $dosesTaken doses taken");
      return;
    }
    if (daysSinceInstall < _sevenDaysMs) {
      Debug.printLog("ReviewPromptService: skip — install too recent");
      return;
    }
    if (daysSincePrompt < _ninetyDaysMs) {
      Debug.printLog("ReviewPromptService: skip — prompted within 90 days");
      return;
    }
    if (daysSincePaywall < _oneDayMs) {
      Debug.printLog("ReviewPromptService: skip — paywall within 24h");
      return;
    }

    final InAppReview review = InAppReview.instance;
    final available = await review.isAvailable();
    if (!available) {
      Debug.printLog("ReviewPromptService: in-app review unavailable on this device");
      return;
    }

    await review.requestReview();
    await p.setLastReviewPromptTs(now);
    Debug.printLog("ReviewPromptService: prompt requested at $now");
  }
}
