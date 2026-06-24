import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';

/// F21 — FCM client wiring (phase-2 prep).
///
/// Wires the device side of push: permission, token persistence + refresh,
/// broadcast-topic subscription, and foreground display (FCM does NOT show a
/// banner while the app is foregrounded, so we render a local notification).
///
/// HONEST LIMITATION: this is INERT until a backend actually sends a push.
/// There is no Cloud Function / campaign sender yet — that's the server half of
/// engagement-system.md §5, which only pays off after the local system proves
/// it moves D7. Subscribing every install to [Constant.fcmBroadcastTopic] now
/// means a future broadcast can reach all users without collecting a token list.
class FcmService {
  Future<void> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // iOS needs an explicit prompt; Android grants by default pre-13 and is
      // covered by the local-notification permission flow on 13+.
      await messaging.requestPermission();

      final String? token = await messaging.getToken();
      if (token != null) {
        await Preference.shared.setString(Preference.fcmToken, token);
        Debug.printLog("FcmService: token ${token.substring(0, 12)}…");
      }
      messaging.onTokenRefresh.listen((t) {
        Preference.shared.setString(Preference.fcmToken, t);
        Debug.printLog("FcmService: token refreshed");
      });

      await messaging.subscribeToTopic(Constant.fcmBroadcastTopic);

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    } catch (e) {
      Debug.printLog("FcmService: init failed", e);
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return; // data-only message, nothing to show
    await NotificationHelper().showEngagementNotification(
      id: Constant.fcmNotificationId,
      title: notification.title ?? 'MediNest',
      body: notification.body ?? '',
    );
    Debug.printLog("FcmService: foreground push shown");
  }
}
